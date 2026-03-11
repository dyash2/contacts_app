import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import 'contact_avatar.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ContactAvatar(contact: contact, radius: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (contact.phone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        contact.phone,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
            ),
            if (contact.isFavorite)
              const Icon(Icons.star, color: Color(0xFF3D5A99), size: 20),
          ],
        ),
      ),
    );
  }
}
