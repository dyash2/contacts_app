import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';
import '../../models/contact_model.dart';
import '../widgets/contact_list_tile.dart';
import 'contact_detail_screen.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

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
        final List<Contact> displayList = ctrl.isSearching
            ? ctrl.searchResults.where((c) => c.isFavorite).toList()
            : ctrl.favorites;

        if (displayList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  ctrl.isSearching ? Icons.search_off : Icons.favorite_border,
                  size: 72,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  ctrl.isSearching
                      ? 'No matching favorites'
                      : 'No favorites yet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ctrl.isSearching
                      ? 'Try a different search term'
                      : 'Star a contact to see them here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: displayList.length,
          itemBuilder: (_, i) => Container(
            color: Colors.white,
            child: ContactListTile(
              contact: displayList[i],
              onTap: () => _openDetail(context, displayList[i]),
            ),
          ),
        );
      },
    );
  }
}
