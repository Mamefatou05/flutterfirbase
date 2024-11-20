import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/transaction_model.dart';
import 'firebase_service.dart';

class TransactionService {
  final FirebaseService _firebaseService;

  TransactionService(this._firebaseService);

  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _firebaseService.createDocument(
          'transactions',
          transaction.toJson()
      );
    } catch (e) {
      print('Erreur lors de la création de la transaction : $e');
      throw Exception('Erreur lors de la création de la transaction');
    }
  }

  Future<List<TransactionModel>> getUserTransactions(
      String userId, {
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
          .where((doc) => doc['timestamp'] != null) // Filtrer les documents avec timestamp
          .map((doc) {
        return TransactionModel.fromJson(doc);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des transactions : $e');
      throw Exception('Erreur lors de la récupération des transactions');
    }
  }

}

