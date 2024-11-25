import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/scheduled_transaction_service.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/scheduled_transaction_model.dart';

class ScheduledTransactionController extends GetxController {
  final ScheduledTransactionService _scheduledService;
  final AuthService _authService;

  final isLoading = false.obs;
  final selectedSchedule = Rx<ScheduledTransactionModel?>(null);
  final schedules = <ScheduledTransactionModel>[].obs;

  ScheduledTransactionController({
    required ScheduledTransactionService scheduledService,
    required AuthService authService,
  })  : _scheduledService = scheduledService,
        _authService = authService;

  Future<void> createScheduledTransaction({
    required String receiverPhone,
    required double amount,
    required ScheduleFrequency frequency,
    required DateTime executionTime,
  }) async {
    try {
      isLoading.value = true;
      await _scheduledService.createScheduledTransaction(
        receiverPhone: receiverPhone,
        amount: amount,
        frequency: frequency,
        firstExecutionTime: executionTime,
      );

      Get.snackbar(
        'Succès',
        'Transaction planifiée créée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelScheduledTransaction(String scheduleId) async {
    try {
      isLoading.value = true;
      await _scheduledService.cancelScheduledTransaction(scheduleId);

      Get.snackbar(
        'Succès',
        'Planification annulée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
