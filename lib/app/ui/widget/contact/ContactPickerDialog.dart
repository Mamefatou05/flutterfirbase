import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactPickerDialog extends StatefulWidget {
  final List<Contact> contacts;
  final bool multipleSelection;
  final TextEditingController searchController; // Contrôleur pour la recherche
  final String label; // Label pour la recherche
  final Function(List<String>) onContactsSelected; // Ajout du callback ici

  const ContactPickerDialog({
    Key? key,
    required this.contacts,
    this.multipleSelection = false,
    required this.searchController, // Ajoutez le contrôleur ici
    required this.label, // Ajoutez le label ici
    required this.onContactsSelected, // Ajout du callback ici
  }) : super(key: key);

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  late List<Contact> filteredContacts;
  final Set<Contact> selectedContacts = {};

  @override
  void initState() {
    super.initState();
    filteredContacts = widget.contacts.toList();
  }

  void _filterContacts(String query) {
    setState(() {
      filteredContacts = widget.contacts.where((contact) {
        final name = contact.displayName?.toLowerCase() ?? '';
        final phone = contact.phones?.firstOrNull?.value?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || phone.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.multipleSelection ? 'Sélectionner des contacts' : 'Sélectionner un contact'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: 'Rechercher un contact...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterContacts,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                itemCount: filteredContacts.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  final hasPhone = contact.phones?.isNotEmpty ?? false;

                  if (widget.multipleSelection) {
                    return CheckboxListTile(
                      value: selectedContacts.contains(contact),
                      onChanged: hasPhone ? (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedContacts.add(contact);
                          } else {
                            selectedContacts.remove(contact);
                          }
                        });
                      } : null,
                      title: Text(contact.displayName ?? 'Sans nom'),
                      subtitle: Text(
                          hasPhone ? (contact.phones!.first.value ?? '') : 'Pas de numéro'
                      ),
                      enabled: hasPhone,
                      secondary: CircleAvatar(
                        child: Text(contact.displayName?[0].toUpperCase() ?? '?'),
                      ),
                    );
                  } else {
                    // Mode sélection simple
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(contact.displayName?[0].toUpperCase() ?? '?'),
                      ),
                      title: Text(contact.displayName ?? 'Sans nom'),
                      subtitle: Text(
                          hasPhone ? (contact.phones!.first.value ?? '') : 'Pas de numéro'
                      ),
                      enabled: hasPhone,
                      onTap: hasPhone
                          ? () => Navigator.of(context).pop(
                          [contact.phones!.first.value!.replaceAll(RegExp(r'[^\d+]'), '')]
                      )
                          : null,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        if (widget.multipleSelection)
          ElevatedButton(
            onPressed: selectedContacts.isNotEmpty
                ? () {
              widget.onContactsSelected(
                selectedContacts
                    .map((c) => c.phones!.first.value!.replaceAll(RegExp(r'[^\d+]'), ''))
                    .toList(),
              );
              Navigator.of(context).pop();
            }
                : null,
            child: Text('Sélectionner (${selectedContacts.length})'),
          ),
      ],
    );
  }
}
