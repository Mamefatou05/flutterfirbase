import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/enums.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../ui/shared/custom_footer.dart';
import '../../../ui/shared/custom_text_field.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/transaction_controller.dart';
class TransactionDetailsPage extends GetView<TransactionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Remplacement de l'AppBar par WaveHeader
          WaveHeader(
            title: 'Détails de la Transaction',
            showBackButton: true,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTransactionDetails(),
                  SizedBox(height: 16),
                  _buildSenderDetails(),
                  SizedBox(height: 16),
                  _buildReceiverDetails(),
                  SizedBox(height: 24),
                  _buildCancelButton(),
                ],
              ),
            ),
          ),

          // Ajout du CustomFooter
          CustomFooter(currentRoute: '/transaction/details'),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Obx(() {
      final transaction = controller.selectedTransaction.value;
      if (transaction == null) {
        return Center(child: Text('Aucune transaction sélectionnée'));
      }

      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Information de la Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              // Utilisation de CustomTextField en mode lecture seule pour chaque détail
              CustomTextField(
                controller: TextEditingController(text: transaction.id),
                label: 'ID',
                prefixIcon: Icons.numbers,
                readOnly: true,
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: TextEditingController(
                    text: '${transaction.amount.toStringAsFixed(2)} €'
                ),
                label: 'Montant',
                prefixIcon: Icons.euro,
                readOnly: true,
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: TextEditingController(
                    text: transaction.type.toString().split('.').last
                ),
                label: 'Type',
                prefixIcon: Icons.category,
                readOnly: true,
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: TextEditingController(
                    text: transaction.status.toString().split('.').last
                ),
                label: 'Statut',
                prefixIcon: Icons.info,
                readOnly: true,
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: TextEditingController(
                    text: _formatDate(transaction.timestamp.toDate())
                ),
                label: 'Date',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildSenderDetails() {
    return Obx(() {
      final sender = controller.senderDetails.value;
      return _buildUserDetailsCard('Expéditeur', sender);
    });
  }

  Widget _buildReceiverDetails() {
    return Obx(() {
      final receiver = controller.receiverDetails.value;
      return _buildUserDetailsCard('Destinataire', receiver);
    });
  }

  Widget _buildCancelButton() {
    return Obx(() {
      if (!controller.canShowCancelButton.value) {
        return SizedBox.shrink();
      }

      return Center(
        child: ElevatedButton.icon(
          onPressed: () => controller.cancelTransaction(),
          icon: Icon(Icons.cancel),
          label: Text('Annuler la Transaction'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      );
    });
  }

  Widget _buildUserDetailsCard(String title, AppUser? user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            if (user == null)
              Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  _buildDetailRow('Nom', user.nomComplet),
                  _buildDetailRow('Téléphone', user.numeroTelephone),
                  _buildDetailRow('Email', user.email),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return Colors.green;
      case TransactionStatus.PENDING:
        return Colors.orange;
      case TransactionStatus.CANCELLED:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}