import 'package:flutter/material.dart';
import '../../../../core/services/ContactService.dart';
import 'ContactPickerDialog.dart';

class ContactPickerWidget extends StatelessWidget {
  final bool multipleSelection;
  final Function(List<String>) onContactsSelected;
  final ContactService contactService;

   ContactPickerWidget({
    Key? key,
    required this.multipleSelection,
    required this.onContactsSelected,
    required this.contactService,
  }) : super(key: key);

  // Initialize the search controller for filtering contacts
  final TextEditingController searchController = TextEditingController();

  Future<void> _pickContacts(BuildContext context) async {
    try {
      // Récupérer les contacts
      final contacts = await contactService.fetchContacts();

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun contact disponible")),
        );
        return;
      }

      // Afficher la boîte de dialogue pour sélectionner les contacts
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => ContactPickerDialog(
          contacts: contacts,
          multipleSelection: multipleSelection,
          searchController: searchController, // Pass the search controller
          label: 'Rechercher un contact', // Provide the label for search
          onContactsSelected: onContactsSelected, // Callback to return selected contacts
        ),
      );
    } catch (e) {
      // Gestion des erreurs générales
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.contacts),
      onPressed: () => _pickContacts(context),
    );
  }
}
