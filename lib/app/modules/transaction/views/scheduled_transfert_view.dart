import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/enums.dart';
import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_footer.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/scheduled_transaction_controller.dart';

class ScheduledTransferView extends StatelessWidget {
  final controller = Get.find<ScheduledTransactionController>();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final selectedFrequency = Rx<ScheduleFrequency?>(null);

  ScheduledTransferView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WaveHeader(
            title: 'Planifier un transfert',
            subtitle: 'Définissez les détails',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: phoneController,
                      label: 'Numéro du bénéficiaire',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un numéro';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: amountController,
                      label: 'Montant',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        try {
                          double amount = double.parse(value);
                          if (amount <= 0) {
                            return 'Le montant doit être supérieur à 0';
                          }
                        } catch (e) {
                          return 'Veuillez entrer un montant valide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: dateController,
                      label: 'Date d\'exécution',
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            final dateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            dateController.text =
                                DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
                          }
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une date';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Obx(() => DropdownButtonFormField<ScheduleFrequency>(
                      decoration: InputDecoration(
                        labelText: 'Fréquence',
                        prefixIcon: Icon(Icons.repeat),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: selectedFrequency.value,
                      items: ScheduleFrequency.values.map((frequency) {
                        String label;
                        switch (frequency) {
                          case ScheduleFrequency.DAILY:
                            label = 'Quotidien';
                            break;
                          case ScheduleFrequency.WEEKLY:
                            label = 'Hebdomadaire';
                            break;
                          case ScheduleFrequency.MONTHLY:
                            label = 'Mensuel';
                            break;
                        }
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (frequency) {
                        selectedFrequency.value = frequency;
                      },
                      validator: (value) {
                        if (selectedFrequency.value == null) {
                          return 'Veuillez sélectionner une fréquence';
                        }
                        return null;
                      },
                    )),
                    SizedBox(height: 32),
                    Obx(() => CustomButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final dateFormat =
                          DateFormat('dd/MM/yyyy HH:mm');
                          final executionTime = dateFormat
                              .parse(dateController.text);
                          controller.createScheduledTransaction(
                            receiverPhone: phoneController.text,
                            amount: double.parse(amountController.text),
                            frequency: selectedFrequency.value!,
                            executionTime: executionTime,
                          );
                        }
                      },
                      isLoading: controller.isLoading.value,
                      child: Text(
                        'Planifier le transfert',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
          CustomFooter(currentRoute: "/planification/create"),

        ],
      ),
    );
  }
}
