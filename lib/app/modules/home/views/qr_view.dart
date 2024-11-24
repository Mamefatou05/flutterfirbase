import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../data/models/enums.dart';
import '../../transaction/views/deposit_view.dart';
import '../../transaction/views/transfert_view.dart';
import '../controllers/home_controller.dart';


class QRScreen extends StatefulWidget {
  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  bool isScanning = false;
  final HomeController controller = Get.find<HomeController>();

  void _handleScannedBarcode(String? phoneNumber) {
    if (phoneNumber == null) return;

    // Fermer l'écran de scan
    Get.back();

    // Vérifier le rôle de l'utilisateur courant
    final userRole = controller.currentUser.value?.role;

    if (userRole == Role.DISTRIBUTEUR) {
      // Si c'est un agent, ouvrir l'écran de dépôt
      Get.toNamed('/transaction/deposit', parameters: {
        'initialPhoneNumber': phoneNumber
      });
    } else {
      // Si c'est un client, ouvrir l'écran de transfert
      Get.toNamed('/transaction/single', parameters: {
        'initialReceiverPhone': phoneNumber
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isScanning ? 'Scanner un QR Code' : 'Mon QR Code',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                isScanning ? Icons.qr_code : Icons.qr_code_scanner,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  isScanning = !isScanning;
                });
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: isScanning ? _buildQRScanner() : _buildMyQRCode(),
      ),
    );
  }
  Widget _buildMyQRCode() {
    final phoneNumber = controller.currentUser.value?.numeroTelephone ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: QrImageView(
              data: phoneNumber,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Votre numéro de téléphone',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _handleScannedBarcode(barcode.rawValue);
                break;
              }
            }
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
              stops: [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Coins du cadre
                Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
                Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
                Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
                Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Placez le QR code dans le cadre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3) : BorderSide.none,
          left: isLeft ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3) : BorderSide.none,
          right: !isLeft ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}