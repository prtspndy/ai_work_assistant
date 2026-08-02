import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../models/business_task.dart';
import '../providers/task_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'edit_task_screen.dart';
import 'whatsapp_message_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  Future<void> _selectCalendarDate() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final picked = await showDatePicker(
      context: context,
      initialDate: taskProvider.selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    taskProvider.setDateFilter(picked);
  }

  String _getDateGroupHeader(DateTime date, AppLocalizations loc) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return loc.translate('today');
    } else if (targetDate == yesterday) {
      return loc.translate('yesterday');
    } else if (today.difference(targetDate).inDays < 7) {
      return loc.translate('earlier_this_week');
    } else if (today.difference(targetDate).inDays < 14) {
      return loc.translate('last_week');
    } else {
      return loc.translate('older');
    }
  }

  Map<String, List<BusinessTask>> _groupTasksByDate(List<BusinessTask> tasks, AppLocalizations loc) {
    final Map<String, List<BusinessTask>> grouped = {};
    for (var task in tasks) {
      final header = _getDateGroupHeader(task.createdAt, loc);
      if (!grouped.containsKey(header)) {
        grouped[header] = [];
      }
      grouped[header]!.add(task);
    }
    return grouped;
  }

  void _showTaskDetailSheet(BusinessTask task) {
    final loc = AppLocalizations.of(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.customerName ?? 'Task Details',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              _detailRow('Instruction:', task.originalInstruction),
              if (task.action != null) _detailRow('Action:', task.action!),
              if (task.amount != null) _detailRow('Amount:', '₹${task.amount}'),
              if (task.dueDate != null) _detailRow('Due Date:', DateFormat('dd MMM yyyy').format(task.dueDate!)),
              _detailRow('Task Status:', task.taskStatus),
              _detailRow('Payment Status:', task.paymentStatus),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditTaskScreen(task: task, isEditingExisting: true)),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WhatsAppMessageScreen(task: task)),
                        );
                      },
                      icon: const Icon(Icons.message_outlined, size: 18),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        final newStatus = task.taskStatus == 'completed' ? 'pending' : 'completed';
                        await taskProvider.updateTask(task.copyWith(taskStatus: newStatus));
                        if (mounted) Navigator.pop(context);
                      },
                      icon: Icon(task.taskStatus == 'completed' ? Icons.undo : Icons.check_circle, color: AppTheme.accentGreen),
                      label: Text(task.taskStatus == 'completed' ? 'Mark Pending' : 'Mark Completed', style: const TextStyle(color: AppTheme.accentGreen)),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(task.id!),
                    icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                    label: Text(loc.translate('delete'), style: const TextStyle(color: AppTheme.accentRed)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int taskId) {
    final loc = AppLocalizations.of(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.translate('delete_confirm_title')),
          content: Text(loc.translate('delete_confirm_msg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await taskProvider.deleteTask(taskId);
                nav.pop(); // Close dialog
                nav.pop(); // Close bottom sheet
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
              child: Text(loc.translate('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    final groupedTasks = _groupTasksByDate(taskProvider.tasks, loc);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          loc.translate('history'),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: taskProvider.selectedDateFilter != null ? AppTheme.primaryColor : const Color(0xFF0F172A),
            ),
            onPressed: _selectCalendarDate,
          ),
          if (taskProvider.selectedDateFilter != null)
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.accentRed),
              onPressed: () => taskProvider.setDateFilter(null),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Bar & Pending Balance Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => taskProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: loc.translate('search_placeholder'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                taskProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips & Pending Balance Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildFilterChip(loc.translate('filter_all'), TaskFilter.all, taskProvider),
                          const SizedBox(width: 6),
                          _buildFilterChip(loc.translate('filter_pending'), TaskFilter.pending, taskProvider),
                          const SizedBox(width: 6),
                          _buildFilterChip(loc.translate('filter_completed'), TaskFilter.completed, taskProvider),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currencyFormat.format(taskProvider.totalPendingAmount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // History List
            Expanded(
              child: taskProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : taskProvider.tasks.isEmpty
                      ? EmptyState(
                          message: loc.translate('no_history'),
                          icon: Icons.history_toggle_off,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: groupedTasks.keys.length,
                          itemBuilder: (context, index) {
                            final groupKey = groupedTasks.keys.elementAt(index);
                            final tasksInGroup = groupedTasks[groupKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                                  child: Text(
                                    groupKey,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                ...tasksInGroup.map(
                                  (t) => TaskCard(
                                    task: t,
                                    onTap: () => _showTaskDetailSheet(t),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskFilter filter, TaskProvider provider) {
    final isSelected = provider.currentFilter == filter;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (_) => provider.setStatusFilter(filter),
    );
  }
}
