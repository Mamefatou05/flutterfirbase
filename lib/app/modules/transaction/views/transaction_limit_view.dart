import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../ui/shared/custom_button.dart';
import '../../../ui/shared/custom_footer.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/transaction_limit_controller.dart';

class TransactionLimitView extends StatelessWidget {
  const TransactionLimitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionLimitController>();

    return Scaffold(
      body: Column(
        children: [
          WaveHeader(
            title: 'Gestion des Plafonds',
            subtitle: 'Contrôle des limites',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildClientSearch(controller),
                  SizedBox(height: 20),
                  Expanded(child: _buildTransactionLimits(controller, context)),
                ],
              ),
            ),
          ),
          CustomFooter(currentRoute: "/transaction/limits"),

        ],
      ),
    );
  }

  Widget _buildClientSearch(TransactionLimitController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rechercher un client',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: controller.searchController,
              label: 'Numéro de téléphone',
              prefixIcon: Icons.phone,
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => controller.searchClient(),
              ),
              onChanged: (_) {},
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionLimits(TransactionLimitController controller, BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value) {
        return Center(child: CircularProgressIndicator());
      }

      final client = controller.selectedClient.value;
      if (client == null) {
        return Center(
          child: Text('Recherchez un client pour voir ses plafonds'),
        );
      }

      final data = controller.transactionData.value;
      if (data == null) {
        return Center(child: Text('Aucune donnée disponible'));
      }

      return ListView(
        children: [
          _buildClientInfo(client),
          SizedBox(height: 20),
          _buildLimitCard(
            title: 'Limite Quotidienne',
            current: data['dailyTotal'],
            limit: data['dailyLimit'],
            onEdit: () => _showEditDialog(context, controller, true, data['dailyLimit']),
          ),
          SizedBox(height: 16),
          _buildLimitCard(
            title: 'Limite Mensuelle',
            current: data['monthlyTotal'],
            limit: data['monthlyLimit'],
            onEdit: () => _showEditDialog(context, controller, false, data['monthlyLimit']),
          ),
        ],
      );
    });
  }

  Widget _buildClientInfo(AppUser client) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Information Client',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            CustomTextField(
              controller: TextEditingController(text: client.nomComplet),
              label: 'Nom',
              prefixIcon: Icons.person,
              readOnly: true,
            ),
            SizedBox(height: 8),
            CustomTextField(
              controller: TextEditingController(text: client.numeroTelephone),
              label: 'Téléphone',
              prefixIcon: Icons.phone,
              readOnly: true,
            ),
            SizedBox(height: 8),
            CustomTextField(
              controller: TextEditingController(text: client.email),
              label: 'Email',
              prefixIcon: Icons.email,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitCard({
    required String title,
    required double current,
    required double limit,
    required VoidCallback onEdit,
  }) {
    final percentage = (current / limit).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 1 ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${current.toStringAsFixed(2)} €'),
                Text('Limite: ${limit.toStringAsFixed(2)} €'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TransactionLimitController controller, bool isDaily, double currentLimit) {
    final textController = TextEditingController(text: currentLimit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier la limite ${isDaily ? "quotidienne" : "mensuelle"}'),
        content: CustomTextField(
          controller: textController,
          label: 'Nouvelle limite',
          prefixIcon: Icons.euro,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CustomButton(
            onPressed: () {
              final newLimit = double.tryParse(textController.text);
              if (newLimit != null) {
                controller.updateLimits(
                  isDaily ? newLimit : null,
                  isDaily ? null : newLimit,
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}