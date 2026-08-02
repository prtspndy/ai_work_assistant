import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/business_task.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper;
  static const String _webStorageKey = 'vyapar_web_tasks_storage';
  static final List<BusinessTask> _webTasks = [];
  static bool _webInitialized = false;

  TaskRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<void> _initWebStorageIfNeeded() async {
    if (_webInitialized || !kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_webStorageKey);
      if (rawList != null && rawList.isNotEmpty) {
        _webTasks.clear();
        for (final itemStr in rawList) {
          final map = jsonDecode(itemStr) as Map<String, dynamic>;
          _webTasks.add(BusinessTask.fromMap(map));
        }
      }
    } catch (e) {
      debugPrint('Web storage load error: $e');
    } finally {
      _webInitialized = true;
    }
  }

  Future<void> _saveWebStorage() async {
    if (!kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final strList = _webTasks.map((t) => jsonEncode(t.toMap())).toList();
      await prefs.setStringList(_webStorageKey, strList);
    } catch (e) {
      debugPrint('Web storage save error: $e');
    }
  }

  Future<int> insertTask(BusinessTask task) async {
    if (kIsWeb) {
      await _initWebStorageIfNeeded();
      final newId = DateTime.now().millisecondsSinceEpoch;
      final taskToInsert = task.copyWith(
        id: newId,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      );
      _webTasks.insert(0, taskToInsert);
      await _saveWebStorage();
      return newId;
    }

    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final taskToInsert = task.copyWith(
        createdAt: task.createdAt,
        updatedAt: now,
      );
      return await db.insert('tasks', taskToInsert.toMap());
    } catch (e) {
      debugPrint('SQLite insert exception, using fallback: $e');
      await _initWebStorageIfNeeded();
      final newId = DateTime.now().millisecondsSinceEpoch;
      final taskToInsert = task.copyWith(
        id: newId,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
      );
      _webTasks.insert(0, taskToInsert);
      await _saveWebStorage();
      return newId;
    }
  }

  Future<List<BusinessTask>> getAllTasks() async {
    if (kIsWeb) {
      await _initWebStorageIfNeeded();
      _webTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return List.from(_webTasks);
    }

    try {
      final db = await _dbHelper.database;
      final maps = await db.query('tasks', orderBy: 'created_at DESC');
      return maps.map((map) => BusinessTask.fromMap(map)).toList();
    } catch (e) {
      debugPrint('SQLite getAllTasks exception, using fallback: $e');
      await _initWebStorageIfNeeded();
      _webTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return List.from(_webTasks);
    }
  }

  Future<BusinessTask?> getTaskById(int id) async {
    if (kIsWeb) {
      await _initWebStorageIfNeeded();
      final index = _webTasks.indexWhere((t) => t.id == id);
      return index != -1 ? _webTasks[index] : null;
    }

    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return BusinessTask.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      await _initWebStorageIfNeeded();
      final index = _webTasks.indexWhere((t) => t.id == id);
      return index != -1 ? _webTasks[index] : null;
    }
  }

  Future<int> updateTask(BusinessTask task) async {
    if (kIsWeb) {
      await _initWebStorageIfNeeded();
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      final index = _webTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _webTasks[index] = updatedTask;
      } else {
        _webTasks.insert(0, updatedTask);
      }
      await _saveWebStorage();
      return task.id ?? 1;
    }

    try {
      final db = await _dbHelper.database;
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      return await db.update(
        'tasks',
        updatedTask.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      debugPrint('SQLite updateTask exception, using fallback: $e');
      await _initWebStorageIfNeeded();
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      final index = _webTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _webTasks[index] = updatedTask;
      } else {
        _webTasks.insert(0, updatedTask);
      }
      await _saveWebStorage();
      return task.id ?? 1;
    }
  }

  Future<int> deleteTask(int id) async {
    if (kIsWeb) {
      await _initWebStorageIfNeeded();
      _webTasks.removeWhere((t) => t.id == id);
      await _saveWebStorage();
      return 1;
    }

    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('SQLite deleteTask exception, using fallback: $e');
      await _initWebStorageIfNeeded();
      _webTasks.removeWhere((t) => t.id == id);
      await _saveWebStorage();
      return 1;
    }
  }

  Future<List<BusinessTask>> searchTasks(String query) async {
    final all = await getAllTasks();
    if (query.trim().isEmpty) return all;
    final q = query.trim().toLowerCase();
    return all.where((t) {
      return (t.customerName?.toLowerCase().contains(q) ?? false) ||
          (t.action?.toLowerCase().contains(q) ?? false) ||
          (t.itemName?.toLowerCase().contains(q) ?? false) ||
          t.originalInstruction.toLowerCase().contains(q) ||
          t.generatedMessage.toLowerCase().contains(q) ||
          (t.notes?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<List<BusinessTask>> getTasksByDate(DateTime date) async {
    final all = await getAllTasks();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return all.where((t) {
      final dueStr = t.dueDate != null ? DateFormat('yyyy-MM-dd').format(t.dueDate!) : null;
      final createdStr = DateFormat('yyyy-MM-dd').format(t.createdAt);
      return dueStr == dateStr || createdStr == dateStr;
    }).toList();
  }

  Future<List<BusinessTask>> getTasksByDateRange(DateTime start, DateTime end) async {
    final all = await getAllTasks();
    return all.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(start.subtract(const Duration(days: 1))) &&
             t.dueDate!.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<List<BusinessTask>> getPendingTasks() async {
    final all = await getAllTasks();
    return all.where((t) => t.taskStatus != 'completed' && t.taskStatus != 'cancelled').toList();
  }

  Future<List<BusinessTask>> getCompletedTasks() async {
    final all = await getAllTasks();
    return all.where((t) => t.taskStatus == 'completed').toList();
  }

  Future<double> getTotalPendingAmount() async {
    final all = await getAllTasks();
    double total = 0.0;
    for (final t in all) {
      if (t.paymentStatus == 'pending' && t.amount != null) {
        total += t.amount!;
      }
    }
    return total;
  }

  Future<int> getTodayPendingCount() async {
    final all = await getAllTasks();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int count = 0;
    for (final t in all) {
      final dueStr = t.dueDate != null ? DateFormat('yyyy-MM-dd').format(t.dueDate!) : null;
      final createdStr = DateFormat('yyyy-MM-dd').format(t.createdAt);
      if ((dueStr == todayStr || createdStr == todayStr) &&
          t.taskStatus != 'completed' &&
          t.taskStatus != 'cancelled') {
        count++;
      }
    }
    return count;
  }

  Future<List<BusinessTask>> getRecentTasks({int limit = 5}) async {
    final all = await getAllTasks();
    return all.take(limit).toList();
  }
}
