import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../../../ui/widget/AgentOperationView.dart';
import '../controllers/deposit_controller.dart';

class DepositView extends GetView<DepositController> {
  const DepositView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => AgentOperationView(
      title: 'Effectuer un dépôt',
      subtitle: 'Entrez le numéro de téléphone du client',
      phoneController: controller.clientPhoneController,
      amountController: controller.amountController,
      onSearch: controller.searchClient,
      onSubmit: controller.performDeposit,
      selectedUser: controller.clientUser.value,
      isLoading: controller.isLoading.value,
      submitButtonText: 'Effectuer le dépôt',
    ));
  }
}