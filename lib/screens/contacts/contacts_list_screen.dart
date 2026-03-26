import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';
import 'add_contact_screen.dart';
import 'contact_detail_screen.dart';
import 'edit_contact_screen.dart';
import '../../providers/auth_provider.dart';

class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _activeFilter = 'All';

  final List<String> _filters = ['All', 'By City', 'By Profession', 'A-Z', 'Z-A'];

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.045;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(isAdmin),
      body: Column(
        children: [
          _buildSearchBar(horizontalPadding),
          _buildFilterChips(horizontalPadding),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 110),
              child: _buildContactsList(isAdmin, horizontalPadding),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isAdmin) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: const Text("Contacts"),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddContactScreen())),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
      child: AppCard(
        borderRadius: 30,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: kTextPrimary),
          decoration: const InputDecoration(
            hintText: AppStrings.searchHint,
            prefixIcon: Icon(Icons.search, color: kTextSecondary),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            // Logic to filter contacts
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(double horizontalPadding) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: horizontalPadding),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: horizontalPadding),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = filter),
              child: Chip(
                label: Text(filter),
                backgroundColor: isSelected ? kPrimaryColor : kInputBg,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : kTextSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactsList(bool isAdmin, double horizontalPadding) {
    // Mock data
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            borderRadius: 16,
            child: ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: "contact_$index"))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const GradientAvatar(radius: 24, initials: "TA"),
              title: const Text(
                "Tahir Ahmed",
                style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: const Text(
                "Software Engineer · Lahore",
                style: TextStyle(color: kTextSecondary, fontSize: 12),
              ),
              trailing: isAdmin ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: kTextSecondary, size: 20),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditContactScreen(contactId: "contact_$index"))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: kError, size: 20),
                    onPressed: () {},
                  ),
                ],
              ) : const Icon(Icons.chevron_right, color: kTextTertiary),
            ),
          ),
        );
      },
    );
  }
}
