import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../utils/app_theme.dart';

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double radius;

  const ContactAvatar({super.key, required this.contact, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.avatarColorFromHex(contact.avatarColor);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        contact.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
