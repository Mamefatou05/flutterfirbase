import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/transaction_model.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback onSeeAllPressed;
  final String currentUserId;
  final String? role; // Ajout de la propriété rôle


  const RecentTransactionsWidget({
    Key? key,
    required this.transactions,
    required this.onSeeAllPressed,
    required this.currentUserId,
    this.role, // Paramètre facultatif pour le rôle

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transactions récentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAllPressed,
          child: const Text('Voir tout'),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('Aucune transaction récente'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return _buildTransactionItem(transactions[index]);
      },
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final bool isSender = transaction.senderId == currentUserId;
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

    // Conversion de Timestamp en DateTime
    final DateTime dateTime = transaction.timestamp.toDate();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSender
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        child: Icon(
          isSender ? Icons.arrow_upward : Icons.arrow_downward,
          color: isSender ? Colors.red : Colors.green,
        ),
      ),
      title: Text(
        isSender ? 'Envoyé' : 'Reçu',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        formatter.format(dateTime), // Utilisation du DateTime
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isSender ? "-" : "+"} ${transaction.amount.toStringAsFixed(0)} F',
            style: TextStyle(
              color: isSender ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getStatusText(transaction.status),
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(transaction.status),
            ),
          ),
        ],
      ),
      onTap: () => Get.toNamed(
        '/transactions/details',
        arguments: transaction,
      ),
    );
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.PENDING:
        return 'En attente';
      case TransactionStatus.COMPLETED:
        return 'Terminé';
      case TransactionStatus.FAILED:
        return 'Échoué';
      default:
        return status.toString().split('.').last;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return Colors.green;
      case TransactionStatus.PENDING:
        return Colors.orange;
      case TransactionStatus.FAILED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
