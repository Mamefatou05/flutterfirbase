import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/enums.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../ui/shared/custom_footer.dart';
import '../../../ui/shared/wave_header.dart';
import '../controllers/transaction_controller.dart';

class TransactionsListPage extends GetView<TransactionController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WaveHeader(
            title: 'Mes Transactions',
            showBackButton: true,
          ),
          _buildFilterSection(),
          Expanded(
            child: _buildTransactionsList(),
          ),
          CustomFooter(
            currentRoute: '/transaction/list',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Wrap each Expanded in a Flexible for better space distribution
          Flexible(
            flex: 1,
            child: Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(Get.context!).copyWith(
                  canvasColor: Colors.grey[100],
                ),
                child: DropdownButtonFormField<TransactionType>(
                  isExpanded: true, // Prevent horizontal overflow
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: controller.selectedType.value,
                  items: [
                    DropdownMenuItem<TransactionType>(
                      value: null,
                      child: Text('Tous les types', overflow: TextOverflow.ellipsis),
                    ),
                    ...TransactionType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_formatTransactionType(type),
                          overflow: TextOverflow.ellipsis),
                    )),
                  ],
                  onChanged: controller.updateTypeFilter,
                ),
              ),
            )),
          ),
          SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(Get.context!).copyWith(
                  canvasColor: Colors.grey[100],
                ),
                child: DropdownButtonFormField<TransactionStatus>(
                  isExpanded: true, // Prevent horizontal overflow
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: controller.selectedStatus.value,
                  items: [
                    DropdownMenuItem<TransactionStatus>(
                      value: null,
                      child: Text('Tous les statuts',
                          overflow: TextOverflow.ellipsis),
                    ),
                    ...TransactionStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last,
                          overflow: TextOverflow.ellipsis),
                    )),
                  ],
                  onChanged: controller.updateStatusFilter,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }


  String _formatTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.SCHEDULED_TRANSFER:
        return 'Transfert programmé';
      default:
        return type.toString().split('.').last;
    }
  }

  Widget _buildTransactionsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Aucune transaction trouvée',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.transactions.length,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final transaction = controller.transactions[index];
          return _buildTransactionItem(transaction);
        },
      );
    });
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.selectTransaction(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _getTransactionIcon(transaction.type),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTransactionType(transaction.type),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${transaction.amount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _getAmountColor(transaction.type),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(transaction.timestamp.toDate()),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          transaction.status.toString().split('.').last,
                          style: TextStyle(
                            color: _getStatusColor(transaction.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTransactionIcon(TransactionType type) {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case TransactionType.SCHEDULED_TRANSFER:
      case TransactionType.TRANSFERT:
        iconData = Icons.swap_horiz;
        backgroundColor = Colors.blue[50]!;
        iconColor = Colors.blue[700]!;
        break;
      case TransactionType.DEPOT:
        iconData = Icons.arrow_downward;
        backgroundColor = Colors.green[50]!;
        iconColor = Colors.green[700]!;
        break;
      case TransactionType.RETRAIT:
        iconData = Icons.arrow_upward;
        backgroundColor = Colors.red[50]!;
        iconColor = Colors.red[700]!;
        break;
      default:
        iconData = Icons.attach_money;
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return Colors.green[700]!;
      case TransactionStatus.PENDING:
        return Colors.orange[700]!;
      case TransactionStatus.CANCELLED:
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Color _getAmountColor(TransactionType type) {
    switch (type) {
      case TransactionType.DEPOT:
        return Colors.green[700]!;
      case TransactionType.RETRAIT:
        return Colors.red[700]!;
      default:
        return Colors.blue[700]!;
    }
  }

  String _formatDate(DateTime date) {
    String padding(int n) => n.toString().padLeft(2, '0');
    return '${padding(date.day)}/${padding(date.month)}/${date.year} ${padding(date.hour)}:${padding(date.minute)}';
  }
}
