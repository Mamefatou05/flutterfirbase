import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../controllers/transaction_limit_controller.dart';

class TransactionLimitBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<FirebaseService>(FirebaseService());
    Get.put<TransactionService>(TransactionService(Get.find<FirebaseService>()));
    Get.put<AuthService>(AuthService(Get.find<FirebaseService>()));

    // Controller
    Get.put<TransactionLimitController>(
      TransactionLimitController(
        Get.find<TransactionService>(),
        Get.find<AuthService>(),
      ),
    );
  }
}