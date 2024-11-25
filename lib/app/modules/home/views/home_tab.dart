import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ui/widget/recent_transaction.dart';
import '../controllers/home_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(),
          Obx(() {
            if (controller.isLoadingTransactions.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return RecentTransactionsWidget(
              transactions: controller.recentTransactions,
              currentUserId: controller.currentUser.value?.id ?? '',
              onSeeAllPressed: () => Get.toNamed('/transaction/list'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    // Vérifier le rôle de l'utilisateur actuel
    final String userRole = controller.currentUser.value?.role.toString().split('.').last ?? '';
    print("le role du user: " + userRole);
    print(userRole);

    // Quick actions pour les rôles
    final quickActions = userRole == 'DISTRIBUTEUR'
        ? [
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Dépôt',
        'route': '/transaction/deposit'
      },
      {
        'icon': Icons.money_off,
        'label': 'Retrait',
        'route': '/transaction/withdraw'
      },
      {
        'icon': Icons.expand,
        'label': 'Déplafonné',
        'route': '/transaction/limits'
      },
    ]
        : [
      {
        'icon': Icons.send,
        'label': 'Envoyer',
        'route': '/transaction/single'
      },
      {
        'icon': Icons.schedule,
        'label': 'Planification',
        'route': '/planification/create'
      },
      {
        'icon': Icons.multiple_stop,
        'label': 'Multiple',
        'route': '/transaction/multiple'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: quickActions.map((action) {
              return _buildActionButton(
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                onTap: () => Get.toNamed(action['route'] as String),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Get.theme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Get.theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
