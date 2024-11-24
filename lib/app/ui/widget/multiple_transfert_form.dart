import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assurez-vous d'importer GetX
import 'package:wavefirebase/app/ui/widget/receiver_field.dart';

import '../../../core/services/ContactService.dart';
import '../../modules/transaction/controllers/transaction_controller.dart';
import '../shared/custom_text_field.dart';

class MultipleTransferForm extends StatelessWidget {
  final TextEditingController amountController;
  final VoidCallback onAddReceiver;
  final VoidCallback onTransfer;
  final ContactService contactService;

  const MultipleTransferForm({
    Key? key,
    required this.amountController,
    required this.onAddReceiver,
    required this.onTransfer,
    required this.contactService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérez le contrôleur
    final TransactionController controller = Get.find();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: amountController,
              label: "Montant à envoyer",
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Utilisez Obx pour écouter les changements de la liste des contrôleurs
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.multiReceiverControllers.length,
              itemBuilder: (context, index) {
                return ReceiverField(
                  controller: controller.multiReceiverControllers[index],
                  index: index,
                  showRemoveButton: controller.multiReceiverControllers.length > 1,
                  onRemove: () => controller.removeReceiverField(index),
                  contactService: contactService,
                  onContactsSelected: (phones) => controller.updateSelectedPhoneNumbers(phones, index),
                );
              },
            )),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onAddReceiver,
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter un destinataire"),
                ),
                ElevatedButton(
                  onPressed: onTransfer,
                  child: const Text("Transférer"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}