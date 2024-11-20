import 'package:get/get.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FirebaseService());
    Get.lazyPut(() => AuthService(Get.find<FirebaseService>()));
    Get.lazyPut(() => AuthController(Get.find<AuthService>()));
  }
}