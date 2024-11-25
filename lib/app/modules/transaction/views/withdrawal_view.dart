import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../ui/widget/AgentOperationView.dart';
import '../controllers/withdrawal_controller.dart';


class WithdrawalView extends GetView<WithdrawalController> {
  const WithdrawalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => AgentOperationView(
      title: 'Effectuer un retrait',
      subtitle: 'Entrez le numéro de téléphone du client',
      phoneController: controller.clientPhoneController,
      amountController: controller.amountController,
      onSearch: controller.searchClient,
      onSubmit: controller.performWithdrawal,
      selectedUser: controller.clientUser.value,
      isLoading: controller.isLoading.value,
      submitButtonText: 'Effectuer le retrait',
    ));
  }
}