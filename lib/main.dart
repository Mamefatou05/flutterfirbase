import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/modules/home/bindings/home_binding.dart';
import 'app/modules/transaction/bindings/deposit_binding.dart';
import 'app/modules/transaction/views/deposit_view.dart';
import 'app/modules/transaction/bindings/transaction_binding.dart';
import 'app/modules/transaction/views/multiple_transfert_view.dart';
import 'app/modules/transaction/views/transfert_view.dart';
import 'firebase_options.dart'; // Importez les options générées
import 'app/modules/auth/bindings/auth_binding.dart';
import 'app/modules/auth/views/login_view.dart';
import 'app/modules/auth/views/register_view.dart';
import 'app/modules/auth/views/verify_code_view.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec les options spécifiques à la plateforme
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Vérifiez la connexion à Firestore
    await FirebaseFirestore.instance.collection('test').doc('test').set({
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Firestore connection successful');
  } catch (e) {
    print('Firebase/Firestore initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mon Application',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/verify-code',
          page: () => VerifyCodeView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => HomeView(),
          binding: HomeBinding(), // Liaison ici
        ),
        GetPage(
          name: '/transaction/single',
          page: () => TransfertView(),
          binding: TransactionBinding(), // Liaison ici
        ),
        GetPage(
          name: '/transaction/multiple',
          page: () => MultipleTransferView(),
          binding: TransactionBinding(), // Liaison ici
        ),
        GetPage(
          name: '/transaction/deposit',
          page: () => const DepositView(),
          binding: DepositBinding(),
        ),
      ],
    );
  }
}
