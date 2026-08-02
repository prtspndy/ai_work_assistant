import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../models/business_task.dart';
import '../providers/task_provider.dart';
import 'whatsapp_message_screen.dart';

class EditTaskScreen extends StatefulWidget {
  final BusinessTask task;
  final bool isEditingExisting;

  const EditTaskScreen({
    super.key,
    required this.task,
    this.isEditingExisting = false,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _customerController;
  late TextEditingController _actionController;
  late TextEditingController _itemController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _amountController;
  late TextEditingController _nextActionController;
  late TextEditingController _notesController;

  late String _instructionType;
  late String _paymentStatus;
  late String _taskStatus;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;

    _customerController = TextEditingController(text: t.customerName ?? '');
    _actionController = TextEditingController(text: t.action ?? '');
    _itemController = TextEditingController(text: t.itemName ?? '');
    _quantityController = TextEditingController(text: t.quantity != null ? t.quantity.toString() : '');
    _unitController = TextEditingController(text: t.quantityUnit ?? '');
    _amountController = TextEditingController(text: t.amount != null ? t.amount.toString() : '');
    _nextActionController = TextEditingController(text: t.nextAction ?? '');
    _notesController = TextEditingController(text: t.notes ?? '');

    _instructionType = t.instructionType;
    _paymentStatus = t.paymentStatus;
    _taskStatus = t.taskStatus;
    _dueDate = t.dueDate ?? DateTime.now();

    if (t.dueTime != null && t.dueTime!.isNotEmpty) {
      final parts = t.dueTime!.split(':');
      if (parts.length >= 2) {
        _dueTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 10, minute: int.tryParse(parts[1]) ?? 0);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      final timeStr = _dueTime != null ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}' : null;

      final updatedTask = widget.task.copyWith(
        customerName: _customerController.text.trim().isEmpty ? null : _customerController.text.trim(),
        instructionType: _instructionType,
        action: _actionController.text.trim().isEmpty ? null : _actionController.text.trim(),
        itemName: _itemController.text.trim().isEmpty ? null : _itemController.text.trim(),
        quantity: double.tryParse(_quantityController.text.trim()),
        quantityUnit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()),
        dueDate: _dueDate,
        dueTime: timeStr,
        paymentStatus: _paymentStatus,
        taskStatus: _taskStatus,
        nextAction: _nextActionController.text.trim().isEmpty ? null : _nextActionController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      int savedId;
      if (widget.isEditingExisting && updatedTask.id != null) {
        await taskProvider.updateTask(updatedTask);
        savedId = updatedTask.id!;
      } else {
        savedId = await taskProvider.addTask(updatedTask);
      }

      final finalTask = updatedTask.copyWith(id: savedId);

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('saved_successfully')),
          backgroundColor: AppTheme.accentGreen,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WhatsAppMessageScreen(task: finalTask),
        ),
      );
    } catch (e) {
      debugPrint('Save task error: $e');
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving task: $e'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _actionController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _amountController.dispose();
    _nextActionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isLowConfidence = (widget.task.confidence ?? 1.0) < 0.60;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          loc.translate('edit_task'),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Low confidence warning
                if (isLowConfidence)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentOrange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.accentOrange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            loc.translate('low_confidence_warning'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Customer Name
                _buildSectionHeader(loc.translate('customer_name')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _customerController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'e.g. મનોજભાઈ / Manojbhai',
                  ),
                ),
                const SizedBox(height: 18),

                // Instruction Type & Action
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('instruction_type')),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: ['task', 'order', 'payment_reminder', 'delivery', 'customer_follow_up', 'other'].contains(_instructionType)
                                ? _instructionType
                                : 'order',
                            items: const [
                              DropdownMenuItem(value: 'order', child: Text('Order')),
                              DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                              DropdownMenuItem(value: 'payment_reminder', child: Text('Payment')),
                              DropdownMenuItem(value: 'customer_follow_up', child: Text('Follow-up')),
                              DropdownMenuItem(value: 'task', child: Text('Task')),
                              DropdownMenuItem(value: 'other', child: Text('Other')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _instructionType = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Action / Work
                _buildSectionHeader(loc.translate('action')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _actionController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.work_outline),
                    hintText: 'e.g. 25 box મોકલવા',
                  ),
                ),
                const SizedBox(height: 18),

                // Item & Quantity & Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('item_name')),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _itemController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('quantity')),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '25',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Amount (₹) & Unit
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('amount')),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.currency_rupee),
                              hintText: '12500',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('quantity_unit')),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              hintText: 'box / kg',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Date & Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('due_date')),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _dueDate != null ? DateFormat('dd MMM yyyy').format(_dueDate!) : 'Select Date',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('due_time')),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(
                                _dueTime != null ? _dueTime!.format(context) : 'Select Time',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Payment Status & Task Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('payment_status')),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: ['pending', 'paid', 'partial', 'not_applicable'].contains(_paymentStatus)
                                ? _paymentStatus
                                : 'pending',
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'paid', child: Text('Paid')),
                              DropdownMenuItem(value: 'partial', child: Text('Partial')),
                              DropdownMenuItem(value: 'not_applicable', child: Text('N/A')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _paymentStatus = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(loc.translate('task_status')),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: ['pending', 'in_progress', 'completed', 'cancelled'].contains(_taskStatus)
                                ? _taskStatus
                                : 'pending',
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                              DropdownMenuItem(value: 'completed', child: Text('Completed')),
                              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _taskStatus = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Next Action
                _buildSectionHeader(loc.translate('next_action')),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nextActionController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.next_plan_outlined),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveTask,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_isSaving ? 'Saving...' : loc.translate('save_task')),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF475569),
      ),
    );
  }
}
