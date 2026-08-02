import 'package:flutter/material.dart';
import '../models/business_task.dart';
import '../repositories/task_repository.dart';

enum TaskFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<BusinessTask> _allTasks = [];
  List<BusinessTask> _filteredTasks = [];
  List<BusinessTask> _recentTasks = [];
  
  double _totalPendingAmount = 0.0;
  int _todayPendingCount = 0;
  bool _isLoading = false;
  
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;
  DateTime? _selectedDateFilter;

  List<BusinessTask> get tasks => _filteredTasks;
  List<BusinessTask> get recentTasks => _recentTasks;
  double get totalPendingAmount => _totalPendingAmount;
  int get todayPendingCount => _todayPendingCount;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TaskFilter get currentFilter => _currentFilter;
  DateTime? get selectedDateFilter => _selectedDateFilter;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTasks = await _repository.getAllTasks();
      _recentTasks = await _repository.getRecentTasks(limit: 5);
      _totalPendingAmount = await _repository.getTotalPendingAmount();
      _todayPendingCount = await _repository.getTodayPendingCount();
      
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading tasks from SQLite: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    List<BusinessTask> result = List.from(_allTasks);

    // Filter by status
    if (_currentFilter == TaskFilter.pending) {
      result = result.where((t) => t.taskStatus != 'completed' && t.taskStatus != 'cancelled').toList();
    } else if (_currentFilter == TaskFilter.completed) {
      result = result.where((t) => t.taskStatus == 'completed').toList();
    }

    // Filter by date if selected
    if (_selectedDateFilter != null) {
      final filterDateStr = _selectedDateFilter!.toIso8601String().split('T').first;
      result = result.where((t) {
        final dueStr = t.dueDate?.toIso8601String().split('T').first;
        final createdStr = t.createdAt.toIso8601String().split('T').first;
        return dueStr == filterDateStr || createdStr == filterDateStr;
      }).toList();
    }

    // Search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((t) {
        return (t.customerName?.toLowerCase().contains(q) ?? false) ||
            (t.action?.toLowerCase().contains(q) ?? false) ||
            (t.itemName?.toLowerCase().contains(q) ?? false) ||
            t.originalInstruction.toLowerCase().contains(q) ||
            t.generatedMessage.toLowerCase().contains(q) ||
            (t.notes?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    _filteredTasks = result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(TaskFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    _selectedDateFilter = date;
    _applyFilters();
    notifyListeners();
  }

  Future<int> addTask(BusinessTask task) async {
    final id = await _repository.insertTask(task);
    await loadTasks();
    return id;
  }

  Future<void> updateTask(BusinessTask task) async {
    await _repository.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    await loadTasks();
  }
}
