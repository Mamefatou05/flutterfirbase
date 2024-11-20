import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  final String currentRoute;

  const CustomFooter({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, '/home', Icons.home, 'Accueil'),
            _buildNavItem(context, '/qr', Icons.qr_code_scanner, 'QR'),
            _buildNavItem(context, '/history', Icons.history, 'Historique'),
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
      ) {
    final theme = Theme.of(context);
    final isSelected = currentRoute == route;

    return InkWell(
      onTap: () {
        if (currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}