import 'business_task.dart';

class BusinessInstruction {
  final String type; // task, order, payment_reminder, delivery, customer_followup, other
  final String? customerName;
  final String? task;
  final String? product;
  final double? quantity;
  final String? quantityUnit;
  final double? amount;
  final String currency;
  final String? date;
  final String? time;
  final bool paymentReminder;
  final String? deliveryInstruction;
  final String? followUpInstruction;
  final String? notes;
  final String? generatedMessage;
  final String originalInstruction;
  final double confidence;

  BusinessInstruction({
    required this.type,
    this.customerName,
    this.task,
    this.product,
    this.quantity,
    this.quantityUnit,
    this.amount,
    this.currency = 'INR',
    this.date,
    this.time,
    this.paymentReminder = false,
    this.deliveryInstruction,
    this.followUpInstruction,
    this.notes,
    this.generatedMessage,
    required this.originalInstruction,
    this.confidence = 0.85,
  });

  // Safe parsing helper for numbers
  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) {
      final cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  }

  // Safe parsing helper for boolean
  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final lower = val.trim().toLowerCase();
      return lower == 'true' || lower == 'yes' || lower == '1';
    }
    return false;
  }

  // Safe parsing helper for String or null
  static String? _parseNullableString(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'None') return null;
    return str;
  }

  factory BusinessInstruction.fromJson(Map<String, dynamic> json, {String? rawSpeech}) {
    final speech = rawSpeech ?? _parseNullableString(json['original_instruction']) ?? '';
    
    // Support aliases: 'type' or 'instruction_type'
    final rawType = _parseNullableString(json['type']) ?? 
                    _parseNullableString(json['instruction_type']) ?? 
                    'task';
    
    // Normalize type string
    String normalizedType = rawType.toLowerCase().replaceAll(' ', '_');
    if (normalizedType == 'customer_follow_up' || normalizedType == 'follow_up' || normalizedType == 'followup') {
      normalizedType = 'customer_followup';
    } else if (!['task', 'order', 'payment_reminder', 'delivery', 'customer_followup', 'other'].contains(normalizedType)) {
      normalizedType = 'task';
    }

    // Support payment_reminder as bool or payment_status string
    bool isPaymentReminder = _parseBool(json['payment_reminder']);
    final rawPaymentStatus = _parseNullableString(json['payment_status']);
    if (rawPaymentStatus == 'pending' || normalizedType == 'payment_reminder') {
      isPaymentReminder = true;
    }

    return BusinessInstruction(
      type: normalizedType,
      customerName: _parseNullableString(json['customer_name']),
      task: _parseNullableString(json['task']) ?? _parseNullableString(json['action']),
      product: _parseNullableString(json['product']) ?? _parseNullableString(json['item_name']),
      quantity: _parseDouble(json['quantity']),
      quantityUnit: _parseNullableString(json['quantity_unit']) ?? _parseNullableString(json['unit']),
      amount: _parseDouble(json['amount']),
      currency: _parseNullableString(json['currency']) ?? 'INR',
      date: _parseNullableString(json['date']) ?? _parseNullableString(json['due_date']),
      time: _parseNullableString(json['time']) ?? _parseNullableString(json['due_time']),
      paymentReminder: isPaymentReminder,
      deliveryInstruction: _parseNullableString(json['delivery_instruction']),
      followUpInstruction: _parseNullableString(json['follow_up_instruction']),
      notes: _parseNullableString(json['notes']),
      generatedMessage: _parseNullableString(json['generated_message']),
      originalInstruction: speech,
      confidence: _parseDouble(json['confidence']) ?? 0.85,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'customer_name': customerName,
      'task': task,
      'product': product,
      'quantity': quantity,
      'quantity_unit': quantityUnit,
      'amount': amount,
      'currency': currency,
      'date': date,
      'time': time,
      'payment_reminder': paymentReminder,
      'delivery_instruction': deliveryInstruction,
      'follow_up_instruction': followUpInstruction,
      'notes': notes,
      'generated_message': generatedMessage,
      'original_instruction': originalInstruction,
      'confidence': confidence,
    };
  }

  /// Converts BusinessInstruction to BusinessTask for SQLite persistence
  BusinessTask toBusinessTask({required String currentLang}) {
    DateTime? parsedDate;
    if (date != null && date!.isNotEmpty) {
      if (date!.toLowerCase() == 'today' || date!.toLowerCase() == 'aaje') {
        parsedDate = DateTime.now();
      } else if (date!.toLowerCase() == 'tomorrow' || date!.toLowerCase() == 'kale') {
        parsedDate = DateTime.now().add(const Duration(days: 1));
      } else {
        parsedDate = DateTime.tryParse(date!);
      }
    }

    final dbInstructionType = (type == 'customer_followup') ? 'customer_follow_up' : type;

    return BusinessTask(
      instructionType: dbInstructionType,
      customerName: customerName,
      action: task,
      itemName: product,
      quantity: quantity,
      quantityUnit: quantityUnit,
      amount: amount,
      currency: currency,
      dueDate: parsedDate,
      dueTime: time,
      paymentStatus: paymentReminder ? 'pending' : 'not_applicable',
      taskStatus: 'pending',
      nextAction: followUpInstruction ?? deliveryInstruction,
      notes: notes,
      originalInstruction: originalInstruction,
      recognizedText: originalInstruction,
      generatedMessage: generatedMessage ?? originalInstruction,
      languageCode: currentLang,
      confidence: confidence,
    );
  }
}
