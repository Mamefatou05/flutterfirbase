import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wavefirebase/core/services/transaction_service.dart';

import '../../data/models/enums.dart';
import '../../data/models/scheduled_transaction_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

class ScheduledTransactionService {
  final FirebaseService _firebaseService;
  final TransactionService _transactionService;
  final AuthService _authService;
  Timer? _schedulerTimer;

  ScheduledTransactionService({
    required FirebaseService firebaseService,
    required TransactionService transactionService,
    required AuthService authService,
  })  : _firebaseService = firebaseService,
        _transactionService = transactionService,
        _authService = authService {
    _startScheduler();
  }

  void _startScheduler() {
    // Vérifier toutes les minutes
    _schedulerTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkAndExecuteScheduledTransactions();
    });
  }

  Future<void> _checkAndExecuteScheduledTransactions() async {
    try {
      final now = DateTime.now();
      // Récupérer toutes les transactions planifiées actives
      final scheduledTransactions = await _firebaseService.getDocumentsWhere(
        'scheduled_transactions',
        'isActive',
        true,
      );

      for (var doc in scheduledTransactions) {
        final scheduled = ScheduledTransactionModel.fromJson(doc);

        if (scheduled.nextExecutionTime.isBefore(now)) {
          await _executeScheduledTransaction(scheduled);
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des transactions planifiées : $e');
    }
  }

  Future<void> _executeScheduledTransaction(
      ScheduledTransactionModel scheduled
      ) async {
    try {
      // Vérifier le solde de l'expéditeur
      final sender = await _authService.getUserDetails(scheduled.senderId);
      if (sender == null) {
        throw Exception('Expéditeur non trouvé');
      }

      final senderUser = AppUser.fromJson(sender);
      if (senderUser.balance < scheduled.amount) {
        throw Exception('Solde insuffisant');
      }

      // Récupérer le destinataire
      final receiver = await _authService.getUserByPhoneNumber(
          scheduled.receiverPhone
      );
      if (receiver == null) {
        throw Exception('Destinataire non trouvé');
      }

      // Créer la transaction
      final transactionId = FirebaseFirestore.instance
          .collection('transactions')
          .doc()
          .id;

      final transaction = TransactionModel(
        id: transactionId,
        senderId: scheduled.senderId,
        receiverId: receiver.id,
        amount: scheduled.amount,
        type: TransactionType.SCHEDULED_TRANSFER,
        status: TransactionStatus.COMPLETED,
        timestamp: Timestamp.now(),
        isReversible: false, // Les transactions planifiées ne sont pas annulables
      );

      // Exécuter la transaction
      await _transactionService.createTransaction(transaction);

      // Mettre à jour la prochaine date d'exécution
      final nextExecution = scheduled.calculateNextExecutionTime();
      await _firebaseService.updateDocument(
          'scheduled_transactions',
          scheduled.id,
          {'nextExecutionTime': Timestamp.fromDate(nextExecution)}
      );

    } catch (e) {
      print('Erreur lors de l\'exécution de la transaction planifiée : $e');
      // Vous pouvez ajouter une notification à l'utilisateur ici
    }
  }

  Future<void> createScheduledTransaction({
    required String receiverPhone,
    required double amount,
    required ScheduleFrequency frequency,
    required DateTime firstExecutionTime,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUserData();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final scheduledId = FirebaseFirestore.instance
          .collection('scheduled_transactions')
          .doc()
          .id;

      final scheduled = ScheduledTransactionModel(
        id: scheduledId,
        senderId: currentUser.id,
        receiverPhone: receiverPhone,
        amount: amount,
        frequency: frequency,
        nextExecutionTime: firstExecutionTime,
        createdAt: DateTime.now(),
      );

      await _firebaseService.setDocument(
        'scheduled_transactions',
        scheduledId,
        scheduled.toJson(),
      );
    } catch (e) {
      print('Erreur lors de la création de la transaction planifiée : $e');
      rethrow;
    }
  }

  Future<void> cancelScheduledTransaction(String scheduleId) async {
    try {
      await _firebaseService.updateDocument(
          'scheduled_transactions',
          scheduleId,
          {'isActive': false}
      );
    } catch (e) {
      print('Erreur lors de l\'annulation de la transaction planifiée : $e');
      rethrow;
    }
  }

  void dispose() {
    _schedulerTimer?.cancel();
  }
}
