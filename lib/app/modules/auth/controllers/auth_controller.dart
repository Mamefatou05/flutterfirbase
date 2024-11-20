import 'package:get/get.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../data/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isLoading = false.obs;

  AuthController(this._authService);

  @override
  void onInit() {
    super.onInit();
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    try {
      final user = await _authService.getCurrentUserData();
      currentUser.value = user;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nomComplet,
    required String numeroTelephone,
  }) async {
    try {
      isLoading.value = true;
      final user = await _authService.registerUser(
        email: email,
        password: password,
        nomComplet: nomComplet,
        numeroTelephone: numeroTelephone,
      );

      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'inscription: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.loginWithEmail(email, password);
      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la connexion: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await _authService.loginWithGoogle();
      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la connexion Google: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startPhoneLogin(String phoneNumber) async {
    try {
      isLoading.value = true;
      await _authService.startPhoneLogin(
        phoneNumber,
            (verificationId) {
          Get.toNamed('/verify-code');
        },
            (error) {
          Get.snackbar('Erreur', error);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPhoneCode(String code) async {
    try {
      isLoading.value = true;
      final user = await _authService.verifyPhoneCode(code);
      if (user != null) {
        currentUser.value = user;
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Code incorrect: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la déconnexion: ${e.toString()}');
    }
  }
}