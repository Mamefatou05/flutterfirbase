import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/enums.dart';
import '../../data/models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  String? _verificationId;

  AuthService(this._firebaseService);



  Future<AppUser?> registerUser({
    required String email,
    required String password,
    required String nomComplet,
    required String numeroTelephone,
  }) async {

    try {
      // Add print statement for debugging
      print('Starting registration process...');

      final userCredential = await _firebaseService.registerUser(email, password);
      print('User registered with Firebase Auth');

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final appUser = AppUser(
          id: firebaseUser.uid,
          nomComplet: nomComplet,
          numeroTelephone: numeroTelephone,
          email: email,
          balance: 0.0,
          role: Role.CLIENT,
        );

        print('Creating user document in Firestore...');
        await _firebaseService.setDocument(
          'users',
          firebaseUser.uid,
          appUser.toJson(),
        );
        print('User document created successfully');

        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during registration: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Cette adresse email est déjà utilisée');
        case 'weak-password':
          throw Exception('Le mot de passe est trop faible');
        case 'invalid-email':
          throw Exception('Adresse email invalide');
        case 'configuration-not-found':
          throw Exception('Erreur de configuration Firebase. Veuillez réessayer.');
        default:
          throw Exception('Erreur lors de l\'inscription: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error during registration: $e');
      throw Exception('Une erreur inattendue s\'est produite');
    }
  }

  Future<AppUser?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmail(
        email,
        password,
      );
      await _updateUserLoginInfo(userCredential.user);

      if (userCredential.user != null) {
        final userData = await getUserDetails(userCredential.user!.uid);
        if (userData != null) {
          return AppUser.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la connexion par email : $e');
      rethrow;
    }
  }
  Future<void> startPhoneLogin(
      String phoneNumber,
      Function(String) onCodeSent,
      Function(String) onError,
      ) async {
    try {
      print('Démarrage de la connexion par téléphone pour $phoneNumber...');
      await _firebaseService.signInWithPhone(
        phoneNumber,
            (auth.PhoneAuthCredential credential) async {
          print('Credential reçu : $credential');
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            print('Connexion réussie pour : ${userCredential.user?.uid}');
            await _updateUserLoginInfo(userCredential.user);
          } catch (e) {
            print('Erreur lors de la connexion : $e');
            onError(e.toString());
          }
        },
            (auth.FirebaseAuthException e) {
          print('FirebaseAuthException : ${e.code}');
          onError(e.message ?? 'Erreur de vérification');
        },
            (String verificationId, int? resendToken) {
          print('Code envoyé avec ID de vérification : $verificationId');
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
            (String verificationId) {
          print('Vérification terminée : $verificationId');
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      print('Erreur inattendue : $e');
      onError(e.toString());
    }
  }

  Future<AppUser?> verifyPhoneCode(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Aucune vérification en cours');
    }

    try {
      // Vérification du code SMS avec Firebase
      final userCredential = await _firebaseService.verifyPhoneCode(
        _verificationId!,
        smsCode,
      );

      // Mise à jour des informations de connexion
      await _updateUserLoginInfo(userCredential.user);

      // Récupération des données de l'utilisateur depuis Firestore
      if (userCredential.user != null) {
        final userData = await getUserDetails(userCredential.user!.uid);
        if (userData != null) {
          // Retourner un objet AppUser
          return AppUser.fromJson(userData);
        }
      }

      return null;
    } catch (e) {
      print('Erreur lors de la vérification du code : $e');
      rethrow;
    }
  }

  Future<AppUser?> loginWithGoogle() async {
    try {
      final userCredential = await _firebaseService.signInWithGoogle();
      await _updateUserLoginInfo(userCredential.user);

      if (userCredential.user != null) {
        final userData = await getUserDetails(userCredential.user!.uid);
        if (userData != null) {
          return AppUser.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la connexion Google : $e');
      rethrow;
    }
  }
  Future<void> _updateUserLoginInfo(User? firebaseUser) async {
    if (firebaseUser != null) {
      final updates = {
        'lastLogin': FieldValue.serverTimestamp(),
        if (firebaseUser.email != null) 'email': firebaseUser.email,
        if (firebaseUser.phoneNumber != null) 'numeroTelephone': firebaseUser.phoneNumber,
        if (firebaseUser.displayName != null) 'nomComplet': firebaseUser.displayName,
      };

      if (!await _userExists(firebaseUser.uid)) {
        updates['dateCreation'] = FieldValue.serverTimestamp();
        updates['role'] = Role.CLIENT.toString().split('.').last;
        updates['balance'] = 0.0;
      }

      await _firebaseService.setDocument(
        'users',
        firebaseUser.uid,
        updates,
        merge: true,
      );
    }
  }

  Future<bool> _userExists(String userId) async {
    final userData = await _firebaseService.getDocumentById('users', userId);
    return userData != null;
  }

  Future<void> logout() async {
    await _firebaseService.logout();
  }

  Future<AppUser?> getCurrentUserData() async {
    final firebaseUser = _firebaseService.getCurrentUser();
    if (firebaseUser != null) {
      final userData = await getUserDetails(firebaseUser.uid);
      if (userData != null) {
        return AppUser.fromJson(userData);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    return await _firebaseService.getDocumentById('users', userId);
  }

  Future<AppUser?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      // Utiliser la méthode getDocumentsWhere du FirebaseService
      final userDocs = await _firebaseService.getDocumentsWhere(
          'users',
          'numeroTelephone',
          phoneNumber
      );

      if (userDocs.isNotEmpty) {
        // Retourner le premier document correspondant
        return AppUser.fromJson(userDocs.first);
      }

      return null;
    } catch (e) {
      print('Erreur lors de la recherche de l\'utilisateur par téléphone : $e');
      return null;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Utiliser la méthode setDocument du FirebaseService avec merge: true
      await _firebaseService.setDocument(
          'users',
          userId,
          updates,
          merge: true
      );
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur : $e');
      return false;
    }
  }
}
