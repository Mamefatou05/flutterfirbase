import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';



class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();  // Ajout de l'initialisation
  final FacebookAuth _facebookAuth = FacebookAuth.instance;



  // CRUD Operations de base
  Future<DocumentReference> createDocument(
      String collectionPath,
      Map<String, dynamic> data, {
        String? docId, // ID personnalisé, facultatif
      }) async {
    try {
      if (docId != null && docId.isNotEmpty) {
        // Utiliser un ID personnalisé pour le document
        await _firestore.collection(collectionPath).doc(docId).set(data);
        return _firestore.collection(collectionPath).doc(docId);
      } else {
        // Créer le document avec un ID généré automatiquement
        return await _firestore.collection(collectionPath).add(data);
      }
    } catch (e) {
      print('Erreur lors de la création du document : $e');
      throw Exception('Erreur lors de la création du document');
    }
  }

  Future<void> setDocument(
      String collectionPath,
      String docId,
      Map<String, dynamic> data,
      {bool merge = false}
      ) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).set(data, SetOptions(merge: merge));
    } catch (e) {
      print('Erreur lors de la création/mise à jour du document avec ID : $e');
      throw Exception('Erreur lors de la création/mise à jour du document avec ID');
    }
  }


  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      print('Erreur lors de la mise à jour du document : $e');
      throw Exception('Erreur lors de la mise à jour du document');
    }
  }

  Future<Map<String, dynamic>?> getDocumentById(String collectionPath, String docId) async {
    try {
      final doc = await _firestore.collection(collectionPath).doc(docId).get();
      return doc.data();
    } catch (e) {
      print('Erreur lors de la récupération du document : $e');
      throw Exception('Erreur lors de la récupération du document');
    }
  }

  Future<List<Map<String, dynamic>>> getCollection(String collectionPath) async {
    try {
      final snapshot = await _firestore.collection(collectionPath).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erreur lors de la récupération de la collection : $e');
      throw Exception('Erreur lors de la récupération de la collection');
    }
  }

  Future<List<Map<String, dynamic>>> getDocumentsWhere(
      String collectionPath,
      String field,
      dynamic value
      ) async {
    try {
      final snapshot = await _firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .get();
     print("dans le firebase");
      print(snapshot);
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erreur lors de la récupération des documents filtrés : $e');
      throw Exception('Erreur lors de la récupération des documents filtrés');
    }
  }

  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du document : $e');
      throw Exception('Erreur lors de la suppression du document');
    }
  }

  // Auth Operations
  Future<UserCredential> registerUser(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erreur lors de l\'inscription : $e');
      throw Exception('Erreur lors de l\'inscription');
    }
  }
// Authentification par email/mot de passe
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erreur de connexion par email : $e');
      throw Exception('Erreur de connexion par email');
    }
  }

  // Authentification par numéro de téléphone
  Future<void> signInWithPhone(
      String phoneNumber,
      Function(PhoneAuthCredential) onVerificationCompleted,
      Function(FirebaseAuthException) onVerificationFailed,
      Function(String, int?) onCodeSent,
      Function(String) onCodeAutoRetrievalTimeout,
      ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Erreur de vérification du numéro : $e');
      throw Exception('Erreur de vérification du numéro');
    }
  }

  // Vérification du code SMS
  Future<UserCredential> verifyPhoneCode(
      String verificationId,
      String smsCode,
      ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Erreur de vérification du code SMS : $e');
      throw Exception('Code SMS invalide');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Déconnectez d'abord l'utilisateur pour forcer la sélection du compte
      await _googleSignIn.signOut();

      // Déclencher le flux de connexion Google avec sélection de compte
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Sélection du compte Google annulée');
      }

      // Obtenir les détails d'authentification du compte sélectionné
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer les credentials Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecter avec Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Erreur lors de la connexion Google: $e');
      throw Exception('Échec de la connexion avec Google: ${e.toString()}');
    }
  }

  // Méthode pour vérifier si un utilisateur est déjà connecté avec Google
  Future<bool> isGoogleSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Méthode pour déconnecter l'utilisateur de Google
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }


  // Nouvelle méthode pour l'authentification Facebook
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Déconnexion préalable pour éviter les conflits
      await _facebookAuth.logOut();

      // Déclencher le flux de connexion Facebook
      final LoginResult loginResult = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.dialogOnly, // Force l'affichage du dialogue de sélection
      );

      if (loginResult.status != LoginStatus.success) {
        throw Exception('Échec de la connexion Facebook: ${loginResult.status}');
      }

      // Obtenir le token d'accès
      final AccessToken? accessToken = loginResult.accessToken;

      if (accessToken == null) {
        throw Exception('Token d\'accès Facebook non obtenu');
      }

      // Créer un credential Firebase avec le token Facebook
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.token,
      );

      // Connecter avec Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Obtenir les informations supplémentaires de l'utilisateur Facebook
      final userData = await _facebookAuth.getUserData(
        fields: "name,email,picture",
      );

      // Si vous voulez stocker des informations supplémentaires dans Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'facebookId': userData['id'],
          'displayName': userData['name'],
          'email': userData['email'],
          'photoURL': userData['picture']?['data']?['url'],
          'lastLoginProvider': 'facebook',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException pendant la connexion Facebook: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Ce compte existe déjà avec une autre méthode de connexion. Veuillez utiliser une autre méthode.');
        case 'invalid-credential':
          throw Exception('Les informations d\'identification Facebook sont invalides.');
        case 'operation-not-allowed':
          throw Exception('La connexion Facebook n\'est pas activée dans Firebase.');
        case 'user-disabled':
          throw Exception('Ce compte utilisateur a été désactivé.');
        case 'user-not-found':
          throw Exception('Aucun compte utilisateur trouvé.');
        default:
          throw Exception('Erreur lors de la connexion Facebook: ${e.message}');
      }
    } catch (e) {
      print('Erreur lors de la connexion Facebook: $e');
      throw Exception('Erreur inattendue lors de la connexion Facebook');
    }
  }

  // Méthode pour vérifier si un utilisateur est connecté avec Facebook
  Future<bool> isFacebookSignedIn() async {
    final AccessToken? accessToken = await _facebookAuth.accessToken;
    return accessToken != null && !accessToken.isExpired;
  }

  // Mise à jour de la méthode de déconnexion pour inclure Facebook
  Future<void> logout() async {
    try {
      await _facebookAuth.logOut();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
      throw Exception('Erreur lors de la déconnexion');
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }


}
