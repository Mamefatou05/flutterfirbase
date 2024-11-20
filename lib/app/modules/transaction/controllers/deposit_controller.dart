import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/user_model.dart';

class DepositController extends GetxController {
  final TransactionService _transactionService;
  final AuthService _authService;

  DepositController({
    required AuthService authService,
    required TransactionService transactionService,
  })  : _authService = authService,
        _transactionService = transactionService;

  final clientPhoneController = TextEditingController();
  final amountController = TextEditingController();
  final isLoading = false.obs;
  final clientUser = Rxn<AppUser>();

  Future<void> searchClient() async {
    if (clientPhoneController.text.isEmpty) return;

    try {
      isLoading.value = true;
      final user = await _authService.getUserByPhoneNumber(clientPhoneController.text);

      if (user == null) {
        Get.snackbar(
          'Erreur',
          'Client non trouvé',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (user.role != Role.CLIENT) {
        Get.snackbar(
          'Erreur',
          'Ce numéro n\'appartient pas à un client',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      clientUser.value = user;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performDeposit() async {
    try {
      isLoading.value = true;
      final amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        throw Exception('Montant invalide');
      }

      if (clientUser.value == null) {
        throw Exception('Veuillez d\'abord rechercher un client');
      }

      final distributor = await _authService.getCurrentUserData();
      if (distributor == null) {
        throw Exception('Distributeur non connecté');
      }

      if (distributor.role != Role.DISTRIBUTEUR) {
        throw Exception('Vous n\'êtes pas autorisé à effectuer des dépôts');
      }

      if (distributor.balance < amount) {
        throw Exception('Solde insuffisant pour effectuer ce dépôt');
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final transactionId = FirebaseFirestore.instance.collection('transactions').doc().id;

        final transactionModel = TransactionModel(
          id: transactionId,
          senderId: distributor.id,
          receiverId: clientUser.value!.id,
          amount: amount,
          type: TransactionType.DEPOT,
          status: TransactionStatus.COMPLETED,
          timestamp: Timestamp.now(),
        );

        // Mettre à jour le solde du distributeur
        await _authService.updateUser(
          distributor.id,
          {'balance': FieldValue.increment(-amount)},
        );

        // Mettre à jour le solde du client
        await _authService.updateUser(
          clientUser.value!.id,
          {'balance': FieldValue.increment(amount)},
        );

        // Créer la transaction
        await _transactionService.createTransaction(transactionModel);
      });

      Get.snackbar(
        'Succès',
        'Dépôt effectué avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm();
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    clientPhoneController.clear();
    amountController.clear();
    clientUser.value = null;
  }

  @override
  void onClose() {
    clientPhoneController.dispose();
    amountController.dispose();
    super.onClose();
  }
}