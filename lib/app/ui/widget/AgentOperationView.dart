import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text_field.dart';
import '../shared/wave_header.dart';

class AgentOperationView extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController phoneController;
  final TextEditingController amountController;
  final VoidCallback onSearch;
  final VoidCallback onSubmit;
  final AppUser? selectedUser;
  final bool isLoading;
  final String submitButtonText;

  const AgentOperationView({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.phoneController,
    required this.amountController,
    required this.onSearch,
    required this.onSubmit,
    required this.selectedUser,
    required this.isLoading,
    required this.submitButtonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              WaveHeader(
                title: title,
                subtitle: subtitle,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchCard(context),
                        const SizedBox(height: 16),
                        if (selectedUser != null) ...[
                          _buildUserInfoCard(context),
                          const SizedBox(height: 16),
                          _buildOperationCard(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Card(
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
                    controller: phoneController,
                    label: 'Numéro de téléphone',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isLoading ? null : onSearch,
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
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
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
              title: Text(selectedUser?.nomComplet ?? ''),
              subtitle: const Text('Nom complet'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(selectedUser?.numeroTelephone ?? ''),
              subtitle: const Text('Téléphone'),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text('${selectedUser?.balance.toStringAsFixed(2)} FCFA'),
              subtitle: const Text('Solde actuel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Montant',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: amountController,
              label: 'Montant (FCFA)',
              prefixIcon: Icons.money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: onSubmit,
              isLoading: isLoading,
              child: Text(
                submitButtonText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}