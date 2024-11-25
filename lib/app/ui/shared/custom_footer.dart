import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFooter extends StatelessWidget {
  final String currentRoute;

  const CustomFooter({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildNavItem(
                context,
                '/home',
                Icons.home,
                'Accueil',
                currentRoute == '/home',
              ),
            ),
            Expanded(
              child: _buildCenterNavItem(
                context,
                '/qr',
                Icons.qr_code_scanner,
                'QR',
                currentRoute == '/qr',
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                '/transaction/list',
                Icons.history,
                'Historique',
                currentRoute == '/transaction/list',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      String route,
      IconData icon,
      String label,
      bool isSelected,
      ) {
    return InkWell(
      onTap: () {
        if (!isSelected) {
          Get.toNamed(route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
        children: [
          Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            size: 22,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem(
      BuildContext context,
      String route,
      IconData icon,
      String label,
      bool isSelected,
      ) {
    return Center(
      child: GestureDetector( // Remplacer InkWell par GestureDetector
        onTap: () async {
          if (!isSelected) {
            try {
              // Ajout de logs pour déboguer
              print('Tentative de navigation vers: $route');
              await Get.toNamed(route);
            } catch (e) {
              print('Erreur de navigation: $e');
              // Afficher un message à l'utilisateur
              Get.snackbar(
                'Erreur',
                'Impossible d\'accéder à cette fonction pour le moment',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
