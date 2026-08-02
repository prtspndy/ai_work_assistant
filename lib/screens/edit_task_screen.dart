import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EditTaskScreen extends StatefulWidget {
  final String customerName;
  final int quantity;
  final double amount;
  final void Function(String name, int qty, double amt) onSave;

  const EditTaskScreen({
    super.key,
    required this.customerName,
    required this.quantity,
    required this.amount,
    required this.onSave,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _amountController;
  
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customerName);
    _qtyController = TextEditingController(text: widget.quantity.toString());
    _amountController = TextEditingController(text: widget.amount.toInt().toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // Simulate saving delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      
      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      widget.onSave(
        _nameController.text,
        int.tryParse(_qtyController.text) ?? widget.quantity,
        double.tryParse(_amountController.text) ?? widget.amount,
      );

      // Show success briefly before popping
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'કાર્ય સુધારો',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.network(
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuDnnAFQzuJPksuCOdZZK84SQhgBRKYsPFAJ4UiGCzpoZXjmA_1tU64zfnFGTdPCw8oIrhDp2TkkgjgLFBlz8zela1ag9C_YFs_aqkhgY9jCQkbkaKeI-udd78X-cfdeE5mmMUcj0iF7Xi7En8P4Kjo4CWLm6KWRFlE8WbaWOk9swuJ_8jlktN0a9t1LW_t9tTBSWQ0R4MXa9KUB_i5Cz438CkET0qWXoFKtuB4ue00wdIvu3Qt1HCI",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppTheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      )
                    ],
                    border: Border.all(color: AppTheme.primary.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.edit_document, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Edit Task',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Transaction details for Order #4421',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'In Progress',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Oct 24, 2023',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      )
                    ],
                    border: Border.all(color: AppTheme.primary.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer name input
                      const Text(
                        'Customer / ગ્રાહક',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person, color: AppTheme.onSurfaceVariant),
                          hintText: 'ગ્રાહકનું નામ લખો',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 20),

                      // Quantity and Amount row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quantity / જથ્થો',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.inventory_2, color: AppTheme.onSurfaceVariant),
                                    hintText: '0',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? 'Qty' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Amount / રકમ (₹)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.payments, color: AppTheme.onSurfaceVariant),
                                    hintText: '0.00',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  validator: (value) => value == null || value.isEmpty ? 'Amount' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Context Warning Alert
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.surfaceContainerHighest.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info, color: AppTheme.primary, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'આ કાર્યને સુધારવાથી મનોજભાઈનું લેજર આપમેળે અપડેટ થશે.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: _isSaved
                                ? const Color(0xFF16A34A)
                                : (_isSaving ? Colors.transparent : null),
                            gradient: !_isSaved && !_isSaving ? AppTheme.skyGradient : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: _isSaving || _isSaved ? null : _submitData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSaving
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'સાચવી રહ્યું છે...',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : (_isSaved
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.check_circle, color: Colors.white, size: 24),
                                          SizedBox(width: 10),
                                          Text(
                                            'સફળતાપૂર્વક સચવાયેલ!',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.check_circle, size: 22),
                                          SizedBox(width: 8),
                                          Text(
                                            'સેવ કરો / Save Changes',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cancel
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
