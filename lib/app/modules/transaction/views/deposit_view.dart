import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/deposit_controller.dart';


class DepositView extends GetView<DepositController> {

  const DepositView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer le numéro de téléphone à partir des paramètres
    final String? initialPhoneNumber = Get.parameters['initialPhoneNumber'];

    // Utiliser WidgetsBinding pour s'assurer que le texte est défini après le rendu initial
    if (initialPhoneNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.clientPhoneController.text = initialPhoneNumber;
        controller.searchClient();
      });
    }

    return Scaffold(
      body: Obx(() => Stack(
        children: [
          Column(
            children: [
              WaveHeader(
                title: 'Effectuer un dépôt',
                subtitle: 'Entrez le numéro de téléphone du client',
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section recherche client
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rechercher un client',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: controller.clientPhoneController,
                                        label: 'Numéro de téléphone',
                                        prefixIcon: Icons.phone,
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : controller.searchClient,
                                      icon: const Icon(Icons.search),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Informations client
                        if (controller.clientUser.value != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informations client',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  ListTile(
                                    leading: const Icon(Icons.person),
                                    title: Text(controller.clientUser.value?.nomComplet ?? ''),
                                    subtitle: const Text('Nom complet'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.phone),
                                    title: Text(controller.clientUser.value?.numeroTelephone ?? ''),
                                    subtitle: const Text('Téléphone'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.account_balance_wallet),
                                    title: Text('${controller.clientUser.value?.balance.toStringAsFixed(2)} FCFA'),
                                    subtitle: const Text('Solde actuel'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Section montant
                        if (controller.clientUser.value != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Montant du dépôt',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: controller.amountController,
                                    label: 'Montant (FCFA)',
                                    prefixIcon: Icons.money,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomButton(
                                    onPressed: controller.performDeposit,
                                    isLoading: controller.isLoading.value,
                                    child: const Text(
                                      'Effectuer le dépôt',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )),
    );
  }
}
