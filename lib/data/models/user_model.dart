import 'package:wavefirebase/data/models/transaction_limit_model.dart';

import 'enums.dart';

class AppUser {
  final String id;
  final String nomComplet;
  final String numeroTelephone;
  final String email;
  final double balance;
  final Role role;
  final String? qrCodeUrl;
  final TransactionLimits transactionLimits;

  AppUser({
    required this.id,
    required this.nomComplet,
    required this.numeroTelephone,
    required this.email,
    required this.balance,
    required this.role,
    String? qrCodeUrl,
    TransactionLimits? transactionLimits,
  }) : qrCodeUrl = qrCodeUrl ?? numeroTelephone,
        transactionLimits = transactionLimits ?? TransactionLimits.defaultLimits();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomComplet': nomComplet,
      'numeroTelephone': numeroTelephone,
      'email': email,
      'balance': balance,
      'role': role.toString().split('.').last,
      'qrCodeUrl': qrCodeUrl,
      'transactionLimits': transactionLimits.toJson(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      nomComplet: json['nomComplet'],
      numeroTelephone: json['numeroTelephone'],
      email: json['email'],
      balance: json['balance'].toDouble(),
      role: Role.values.firstWhere(
            (e) => e.toString() == 'Role.${json['role']}',
      ),
      qrCodeUrl: json['qrCodeUrl'],
      transactionLimits: json['transactionLimits'] != null
          ? TransactionLimits.fromJson(json['transactionLimits'])
          : TransactionLimits.defaultLimits(),
    );
  }
}










