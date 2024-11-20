import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/auth_controller.dart';
class VerifyCodeView extends GetView<AuthController> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WaveHeader(
            title: 'Vérification',
            subtitle: 'Entrez le code reçu par SMS',
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: codeController,
                  label: 'Code de vérification',
                  prefixIcon: Icons.security,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 24),
                CustomButton(
                  onPressed: () => controller.verifyPhoneCode(
                    codeController.text,
                  ),
                  isLoading: controller.isLoading.value,
                  child: Text('Vérifier'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}