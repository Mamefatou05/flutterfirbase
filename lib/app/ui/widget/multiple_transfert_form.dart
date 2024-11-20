import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wavefirebase/app/ui/widget/receiver_field.dart';

import '../../../core/services/ContactService.dart';
import '../shared/custom_text_field.dart';

class MultipleTransferForm extends StatelessWidget {
  final TextEditingController amountController;
  final List<TextEditingController> multiReceiverControllers;
  final void Function(int) onRemoveReceiver;
  final VoidCallback onAddReceiver;
  final VoidCallback onTransfer;
  final void Function(List<String>, int) onContactsSelected;
  final ContactService contactService;

  const MultipleTransferForm({
    Key? key,
    required this.amountController,
    required this.multiReceiverControllers,
    required this.onRemoveReceiver,
    required this.onAddReceiver,
    required this.onTransfer,
    required this.onContactsSelected,
    required this.contactService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: multiReceiverControllers.length,
              itemBuilder: (context, index) {
                return ReceiverField(
                  controller: multiReceiverControllers[index],
                  index: index,
                  showRemoveButton: multiReceiverControllers.length > 1,
                  onRemove: () => onRemoveReceiver(index),
                  contactService: contactService,
                  onContactsSelected: (phones) => onContactsSelected(phones, index),
                );
              },
            ),

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