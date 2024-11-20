import 'package:get/get.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactService extends GetxService {
  // Vérifier et demander la permission d'accéder aux contacts
  Future<bool> _requestPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }
    return status.isGranted;
  }

  // Récupérer la liste des contacts avec gestion des permissions
  Future<List<Contact>> fetchContacts() async {
    if (await _requestPermission()) {
      final contacts = await ContactsService.getContacts();
      return contacts.toList();
    } else {
      throw Exception("Permission d'accéder aux contacts refusée");
    }
  }

  // Ajouter un nouveau contact
  Future<bool> addContact(String name, String phoneNumber) async {
    try {
      if (await _requestPermission()) {
        final newContact = Contact()
          ..givenName = name
          ..phones = [Item(value: phoneNumber)];

        await ContactsService.addContact(newContact);
        return true;
      } else {
        throw Exception("Permission d'accéder aux contacts refusée");
      }
    } catch (e) {
      print("Erreur lors de l'ajout du contact: $e");
      return false;
    }
  }
}