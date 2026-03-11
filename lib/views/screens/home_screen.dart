import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/contact_provider.dart';
import '../../utils/app_theme.dart';
import 'contacts_tab.dart';
import 'favorites_tab.dart';
import 'add_edit_contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late final AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  void _startSearch() {
    context.read<ContactProvider>().startSearch();
    _searchFocus.requestFocus();
    setState(() {});
  }

  void _stopSearch() {
    _searchFocus.unfocus();
    _searchCtrl.clear();
    context.read<ContactProvider>().stopSearch();
    setState(() {});
  }

  Future<void> _openAddContact() async {
    _searchFocus.unfocus();
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ChangeNotifierProvider.value(
          value: context.read<ContactProvider>(),
          child: const AddEditContactScreen(),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ContactProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            isSearching: ctrl.isSearching,
            onTap: _startSearch,
            onChanged: (q) => ctrl.search(q),
            onClear: () {
              _searchCtrl.clear();
              ctrl.search('');
              _searchFocus.requestFocus();
            },
            onBack: _stopSearch,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _currentIndex == 0
                  ? const ContactsTab(key: ValueKey('contacts'))
                  : const FavoritesTab(key: ValueKey('favorites')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: _currentIndex == 0
            ? FloatingActionButton(
                key: const ValueKey('fab'),
                onPressed: _openAddContact,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 28),
              )
            : const SizedBox.shrink(key: ValueKey('no_fab')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.appBarBg,
      elevation: 0,
      title: Text(
        _currentIndex == 0 ? 'Contacts' : 'Favorites',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        _searchFocus.unfocus();
        setState(() => _currentIndex = i);
        if (context.read<ContactProvider>().isSearching) {
          _stopSearch();
        }
      },
      backgroundColor: Colors.white,
      elevation: 8,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: Colors.grey[400],
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts_outlined),
          activeIcon: Icon(Icons.contacts),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onTap,
    required this.onChanged,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.appBarBg,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSearching)
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                color: Colors.grey[600],
                onPressed: onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.search, color: Colors.grey[400], size: 20),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onTap: onTap,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            if (isSearching && controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: Colors.grey[500],
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40),
              ),
          ],
        ),
      ),
    );
  }
}
