import 'package:get/get.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/transaction_limit_model.dart';
import '../../../../data/models/user_model.dart';


class ProfileController extends GetxController {
  final AuthService authService;

  // Champs observables
  var isLoading = false.obs;
  var user = Rxn<AppUser>();

  ProfileController({required this.authService});

  // Charger les données de l'utilisateur actuel
  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      user.value = await authService.getCurrentUserData();
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le profil
  Future<bool> updateProfile({
    required String userId,
    required String nomComplet,
    required String numeroTelephone,
    String? email,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> updateData = {
        'nomComplet': nomComplet,
        'numeroTelephone': numeroTelephone,
        'role': Role.CLIENT.toString().split('.').last,
        'qrCodeUrl': numeroTelephone,
        'transactionLimits': TransactionLimits.defaultLimits().toJson(),
      };
      if (email != null && email.isNotEmpty) {
        updateData['email'] = email;
      }
      final success = await authService.updateUser(userId, updateData);

      if (success) {
        Get.snackbar('Succès', 'Profil mis à jour avec succès');
      } else {
        Get.snackbar('Erreur', 'Échec de la mise à jour du profil');
      }
      return success;
    } catch (e) {
      Get.snackbar('Erreur', 'Une erreur est survenue : $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
