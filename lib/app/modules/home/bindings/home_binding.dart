import 'package:get/get.dart';
import '../../../../core/services/firebase_service.dart';
import '../controllers/home_controller.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/transaction_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService(FirebaseService()));
    Get.lazyPut(() => TransactionService(FirebaseService()));
    Get.lazyPut(() => HomeController(
      authService: Get.find<AuthService>(),
      transactionService: Get.find<TransactionService>(),
    ));
  }
}
