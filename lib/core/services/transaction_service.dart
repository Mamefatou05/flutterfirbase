import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/enums.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';
import 'firebase_service.dart';

class TransactionService {
  final FirebaseService _firebaseService;
  final Map<String, Timer> _transactionTimers = {};


  TransactionService(this._firebaseService) {
    // Démarrer l'écoute des transactions pour gérer isReversible
    _listenToTransactions();
  }


  Future<void> createTransaction(TransactionModel transaction) async {
    final isWithinLimit = await checkTransactionLimit(
        transaction.senderId,
        transaction.amount
    );

    if (!isWithinLimit) {
      throw Exception('Limite de transaction dépassée');
    }
    try {
      await _firebaseService.setDocument(
          'transactions',
          transaction.id,
          transaction.toJson()
      );
    } catch (e) {
      print('Erreur lors de la création de la transaction : $e');
      throw Exception('Erreur lors de la création de la transaction');
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId, {
    int limit = 10,
    TransactionModel? lastTransaction,
  }) async {
    try {
      // Récupérer les documents de transactions de Firebase
      final senderDocs = await _firebaseService.getDocumentsWhere(
        'transactions',
        'senderId',
        userId,
      );

      final receiverDocs = await _firebaseService.getDocumentsWhere(
        'transactions',
        'receiverId',
        userId,
      );

      final allDocs = [...senderDocs, ...receiverDocs];
      print('les transactions recuperé ');
      allDocs.forEach((doc) {
        final timestamp = doc['timestamp'];
        print('Document: $doc');
        print('Type de timestamp: ${timestamp.runtimeType}');
      });

      // Trier les transactions par date
      allDocs.sort((a, b) {
        // Vérifiez si le timestamp existe avant de le comparer
        final timestampA = a['timestamp'];
        final timestampB = b['timestamp'];

        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1;
        if (timestampB == null) return -1;

        return (timestampB as Timestamp).compareTo(timestampA as Timestamp);
      });

      // Mapper les documents en objets TransactionModel, en ignorant ceux sans timestamp
      return allDocs
          .where((doc) =>
      doc['timestamp'] != null) // Filtrer les documents avec timestamp
          .map((doc) {
        return TransactionModel.fromJson(doc);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des transactions : $e');
      throw Exception('Erreur lors de la récupération des transactions');
    }
  }

  Future<bool> cancelTransaction(TransactionModel transaction,
      AppUser currentUser) async {
    try {
      print('debut de l\'anulation de la transaction');
      // Vérifier si la transaction peut être annulée
      if (!transaction.canBeReversed()) {
        throw Exception('Transaction ne peut pas être annulée');
      }

      await FirebaseFirestore.instance.runTransaction((
          firestoreTransaction) async {
        // Annuler la transaction côté expéditeur
        await _firebaseService.updateDocument(
            'users',
            transaction.senderId,
            {'balance': FieldValue.increment(transaction.amount)}
        );

        // Annuler la transaction côté receveur
        await _firebaseService.updateDocument(
            'users',
            transaction.receiverId,
            {'balance': FieldValue.increment(-transaction.amount)}
        );

        print('Erreur lors de l\'annulation de la transaction : ');
        print('Transaction annulée avec succès');

        // Mettre à jour le statut de la transaction
        await _firebaseService.updateDocument(
            'transactions',
            transaction.id,
            {
              'status': 'CANCELLED',
              'isReversible': false
            }
        );
      });

      print('Transaction annulééé: ' + transaction.id);

      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation de la transaction : $e');
      throw Exception('Impossible d\'annuler la transaction');
    }
  }

  // Méthode pour filtrer les transactions
  Future<List<TransactionModel>> filterTransactions({
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Récupérer toutes les transactions de l'utilisateur
      final transactions = await getUserTransactions(userId ?? '');

      // Appliquer les filtres
      return transactions.where((transaction) {
        bool matchesType = type == null || transaction.type == type;
        bool matchesStatus = status == null || transaction.status == status;
        bool matchesStartDate = startDate == null ||
            transaction.timestamp.toDate().isAfter(startDate);
        bool matchesEndDate = endDate == null ||
            transaction.timestamp.toDate().isBefore(endDate);

        return matchesType && matchesStatus && matchesStartDate &&
            matchesEndDate;
      }).toList();
    } catch (e) {
      print('Erreur lors du filtrage des transactions : $e');
      throw Exception('Impossible de filtrer les transactions');
    }
  }

  void _listenToTransactions() {
    FirebaseFirestore.instance
        .collection('transactions')
        .where('isReversible', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromJson(doc.data());
        final now = DateTime.now();
        final transactionTime = transaction.timestamp.toDate();
        final thirtyMinutesLater = transactionTime.add(Duration(minutes: 30));

        if (now.isAfter(thirtyMinutesLater)) {
          // Mettre à jour isReversible à false après 30 minutes
          _firebaseService.updateDocument(
              'transactions',
              transaction.id,
              {'isReversible': false}
          );
        } else {
          // Programmer la mise à jour pour plus tard
          _setReversibleTimer(transaction.id, thirtyMinutesLater);
        }
      }
    });
  }

  void _setReversibleTimer(String transactionId, DateTime updateTime) {
    // Annuler le timer existant s'il y en a un
    _transactionTimers[transactionId]?.cancel();

    final duration = updateTime.difference(DateTime.now());
    _transactionTimers[transactionId] = Timer(duration, () {
      _firebaseService.updateDocument(
          'transactions',
          transactionId,
          {'isReversible': false}
      );
      _transactionTimers.remove(transactionId);
    });
  }

  Future<bool> checkTransactionLimit(String userId,
      double transactionAmount) async {
    try {
      final user = await _firebaseService.getDocumentById('users', userId);
      final appUser = AppUser.fromJson(user!);

      // Wait for both totals to resolve
      final double dailyTotal = await getDailyTransactionsTotal(userId);
      final double monthlyTotal = await getMonthlyTransactionsTotal(userId);

      return (dailyTotal + transactionAmount <=
          appUser.transactionLimits.dailyLimit) &&
          (monthlyTotal + transactionAmount <=
              appUser.transactionLimits.monthlyLimit);
    } catch (e) {
      throw Exception('Erreur lors de la vérification des limites');
    }
  }

  Future<double> getDailyTransactionsTotal(String userId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final transactions = await filterTransactions(
        userId: userId,
        startDate: todayStart,
        type: TransactionType.TRANSFERT,
        status: TransactionStatus.COMPLETED
    );

    return transactions.fold<double>(
        0.0, (sum, transaction) => sum + transaction.amount);
  }

  Future<double> getMonthlyTransactionsTotal(String userId) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final transactions = await filterTransactions(
        userId: userId,
        startDate: monthStart,
        type: TransactionType.TRANSFERT,
        status: TransactionStatus.COMPLETED
    );

    return transactions.fold<double>(
        0.0, (sum, transaction) => sum + transaction.amount);
  }

  Future<void> updateUserTransactionLimits({
    required String userId,
    double? dailyLimit,
    double? monthlyLimit,
  }) async {
    try {
      final user = await _firebaseService.getDocumentById('users', userId);
      final appUser = AppUser.fromJson(user!);

      final updates = {
        'transactionLimits': {
          'dailyLimit': dailyLimit ?? appUser.transactionLimits.dailyLimit,
          'monthlyLimit': monthlyLimit ??
              appUser.transactionLimits.monthlyLimit,
        }
      };

      await _firebaseService.updateDocument('users', userId, updates);
    } catch (e) {
      throw Exception('Impossible de mettre à jour les limites');
    }
  }
}