import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';
import '../../models/contact_model.dart';
import '../widgets/contact_list_tile.dart';
import 'contact_detail_screen.dart';

class ContactsTab extends StatelessWidget {
  const ContactsTab({super.key});

  void _openDetail(BuildContext context, Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ContactProvider>(),
          child: ContactDetailScreen(contact: contact),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, ctrl, _) {
        if (ctrl.status == ContactStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3D5A99)),
          );
        }

        final grouped = ctrl.groupedContacts;
        final keys = grouped.keys.toList();

        if (keys.isEmpty) {
          return _EmptyState(
            icon: Icons.contacts_outlined,
            title: ctrl.isSearching ? 'No results found' : 'No contacts yet',
            subtitle: ctrl.isSearching
                ? 'Try a different search term'
                : 'Tap + to add your first contact',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: keys.length,
          itemBuilder: (_, sectionIdx) {
            final key = keys[sectionIdx];
            final contacts = grouped[key]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFFF2F4F8),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3D5A99),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: contacts
                        .map(
                          (c) => ContactListTile(
                            contact: c,
                            onTap: () => _openDetail(context, c),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
