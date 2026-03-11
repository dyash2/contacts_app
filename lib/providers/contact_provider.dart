import 'package:flutter/foundation.dart';
import '../controllers/contact_controller.dart';
import '../models/contact_model.dart';

enum ContactStatus { initial, loading, loaded, error }

class ContactProvider extends ChangeNotifier {
  final ContactController _controller;

  ContactProvider({ContactController? controller})
    : _controller = controller ?? ContactController();

  List<Contact> _contacts = [];
  List<Contact> _favorites = [];
  List<Contact> _searchResults = [];

  ContactStatus _status = ContactStatus.initial;
  String? _errorMessage;
  bool _isSearching = false;
  String _searchQuery = '';

  List<Contact> get contacts => _contacts;
  List<Contact> get favorites => _favorites;
  List<Contact> get searchResults => _searchResults;
  ContactStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  Map<String, List<Contact>> get groupedContacts {
    final list = _isSearching ? _searchResults : _contacts;
    return _controller.groupByLetter(list);
  }

  //  Load

  Future<void> loadContacts() async {
    _setStatus(ContactStatus.loading);
    try {
      _contacts = await _controller.fetchAllContacts();
      _favorites = await _controller.fetchFavorites();
      _setStatus(ContactStatus.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  //  Search

  void startSearch() {
    _isSearching = true;
    notifyListeners();
  }

  void stopSearch() {
    _isSearching = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    try {
      _searchResults = await _controller.searchContacts(query);
    } catch (_) {
      _searchResults = [];
    }
    notifyListeners();
  }

  //  CRUD

  Future<bool> addContact(Contact contact) async {
    try {
      await _controller.addContact(contact);
      await loadContacts();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateContact(Contact contact) async {
    try {
      await _controller.updateContact(contact);
      await loadContacts();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteContact(int id) async {
    try {
      await _controller.deleteContact(id);
      await loadContacts();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  //  Favourite ─

  Future<void> toggleFavorite(Contact contact) async {
    try {
      await _controller.toggleFavorite(contact);
      await loadContacts();
    } catch (e) {
      _setError(e.toString());
    }
  }

  //  Helpers ─

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setStatus(ContactStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = ContactStatus.error;
    notifyListeners();
  }
}
