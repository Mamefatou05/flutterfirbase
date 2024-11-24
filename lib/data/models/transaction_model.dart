import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final Timestamp timestamp; // Directement de type Timestamp
  final TransactionType type;
  final TransactionStatus status;
  final bool isReversible; // Nouveau champ


  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.type,
    required this.status,
    this.isReversible = true,

  });

  // Conversion en JSON pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': timestamp, // Pas besoin de conversion
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'isReversible': isReversible, // Pas besoin de conversion
    };
  }

  // Création d'un modèle à partir de JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      amount: _parseAmount(json['amount']),
      timestamp: json['timestamp'] as Timestamp, // Pas de conversion nécessaire
      type: _parseTransactionType(json['type']),
      status: _parseTransactionStatus(json['status']),
      isReversible: json['isReversible'] ?? true,

    );
  }

  // Méthode pour analyser le montant
  static double _parseAmount(dynamic amount) {
    if (amount is String) {
      return double.tryParse(amount) ?? 0.0;
    } else if (amount is double) {
      return amount;
    }
    return 0.0;
  }

  // Méthode pour analyser le type de transaction
  static TransactionType _parseTransactionType(String? type) {
    if (type != null) {
      return TransactionType.values.firstWhere(
            (e) => e.toString() == 'TransactionType.$type',
        orElse: () => TransactionType.UNKNOWN,
      );
    }
    return TransactionType.UNKNOWN;
  }

  // Méthode pour analyser le statut de transaction
  static TransactionStatus _parseTransactionStatus(String? status) {
    if (status != null) {
      return TransactionStatus.values.firstWhere(
            (e) => e.toString() == 'TransactionStatus.$status',
        orElse: () => TransactionStatus.UNKNOWN,
      );
    }
    return TransactionStatus.UNKNOWN;
  }

  // Méthode pour vérifier si la transaction peut être annulée
  bool canBeReversed() {
    final now = Timestamp.now();
    final thirtyMinutesAgo = Timestamp.fromDate(
        DateTime.now().subtract(Duration(minutes: 30))
    );

    return isReversible &&
        status == TransactionStatus.COMPLETED &&
        timestamp.compareTo(thirtyMinutesAgo) > 0;
  }
}
