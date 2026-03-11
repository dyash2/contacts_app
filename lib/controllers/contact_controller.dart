import '../models/contact_model.dart';
import '../utils/database_helper.dart';
import '../utils/app_theme.dart';

class ContactController {
  final DatabaseHelper _db;

  int _colorIndex = 0;

  ContactController({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  //  Read

  Future<List<Contact>> fetchAllContacts() async {
    final contacts = await _db.getAllContacts();
    _colorIndex = contacts.length;
    return contacts;
  }

  Future<List<Contact>> fetchFavorites() async {
    return _db.getFavoriteContacts();
  }

  Future<List<Contact>> searchContacts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    return _db.searchContacts(trimmed);
  }

  //  Write ─

  Future<int> addContact(Contact contact) async {
    final color = AppTheme.avatarColorForIndex(_colorIndex++);
    final colorHex = AppTheme.colorToHex(color);
    final enriched = contact.copyWith(avatarColor: colorHex);
    return _db.insertContact(enriched);
  }

  Future<void> updateContact(Contact contact) async {
    await _db.updateContact(contact);
  }

  Future<void> deleteContact(int id) async {
    await _db.deleteContact(id);
  }

  //  Favourite ─

  Future<void> toggleFavorite(Contact contact) async {
    await _db.toggleFavorite(contact.id!, contact.isFavorite);
  }

  //  Helpers ─

  Map<String, List<Contact>> groupByLetter(List<Contact> contacts) {
    final Map<String, List<Contact>> groups = {};
    for (final c in contacts) {
      final key = c.name.isNotEmpty ? c.name[0].toUpperCase() : '#';
      groups.putIfAbsent(key, () => []).add(c);
    }
    return Map.fromEntries(
      groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}
