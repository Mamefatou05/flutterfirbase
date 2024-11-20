import 'package:get/get.dart';
import '../controllers/deposit_controller.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';

class DepositBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DepositController(
      authService: Get.find<AuthService>(),
      transactionService: Get.find<TransactionService>(),
    ));
  }
}