import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../data/models/user_model.dart';

class TransactionLimitController extends GetxController {
  final TransactionService _transactionService;
  final AuthService _authService;

  final searchController = TextEditingController();
  final isSearching = false.obs;
  final selectedClient = Rx<AppUser?>(null);
  final transactionData = Rx<Map<String, dynamic>?>(null);

  TransactionLimitController(this._transactionService, this._authService);

  Future<void> searchClient() async {
    if (searchController.text.isEmpty) return;

    try {
      isSearching.value = true;
      final client = await _authService.getUserByPhoneNumber(searchController.text);

      if (client == null) {
        Get.snackbar('Erreur', 'Client non trouvé');
        return;
      }

      selectedClient.value = client;
      await loadClientTransactionData();
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la recherche');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> loadClientTransactionData() async {
    if (selectedClient.value == null) return;

    try {
      final dailyTotal = await _transactionService.getDailyTransactionsTotal(
          selectedClient.value!.id
      );
      final monthlyTotal = await _transactionService.getMonthlyTransactionsTotal(
          selectedClient.value!.id
      );

      transactionData.value = {
        'dailyTotal': dailyTotal,
        'monthlyTotal': monthlyTotal,
        'dailyLimit': selectedClient.value!.transactionLimits.dailyLimit,
        'monthlyLimit': selectedClient.value!.transactionLimits.monthlyLimit,
      };
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les données');
    }
  }

  Future<void> updateLimits(double? dailyLimit, double? monthlyLimit) async {
    if (selectedClient.value == null) return;

    try {
      await _transactionService.updateUserTransactionLimits(
        userId: selectedClient.value!.id,
        dailyLimit: dailyLimit,
        monthlyLimit: monthlyLimit,
      );
      await loadClientTransactionData();
      Get.snackbar('Succès', 'Limites mises à jour avec succès');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour les limites');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
