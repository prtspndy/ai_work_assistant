import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/business_task.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper;

  TaskRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> insertTask(BusinessTask task) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final taskToInsert = task.copyWith(
      createdAt: task.createdAt,
      updatedAt: now,
    );
    return await db.insert('tasks', taskToInsert.toMap());
  }

  Future<List<BusinessTask>> getAllTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query('tasks', orderBy: 'created_at DESC');
    return maps.map((map) => BusinessTask.fromMap(map)).toList();
  }

  Future<BusinessTask?> getTaskById(int id) async {
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
  }

  Future<int> updateTask(BusinessTask task) async {
    final db = await _dbHelper.database;
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'tasks',
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BusinessTask>> searchTasks(String query) async {
    if (query.trim().isEmpty) return getAllTasks();

    final db = await _dbHelper.database;
    final searchPattern = '%${query.trim()}%';
    final maps = await db.query(
      'tasks',
      where: '''
        customer_name LIKE ? OR 
        action LIKE ? OR 
        item_name LIKE ? OR 
        original_instruction LIKE ? OR 
        generated_message LIKE ? OR
        notes LIKE ?
      ''',
      whereArgs: List.filled(6, searchPattern),
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => BusinessTask.fromMap(map)).toList();
  }

  Future<List<BusinessTask>> getTasksByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final maps = await db.query(
      'tasks',
      where: 'due_date = ? OR date(created_at) = ?',
      whereArgs: [dateStr, dateStr],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BusinessTask.fromMap(map)).toList();
  }

  Future<List<BusinessTask>> getTasksByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(end);
    final maps = await db.query(
      'tasks',
      where: 'due_date BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BusinessTask.fromMap(map)).toList();
  }

  Future<List<BusinessTask>> getPendingTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: "task_status != 'completed' AND task_status != 'cancelled'",
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BusinessTask.fromMap(map)).toList();
  }

  Future<List<BusinessTask>> getCompletedTasks() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      where: "task_status = 'completed'",
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BusinessTask.fromMap(map)).toList();
  }

  Future<double> getTotalPendingAmount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM tasks WHERE payment_status = 'pending'"
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<int> getTodayPendingCount() async {
    final db = await _dbHelper.database;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM tasks WHERE (due_date = ? OR date(created_at) = ?) AND task_status != 'completed' AND task_status != 'cancelled'",
      [todayStr, todayStr]
    );
    if (result.isNotEmpty && result.first['count'] != null) {
      return result.first['count'] as int;
    }
    return 0;
  }

  Future<List<BusinessTask>> getRecentTasks({int limit = 5}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tasks',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => BusinessTask.fromMap(map)).toList();
  }
}
