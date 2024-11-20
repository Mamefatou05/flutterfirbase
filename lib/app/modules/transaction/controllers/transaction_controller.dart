import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/transaction_model.dart' as transaction_model;
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/user_model.dart';


class TransactionController extends GetxController {
  final TransactionService _transactionService;
  final AuthService _authService;

  TransactionController({
    required AuthService authService,
    required TransactionService transactionService,
  })
      : _authService = authService,
        _transactionService = transactionService;

  final receiverController = TextEditingController();
  final amountController = TextEditingController();
  final amountReceivedController = TextEditingController();
  final multiReceiverControllers = <TextEditingController>[].obs;
  final List<String> receiverPhones = [];
  final selectedPhoneNumbers = <String>[].obs;


  final isLoading = false.obs;

  void syncAmounts({bool isSend = true}) {
    final amount = double.tryParse(isSend
        ? amountController.text
        : amountReceivedController.text);

    if (amount == null) return;

    if (isSend) {
      final received = amount - (amount * 0.01);
      amountReceivedController.text = received.toStringAsFixed(2);
    } else {
      final send = amount / 0.99;
      amountController.text = send.toStringAsFixed(2);
    }
  }


  void addReceiverField() {
    multiReceiverControllers.add(TextEditingController());

    update(); // Pour mettre à jour l'UI
  }

  void removeReceiverField(int index) {
    if (index < multiReceiverControllers.length) {
      multiReceiverControllers.removeAt(index);
      update(); // Pour mettre à jour l'UI
    }
  }
  // Méthode pour mettre à jour les numéros sélectionnés
  void updateSelectedPhoneNumbers(List<String> phoneNumbers, int index) {
    if (index >= 0 && index < multiReceiverControllers.length) {
      multiReceiverControllers[index].text = phoneNumbers.join(', ');
      // Mettre à jour la liste des numéros sélectionnés
      selectedPhoneNumbers.value = getUniquePhoneNumbers();
    }

  }
  // Méthode pour obtenir tous les numéros uniques
  List<String> getUniquePhoneNumbers() {
    Set<String> uniqueNumbers = {};
    for (var controller in multiReceiverControllers) {
      if (controller.text.isNotEmpty) {
        // Séparer les numéros s'ils sont séparés par des virgules
        controller.text.split(',').forEach((number) {
          String trimmedNumber = number.trim();
          if (trimmedNumber.isNotEmpty) {
            uniqueNumbers.add(trimmedNumber);
          }
        });
      }
    }
    return uniqueNumbers.toList();
  }

  Future<Map<String, AppUser>> _validateTransfer(double amount, List<String> receiverPhones) async {
    if (receiverPhones.isEmpty || amount <= 0) {
      throw Exception('Veuillez remplir tous les champs correctement.');
    }

    final currentUser = await _authService.getCurrentUserData();
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    final totalAmount = amount * receiverPhones.length;
    if (currentUser.balance < totalAmount) {
      throw Exception('Solde insuffisant (${totalAmount.toStringAsFixed(2)} requis)');
    }

    Map<String, AppUser> validReceivers = {};
    List<String> invalidPhones = [];

    for (var phone in receiverPhones) {
      final receiver = await _authService.getUserByPhoneNumber(phone);
      if (receiver != null) {
        validReceivers[phone] = receiver;
      } else {
        invalidPhones.add(phone);
      }
    }

    if (invalidPhones.isNotEmpty) {
      throw Exception('Numéros invalides : ${invalidPhones.join(", ")}');
    }

    return validReceivers;
  }

  Future<void> _processTransfer(AppUser sender, Map<String, AppUser> receivers, double amount) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      for (var receiver in receivers.values) {
        final transactionId = FirebaseFirestore.instance.collection('transactions').doc().id;

        final transactionModel = TransactionModel(
          id: transactionId,
          senderId: sender.id,
          receiverId: receiver.id,
          amount: amount,
          type: TransactionType.TRANSFERT,
          status: TransactionStatus.COMPLETED,
          timestamp: Timestamp.now(),
        );

        await _authService.updateUser(
            sender.id,
            {'balance': FieldValue.increment(-amount)}
        );

        await _authService.updateUser(
            receiver.id,
            {'balance': FieldValue.increment(amount)}
        );

        await _transactionService.createTransaction(transactionModel);
      }
    });
  }

  Future<void> performTransfer({bool isMultiple = false}) async {
    try {
      isLoading.value = true;
      final amount = double.tryParse(amountController.text);
      if (amount == null) throw Exception('Montant invalide');

      final phones = isMultiple ? getUniquePhoneNumbers() : [receiverController.text];
      final receivers = await _validateTransfer(amount, phones);

      final currentUser = await _authService.getCurrentUserData();
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      await _processTransfer(currentUser, receivers, amount);

      Get.snackbar(
        'Succès',
        isMultiple ? 'Transferts multiples effectués' : 'Transfert effectué',
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm(isMultiple);

    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm(bool isMultiple) {
    amountController.clear();
    if (isMultiple) {
      multiReceiverControllers.clear();
      selectedPhoneNumbers.clear();
      addReceiverField();
    } else {
      receiverController.clear();
    }
  }

  @override
  void onInit() {
    super.onInit();
    addReceiverField();
  }

  @override
  void onClose() {
    amountController.dispose();
    for (var controller in multiReceiverControllers) {
      controller.dispose();
    }
    super.onClose();
  }


}

