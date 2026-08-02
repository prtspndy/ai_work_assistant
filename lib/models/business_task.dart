import 'dart:convert';

class BusinessTask {
  final int? id;
  final String instructionType; // task, order, payment_reminder, delivery, customer_follow_up, other
  final String? customerName;
  final String? action;
  final String? itemName;
  final double? quantity;
  final String? quantityUnit;
  final double? amount;
  final String currency;
  final DateTime? dueDate;
  final String? dueTime;
  final String paymentStatus; // pending, paid, partial, not_applicable
  final String taskStatus; // pending, in_progress, completed, cancelled
  final String? nextAction;
  final String? notes;
  final String originalInstruction;
  final String recognizedText;
  final String generatedMessage;
  final String languageCode; // en, gu, hi
  final double? confidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessTask({
    this.id,
    required this.instructionType,
    this.customerName,
    this.action,
    this.itemName,
    this.quantity,
    this.quantityUnit,
    this.amount,
    this.currency = 'INR',
    this.dueDate,
    this.dueTime,
    this.paymentStatus = 'pending',
    this.taskStatus = 'pending',
    this.nextAction,
    this.notes,
    required this.originalInstruction,
    required this.recognizedText,
    required this.generatedMessage,
    required this.languageCode,
    this.confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  BusinessTask copyWith({
    int? id,
    String? instructionType,
    String? customerName,
    String? action,
    String? itemName,
    double? quantity,
    String? quantityUnit,
    double? amount,
    String? currency,
    DateTime? dueDate,
    String? dueTime,
    String? paymentStatus,
    String? taskStatus,
    String? nextAction,
    String? notes,
    String? originalInstruction,
    String? recognizedText,
    String? generatedMessage,
    String? languageCode,
    double? confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessTask(
      id: id ?? this.id,
      instructionType: instructionType ?? this.instructionType,
      customerName: customerName ?? this.customerName,
      action: action ?? this.action,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      taskStatus: taskStatus ?? this.taskStatus,
      nextAction: nextAction ?? this.nextAction,
      notes: notes ?? this.notes,
      originalInstruction: originalInstruction ?? this.originalInstruction,
      recognizedText: recognizedText ?? this.recognizedText,
      generatedMessage: generatedMessage ?? this.generatedMessage,
      languageCode: languageCode ?? this.languageCode,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

  // Safe parsing helper for Dates
  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is String) {
      try {
        return DateTime.parse(val);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Safe parsing helper for String or null
  static String? _parseNullableString(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    return str.isEmpty || str == 'null' ? null : str;
  }

  factory BusinessTask.fromJson(Map<String, dynamic> json, {required String rawSpeech, required String currentLang}) {
    final rawDateStr = json['due_date'];
    DateTime? parsedDueDate;
    if (rawDateStr != null && rawDateStr is String && rawDateStr.isNotEmpty && rawDateStr != 'null') {
      parsedDueDate = DateTime.tryParse(rawDateStr);
    }

    return BusinessTask(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      instructionType: _parseNullableString(json['instruction_type']) ?? 'task',
      customerName: _parseNullableString(json['customer_name']),
      action: _parseNullableString(json['action']),
      itemName: _parseNullableString(json['item_name']),
      quantity: _parseDouble(json['quantity']),
      quantityUnit: _parseNullableString(json['quantity_unit']),
      amount: _parseDouble(json['amount']),
      currency: _parseNullableString(json['currency']) ?? 'INR',
      dueDate: parsedDueDate,
      dueTime: _parseNullableString(json['due_time']),
      paymentStatus: _parseNullableString(json['payment_status']) ?? 'pending',
      taskStatus: _parseNullableString(json['task_status']) ?? 'pending',
      nextAction: _parseNullableString(json['next_action']),
      notes: _parseNullableString(json['notes']),
      originalInstruction: _parseNullableString(json['original_instruction']) ?? rawSpeech,
      recognizedText: rawSpeech,
      generatedMessage: _parseNullableString(json['generated_message']) ?? rawSpeech,
      languageCode: currentLang,
      confidence: _parseDouble(json['confidence']) ?? 0.85,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'instruction_type': instructionType,
      'customer_name': customerName,
      'action': action,
      'item_name': itemName,
      'quantity': quantity,
      'quantity_unit': quantityUnit,
      'amount': amount,
      'currency': currency,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'due_time': dueTime,
      'payment_status': paymentStatus,
      'task_status': taskStatus,
      'next_action': nextAction,
      'notes': notes,
      'original_instruction': originalInstruction,
      'recognized_text': recognizedText,
      'generated_message': generatedMessage,
      'language_code': languageCode,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BusinessTask.fromMap(Map<String, dynamic> map) {
    return BusinessTask(
      id: map['id'] as int?,
      instructionType: map['instruction_type'] as String? ?? 'task',
      customerName: map['customer_name'] as String?,
      action: map['action'] as String?,
      itemName: map['item_name'] as String?,
      quantity: map['quantity'] != null ? (map['quantity'] as num).toDouble() : null,
      quantityUnit: map['quantity_unit'] as String?,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      currency: map['currency'] as String? ?? 'INR',
      dueDate: _parseDate(map['due_date']),
      dueTime: map['due_time'] as String?,
      paymentStatus: map['payment_status'] as String? ?? 'pending',
      taskStatus: map['task_status'] as String? ?? 'pending',
      nextAction: map['next_action'] as String?,
      notes: map['notes'] as String?,
      originalInstruction: map['original_instruction'] as String? ?? '',
      recognizedText: map['recognized_text'] as String? ?? '',
      generatedMessage: map['generated_message'] as String? ?? '',
      languageCode: map['language_code'] as String? ?? 'en',
      confidence: map['confidence'] != null ? (map['confidence'] as num).toDouble() : null,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'instruction_type': instructionType,
      'customer_name': customerName,
      'action': action,
      'item_name': itemName,
      'quantity': quantity,
      'quantity_unit': quantityUnit,
      'amount': amount,
      'currency': currency,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'due_time': dueTime,
      'payment_status': paymentStatus,
      'task_status': taskStatus,
      'next_action': nextAction,
      'notes': notes,
      'original_instruction': originalInstruction,
      'recognized_text': recognizedText,
      'generated_message': generatedMessage,
      'language_code': languageCode,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
