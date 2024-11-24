import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/ContactService.dart';
import '../../../ui/shared/custom_footer.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../../../ui/widget/contact/ContactPickerWidget.dart';
import '../controllers/transaction_controller.dart';

class TransfertView extends StatelessWidget {
  const TransfertView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Injecter le contrôleur
    final TransactionController controller = Get.find();
    final ContactService contactService = Get.find();

    // Récupérer le numéro de téléphone à partir des paramètres
    final String? initialReceiverPhone = Get.parameters['initialReceiverPhone'];

    // Utiliser WidgetsBinding pour s'assurer que le texte est défini après le rendu initial
    if (initialReceiverPhone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.receiverController.text = initialReceiverPhone;
      });
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          WaveHeader(
            title: "Transfert Simple",
            subtitle: "Envoyez de l'argent rapidement et en toute sécurité.",
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.receiverController,
                      label: "Téléphone du destinataire",
                      prefixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.amountController,
                      label: "Montant à envoyer",
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => controller.syncAmounts(isSend: true),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.amountReceivedController,
                      label: "Montant reçu",
                      prefixIcon: Icons.money,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => controller.syncAmounts(isSend: false),
                    ),
                    const SizedBox(height: 16),
                    ContactPickerWidget(
                      multipleSelection: false,
                      contactService: contactService,
                      onContactsSelected: (phones) {
                        if (phones.isNotEmpty) {
                          controller.receiverController.text = phones.first;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                        await controller.performTransfer(isMultiple: false);
                      },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text("Envoyer"),
                    )),

                  ],
                ),
              ),
            ),
          ),
          // Footer
          CustomFooter(currentRoute: "/transaction/single"),
        ],
      ),
    );
  }
}
