import 'package:get/get.dart';
import '../../../../core/services/ContactService.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../controllers/transaction_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService(FirebaseService()));
    Get.lazyPut(() => TransactionService(FirebaseService()));
    Get.lazyPut(() => ContactService());  // Register ContactService
    Get.lazyPut(() => TransactionController(
      authService: Get.find<AuthService>(),
      transactionService: Get.find<TransactionService>(),
    ));
  }
}
