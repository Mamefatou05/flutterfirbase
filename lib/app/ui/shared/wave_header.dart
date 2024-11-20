import 'package:flutter/material.dart';

// Define the custom clippers before the WaveHeader class.
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);

    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.95);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.75);
    var secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);

    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.85);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.65);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Your WaveHeader widget follows
class WaveHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final Widget? trailing; // Nouveau paramètre pour les contrôles

  const WaveHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.trailing, // Ajout du paramètre trailing
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // Première couche de gradient plus foncé
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6B35E8),
                    Color(0xFF8B5CF6),
                  ],
                ),
              ),
            ),
          ),

          // Deuxième couche de vague plus claire et transparente
          ClipPath(
            clipper: WaveClipper2(),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Bouton retour et contrôles
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showBackButton)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFF6B35E8)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                if (trailing != null) trailing!, // Ajout des contrôles
              ],
            ),
          ),

          // Contenu central (titre et sous-titre)
          Positioned(
            top: showBackButton ? 90 : 40, // Ajustement de la position selon la présence du bouton retour
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}