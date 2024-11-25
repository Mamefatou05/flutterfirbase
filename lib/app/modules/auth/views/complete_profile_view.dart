import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/profile_controller.dart';


class CompleteProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      body: Column(
        children: [
          WaveHeader(
            title: 'Compléter votre profil',
            showBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                final user = controller.user.value;

                if (user == null) {
                  return Center(child: Text('Aucune donnée utilisateur'));
                }

                // Formulaire pour compléter le profil
                return ProfileForm(controller: controller, user: user);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileForm extends StatelessWidget {
  final ProfileController controller;
  final AppUser user;

  const ProfileForm({
    Key? key,
    required this.controller,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController(text: user.nomComplet ?? '');
    final _phoneController = TextEditingController(text: user.numeroTelephone ?? '');
    final _emailController = TextEditingController(text: user.email ?? '');

    return Form(
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Nom Complet',
            prefixIcon: Icons.person,
            validator: (value) => value!.isEmpty ? 'Nom requis' : null,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Numéro requis' : null,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 24),
          CustomButton(
            onPressed: () async {
              final success = await controller.updateProfile(
                userId: user.id,
                nomComplet: _nameController.text,
                numeroTelephone: _phoneController.text,
                email: _emailController.text.isNotEmpty
                    ? _emailController.text
                    : null,
              );
              if (success) {
                Get.back();
              }
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
