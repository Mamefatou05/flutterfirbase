import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Variables pour contrôler la visibilité
  final RxString selectedMethod = ''.obs;
  final RxBool showOptions = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => SingleChildScrollView(
        child: Column(
          children: [
            WaveHeader(
              title: 'Connexion',
              subtitle: 'Bienvenue sur notre application',
              showBackButton: false,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Options de connexion initiales
                  if (showOptions.value) ...[
                    _buildMethodButton(
                      'email',
                      'Email',
                      Icons.email,
                      'Se connecter avec Email',
                    ),
                    SizedBox(height: 16),
                    _buildMethodButton(
                      'phone',
                      'Téléphone',
                      Icons.phone,
                      'Se connecter avec Téléphone',
                    ),
                    SizedBox(height: 16),
                    _buildMethodButton(
                      'google',
                      'Google',
                      Icons.g_mobiledata,
                      'Se connecter avec Google',
                    ),
                    _buildMethodButton(
                      'facebook',
                      'Facebook',
                      Icons.facebook,
                      'Se connecter avec Facebook',
                    ),

                  ],

                  // Formulaire Email
                  if (selectedMethod.value == 'email') ...[
                    AnimatedOpacity(
                      opacity: selectedMethod.value == 'email' ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              selectedMethod.value = '';
                              showOptions.value = true;
                            },
                          ),
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
                          SizedBox(height: 24),
                          CustomButton(
                            onPressed: () => controller.loginWithEmail(
                              emailController.text,
                              passwordController.text,
                            ),
                            isLoading: controller.isLoading.value,
                            child: Text('Se connecter'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Formulaire Téléphone
                  if (selectedMethod.value == 'phone') ...[
                    AnimatedOpacity(
                      opacity: selectedMethod.value == 'phone' ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              selectedMethod.value = '';
                              showOptions.value = true;
                            },
                          ),
                          CustomTextField(
                            controller: phoneController,
                            label: 'Numéro de téléphone',
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 24),
                          CustomButton(
                            onPressed: () => controller.startPhoneLogin(
                              phoneController.text,
                            ),
                            isLoading: controller.isLoading.value,
                            child: Text('Se connecter'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),
                  if (showOptions.value)
                    TextButton(
                      onPressed: () => Get.toNamed('/register'),
                      child: Text('Créer un compte'),
                    ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildMethodButton(
      String method,
      String title,
      IconData icon,
      String buttonText,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: CustomButton(
        onPressed: () {
          selectedMethod.value = method;
          showOptions.value = false;
          if (method == 'google') {
            controller.loginWithGoogle();
          }
          if (method == 'facebook') {
            controller.loginWithFacebook();
          }

        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            SizedBox(width: 8),
            Text(buttonText),
          ],
        ),
      ),
    );
  }
}
