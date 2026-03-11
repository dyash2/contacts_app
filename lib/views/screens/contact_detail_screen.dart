import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/contact_provider.dart';
import '../../models/contact_model.dart';
import '../../utils/app_theme.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/confirm_dialog.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
    }
  }

  Future<void> _email(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _delete(BuildContext context, Contact c) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Contact?',
      message:
          'Are you sure you want to delete ${c.name}? This action cannot be undone.',
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    final ok = await context.read<ContactProvider>().deleteContact(c.id!);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${c.name} deleted'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _openEdit(BuildContext context, Contact c) async {
    final provider = context.read<ContactProvider>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: AddEditContactScreen(contact: c),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final updated = context.select<ContactProvider, Contact?>(
      (ctrl) => ctrl.contacts.where((c) => c.id == contact.id).firstOrNull,
    );
    final c = updated ?? contact;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contact Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.read<ContactProvider>().toggleFavorite(c),
            child: Icon(
              c.isFavorite ? Icons.star : Icons.star_border,
              color: c.isFavorite ? Colors.yellowAccent : Colors.grey[400],
              size: 26,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') _openEdit(context, c);
              if (value == 'delete') _delete(context, c);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.edit, color: Colors.black),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  ContactAvatar(contact: c, radius: 44),
                  const SizedBox(height: 14),
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.phone,
                        label: 'Call',
                        onTap: () => _call(context, c.phone),
                      ),
                      const SizedBox(width: 24),
                      _ActionButton(
                        icon: Icons.email,
                        label: 'Email',
                        onTap: () => _email(context, c.email ?? ''),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _DetailRow(label: 'Mobile', value: c.phone),
                  if (c.email != null && c.email!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(label: 'Email', value: c.email!),
                  ],
                  if (c.company != null && c.company!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(label: 'Company', value: c.company!),
                  ],
                  if (c.address != null && c.address!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(label: 'Address', value: c.address!),
                  ],
                  if (c.notes != null && c.notes!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(label: 'Notes', value: c.notes!),
                  ],
                  const Divider(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ],
    );
  }
}
