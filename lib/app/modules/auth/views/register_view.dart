import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            WaveHeader(
              title: 'Inscription',
              subtitle: 'Créez votre compte',
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Nom complet',
                    prefixIcon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Mot de passe',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: phoneController,
                    label: 'Numéro de téléphone',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    onPressed: () => controller.register(
                      email: emailController.text,
                      password: passwordController.text,
                      nomComplet: nameController.text,
                      numeroTelephone: phoneController.text,
                    ),
                    isLoading: controller.isLoading.value,
                    child: Text('S\'inscrire'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
