import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/services/ContactService.dart';
import '../shared/custom_text_field.dart';
import 'contact/ContactPickerWidget.dart';

class ReceiverField extends StatelessWidget {
  final TextEditingController controller;
  final int index;
  final bool showRemoveButton;
  final VoidCallback onRemove;
  final ContactService contactService;
  final Function(List<String>) onContactsSelected;

  const ReceiverField({
    Key? key,
    required this.controller,
    required this.index,
    required this.showRemoveButton,
    required this.onRemove,
    required this.contactService,
    required this.onContactsSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Destinataire ${index + 1}",
                prefixIcon: const Icon(Icons.person),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.contacts),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => ContactPickerWidget(
                        multipleSelection: true,
                        contactService: contactService,
                        onContactsSelected: onContactsSelected,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (showRemoveButton)
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: onRemove,
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}
