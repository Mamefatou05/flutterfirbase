import 'package:get/get.dart';
import '../controllers/deposit_controller.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../controllers/withdrawal_controller.dart';

class WithdrawBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WithdrawalController(
      authService: Get.find<AuthService>(),
      transactionService: Get.find<TransactionService>(),
    ));
  }
}