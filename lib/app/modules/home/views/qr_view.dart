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
      Get.to(() => DepositView(initialPhoneNumber: phoneNumber));
    } else {
      // Si c'est un client, ouvrir l'écran de transfert
      Get.to(() => TransfertView(initialReceiverPhone: phoneNumber));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isScanning ? 'Scanner un QR Code' : 'Mon QR Code'),
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.qr_code : Icons.qr_code_scanner),
            onPressed: () {
              setState(() {
                isScanning = !isScanning;
              });
            },
          ),
        ],
      ),
      body: isScanning ? _buildQRScanner() : _buildMyQRCode(),
    );
  }

  Widget _buildMyQRCode() {
    final phoneNumber = controller.currentUser.value?.numeroTelephone ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: phoneNumber,
            version: QrVersions.auto,
            size: 200.0,
          ),
          SizedBox(height: 20),
          Text(
            'Votre numéro de téléphone',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            phoneNumber,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                break; // Traiter seulement le premier code scanné
              }
            }
          },
        ),
        // Ajouter un overlay pour guider l'utilisateur
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Placez le QR code dans le cadre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}