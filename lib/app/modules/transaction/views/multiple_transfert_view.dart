import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../core/services/ContactService.dart';
import '../../../ui/shared/custom_footer.dart';
import '../../../ui/widget/multiple_transfert_form.dart';
import '../controllers/transaction_controller.dart';

class MultipleTransferView extends StatelessWidget {
  const MultipleTransferView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.find();
    final ContactService contactService = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfert Multiple"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return MultipleTransferForm(
          amountController: controller.amountController,
          onAddReceiver: controller.addReceiverField,
          onTransfer: () => controller.performTransfer(isMultiple: true),
          contactService: contactService,
        );
      }),
      bottomNavigationBar: const CustomFooter(
        currentRoute: "/transaction/multiple",
      ),
    );
  }
}
