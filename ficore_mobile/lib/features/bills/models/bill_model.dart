import 'package:json_annotation/json_annotation.dart';

part 'bill_model.g.dart';

@JsonSerializable()
class Bill {
  @JsonKey(name: '_id')
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'session_id')
  final String? sessionId;
  
  @JsonKey(name: 'bill_name')
  final String billName;
  
  final double amount;
  
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  
  final String frequency;
  final String category;
  final String status;
  
  @JsonKey(name: 'send_notifications')
  final bool sendNotifications;
  
  @JsonKey(name: 'send_email')
  final bool sendEmail;
  
  @JsonKey(name: 'send_sms')
  final bool sendSms;
  
  @JsonKey(name: 'send_whatsapp')
  final bool sendWhatsapp;
  
  @JsonKey(name: 'reminder_days')
  final int? reminderDays;
  
  @JsonKey(name: 'user_email')
  final String? userEmail;
  
  @JsonKey(name: 'user_phone')
  final String? userPhone;
  
  @JsonKey(name: 'first_name')
  final String? firstName;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const Bill({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.billName,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    required this.category,
    required this.status,
    required this.sendNotifications,
    required this.sendEmail,
    required this.sendSms,
    required this.sendWhatsapp,
    this.reminderDays,
    this.userEmail,
    this.userPhone,
    this.firstName,
    this.createdAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
  
  Map<String, dynamic> toJson() => _$BillToJson(this);

  // Computed properties
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue' || (isPending && dueDate.isBefore(DateTime.now()));
  bool get isRecurring => frequency != 'one-time';
  
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }
  
  bool get isDueToday => daysUntilDue == 0;
  bool get isDueTomorrow => daysUntilDue == 1;
  bool get isDueThisWeek => daysUntilDue >= 0 && daysUntilDue <= 7;

  Bill copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? billName,
    double? amount,
    DateTime? dueDate,
    String? frequency,
    String? category,
    String? status,
    bool? sendNotifications,
    bool? sendEmail,
    bool? sendSms,
    bool? sendWhatsapp,
    int? reminderDays,
    String? userEmail,
    String? userPhone,
    String? firstName,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      billName: billName ?? this.billName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      status: status ?? this.status,
      sendNotifications: sendNotifications ?? this.sendNotifications,
      sendEmail: sendEmail ?? this.sendEmail,
      sendSms: sendSms ?? this.sendSms,
      sendWhatsapp: sendWhatsapp ?? this.sendWhatsapp,
      reminderDays: reminderDays ?? this.reminderDays,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      firstName: firstName ?? this.firstName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Bill(id: $id, billName: $billName, amount: $amount, dueDate: $dueDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}