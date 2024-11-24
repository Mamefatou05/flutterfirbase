import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

class ScheduledTransactionModel {
  final String id;
  final String senderId;
  final String receiverPhone;
  final double amount;
  final ScheduleFrequency frequency;
  final DateTime nextExecutionTime;
  final bool isActive;
  final DateTime createdAt;

  ScheduledTransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverPhone,
    required this.amount,
    required this.frequency,
    required this.nextExecutionTime,
    this.isActive = true,
    required this.createdAt,
  });

  factory ScheduledTransactionModel.fromJson(Map<String, dynamic> json) {
    return ScheduledTransactionModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverPhone: json['receiverPhone'],
      amount: json['amount'],
      frequency: ScheduleFrequency.values.firstWhere(
              (e) => e.toString() == json['frequency']
      ),
      nextExecutionTime: (json['nextExecutionTime'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverPhone': receiverPhone,
      'amount': amount,
      'frequency': frequency.toString(),
      'nextExecutionTime': Timestamp.fromDate(nextExecutionTime),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DateTime calculateNextExecutionTime() {
    DateTime next;
    switch (frequency) {
      case ScheduleFrequency.DAILY:
        next = nextExecutionTime.add(Duration(days: 1));
        break;
      case ScheduleFrequency.WEEKLY:
        next = nextExecutionTime.add(Duration(days: 7));
        break;
      case ScheduleFrequency.MONTHLY:
        next = DateTime(
          nextExecutionTime.year,
          nextExecutionTime.month + 1,
          nextExecutionTime.day,
          nextExecutionTime.hour,
          nextExecutionTime.minute,
        );
        break;
    }
    return next;
  }
}

