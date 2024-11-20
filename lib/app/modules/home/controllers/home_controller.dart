import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/user_model.dart';


class HomeController extends GetxController {
  final AuthService _authService;
  final TransactionService _transactionService;

  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTransactions = false.obs;

  final RxBool isBalanceVisible = true.obs;
  final Rx<QRViewController?> qrController = Rx<QRViewController?>(null);
  final RxBool isScanning = false.obs;

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
  }

  void toggleScanning() {
    isScanning.value = !isScanning.value;
  }

  @override
  void onClose() {
    qrController.value?.dispose();
    super.onClose();
  }
  HomeController({
    required AuthService authService,
    required TransactionService transactionService,
  }) : _authService = authService,
        _transactionService = transactionService;

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    try {
      isLoading.value = true;
      final userData = await _authService.getCurrentUserData();
      if (userData != null) {
        currentUser.value = userData;
        fetchRecentTransactions();
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecentTransactions() async {
    if (currentUser.value == null) return;

    try {
      isLoadingTransactions.value = true;
      final transactions = await _transactionService.getUserTransactions(
          currentUser.value!.id
      );

      // Trier par date décroissante et limiter à 10
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      recentTransactions.value = transactions.take(10).toList();

    } catch (e) {
      print('Erreur lors de la récupération des transactions: $e');
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  void refreshData() {
    getCurrentUser();
  }
}

