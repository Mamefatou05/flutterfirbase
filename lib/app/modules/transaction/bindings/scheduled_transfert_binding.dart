import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/scheduled_transaction_service.dart';
import '../../../../core/services/transaction_service.dart';
import '../controllers/scheduled_transaction_controller.dart';

class ScheduledTransferBinding extends Bindings {
  @override
  void dependencies() {
    // Register AuthService and FirebaseService
    Get.lazyPut(() => AuthService(FirebaseService()));
    Get.lazyPut(() => TransactionService(FirebaseService()));
    Get.lazyPut(() => FirebaseService());

    // Register ScheduledTransactionService with all required dependencies
    Get.lazyPut(() => ScheduledTransactionService(
      firebaseService: Get.find<FirebaseService>(),
      transactionService: Get.find<TransactionService>(),
      authService: Get.find<AuthService>(),
    ));

    // Register ScheduledTransactionController with all required dependencies
    Get.lazyPut(() => ScheduledTransactionController(
      authService: Get.find<AuthService>(),
      scheduledService: Get.find<ScheduledTransactionService>(),
    ));
  }
}
