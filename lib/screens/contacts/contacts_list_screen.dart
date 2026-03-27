import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/common_widgets.dart';
import '../../models/contact_model.dart';
import 'add_contact_screen.dart';
import 'contact_detail_screen.dart';
import 'edit_contact_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';

class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'All';

  final List<String> _filters = ['All', 'By Group', 'By City', 'By Profession', 'A-Z', 'Z-A'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(contactsProvider.notifier).loadContacts(
      search: value,
      filter: _activeFilter == 'All' ? null : _activeFilter,
    );
  }

  void _onFilterChanged(String filter) {
    setState(() => _activeFilter = filter);
    ref.read(contactsProvider.notifier).loadContacts(
      search: _searchController.text,
      filter: (filter == 'All' || filter == 'By Group') ? null : filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    // ── MediaQuery values ──────────────────────────────────────────────────
    final size           = MediaQuery.of(context).size;
    final sw             = size.width;
    final sh             = size.height;
    final hPad           = sw * 0.045;          // horizontal padding
    final searchHeight   = sh * 0.058;          // search bar height
    final filterHeight   = sh * 0.058;          // filter row height
    final avatarRadius   = sw * 0.06;           // contact avatar radius
    final titleFontSize  = sw * 0.038;          // contact name font size
    final subFontSize    = sw * 0.030;          // subtitle font size
    final iconSize       = sw * 0.055;          // trailing icon size
    final cardRadius     = sw * 0.04;           // card border radius
    final itemSpacing    = sh * 0.014;          // spacing between list items
    final chipFontSize   = sw * 0.032;          // filter chip label font size

    final contactsState = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: _buildAppBar(isAdmin, sw),
      body: Column(
        children: [
          SizedBox(height: sh * 0.018),
          _buildSearchBar(hPad, searchHeight, sw),
          SizedBox(height: sh * 0.008),
          _buildFilterChips(hPad, filterHeight, chipFontSize),
          SizedBox(height: sh * 0.01),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: sh * 0.13),
              child: contactsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : contactsState.error != null
                      ? Center(child: Text(contactsState.error!))
                      : contactsState.contacts.isEmpty
                          ? const Center(child: Text("No contacts found"))
                          : _buildContactsList(
                              contactsState.contacts,
                              isAdmin, hPad, avatarRadius,
                              titleFontSize, subFontSize,
                              iconSize, cardRadius, itemSpacing, sw,
                            ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isAdmin, double sw) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, size: sw * 0.06),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        "Contacts",
        style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold),
      ),
      actions: [
        if (isAdmin)
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white, size: sw * 0.065),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddContactScreen()),
            ),
          ),
        SizedBox(width: sw * 0.02),
      ],
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar(double hPad, double height, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: AppCard(
        borderRadius: height / 2,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: kTextPrimary, fontSize: sw * 0.035),
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle: TextStyle(fontSize: sw * 0.034),
            prefixIcon: Icon(Icons.search, color: kTextSecondary, size: sw * 0.055),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  // ── Filter chips ─────────────────────────────────────────────────────────
  Widget _buildFilterChips(double hPad, double height, double chipFontSize) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: hPad, right: hPad),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: hPad * 0.4),
            child: GestureDetector(
              onTap: () => _onFilterChanged(filter),
              child: Chip(
                label: Text(
                  filter,
                  style: TextStyle(
                    fontSize: chipFontSize,
                    color: isSelected ? Colors.white : kTextSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                backgroundColor: isSelected ? kPrimaryColor : kInputBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactsList(
      List<Contact> contacts,
      bool isAdmin,
      double hPad,
      double avatarRadius,
      double titleFontSize,
      double subFontSize,
      double iconSize,
      double cardRadius,
      double itemSpacing,
      double sw,
      ) {
    
    if (_activeFilter == 'By Group') {
      final Map<String, List<Contact>> grouped = {};
      for (final contact in contacts) {
        if (contact.groups.isEmpty) {
          grouped.putIfAbsent('Uncategorized', () => []).add(contact);
        } else {
          for (final g in contact.groups) {
            grouped.putIfAbsent(g, () => []).add(contact);
          }
        }
      }
      final sortedGroups = grouped.keys.toList()..sort();
      
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sw * 0.02),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: sw * 0.03,
          mainAxisSpacing: sw * 0.03,
          childAspectRatio: 1.25,
        ),
        itemCount: sortedGroups.length,
        itemBuilder: (context, index) {
          final groupName = sortedGroups[index];
          final groupContacts = grouped[groupName]!;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupContactsScreen(
                    groupName: groupName,
                    contacts: groupContacts,
                    isAdmin: isAdmin,
                  ),
                ),
              );
            },
            child: AppCard(
              borderRadius: cardRadius,
              padding: EdgeInsets.all(sw * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style, color: kPrimaryColor, size: sw * 0.08),
                  SizedBox(height: sw * 0.02),
                  Text(
                    groupName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sw * 0.01),
                  Text(
                    "${groupContacts.length} Contact${groupContacts.length == 1 ? '' : 's'}",
                    style: TextStyle(color: kTextSecondary, fontSize: subFontSize),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Default list view
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return _buildContactCard(
          contacts[index], isAdmin, avatarRadius, titleFontSize, 
          subFontSize, iconSize, cardRadius, itemSpacing, sw,
        );
      },
    );
  }

  Widget _buildContactCard(
      Contact contact,
      bool isAdmin,
      double avatarRadius,
      double titleFontSize,
      double subFontSize,
      double iconSize,
      double cardRadius,
      double itemSpacing,
      double sw,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: itemSpacing),
      child: AppCard(
        borderRadius: cardRadius,
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContactDetailScreen(contactId: contact.id),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sw * 0.02,
          ),
          leading: contact.photoUrl != null
              ? CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: CachedNetworkImageProvider(
                    contact.photoUrl!.startsWith('http')
                        ? contact.photoUrl!
                        : "${ApiConstants.baseImageUrl}${contact.photoUrl}",
                  ),
                )
              : GradientAvatar(
                  radius: avatarRadius,
                  initials: contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
                ),
          title: Text(
            contact.name,
            style: TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: sw * 0.008),
            child: Text(
              "${contact.designation ?? ''}${contact.designation != null && contact.city != null ? ' · ' : ''}${contact.city ?? ''}",
              style: TextStyle(color: kTextSecondary, fontSize: subFontSize),
            ),
          ),
          trailing: isAdmin
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: kTextSecondary, size: iconSize),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditContactScreen(contactId: contact.id),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: kError, size: iconSize),
                onPressed: () => _confirmDelete(context, contact.id),
              ),
            ],
          )
              : Icon(Icons.chevron_right, color: kTextTertiary, size: iconSize * 1.2),
        ),
      ),
    );
  }

  // ── Delete confirmation ──────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, String contactId) {
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.04)),
        title: Text(
          "Delete Contact",
          style: TextStyle(color: kTextPrimary, fontSize: sw * 0.045),
        ),
        content: Text(
          "Are you sure you want to delete this contact?",
          style: TextStyle(color: kTextSecondary, fontSize: sw * 0.035),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: kTextTertiary, fontSize: sw * 0.035)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(contactsProvider.notifier).deleteContact(contactId);
              
              if (mounted) {
                final error = ref.read(contactsProvider).error;
                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contact deleted"), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text("DELETE", style: TextStyle(color: kError, fontSize: sw * 0.035, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Group Contacts Screen ───────────────────────────────────────────────────
class GroupContactsScreen extends ConsumerStatefulWidget {
  final String groupName;
  final List<Contact> contacts;
  final bool isAdmin;

  const GroupContactsScreen({
    super.key,
    required this.groupName,
    required this.contacts,
    required this.isAdmin,
  });

  @override
  ConsumerState<GroupContactsScreen> createState() => _GroupContactsScreenState();
}

class _GroupContactsScreenState extends ConsumerState<GroupContactsScreen> {
  late List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = widget.contacts;
  }

  void _confirmDelete(BuildContext context, String contactId) {
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.04)),
        title: Text("Delete Contact", style: TextStyle(color: kTextPrimary, fontSize: sw * 0.045)),
        content: Text("Are you sure you want to delete this contact?", style: TextStyle(color: kTextSecondary, fontSize: sw * 0.035)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: kTextSecondary, fontSize: sw * 0.035)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.02)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(contactsProvider.notifier).deleteContact(contactId);
              if (mounted) {
                setState(() {
                  _contacts.removeWhere((c) => c.id == contactId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Contact deleted"), backgroundColor: Colors.red),
                );
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.white, fontSize: sw * 0.035)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hPad = sw * 0.045;
    final avatarRadius = sw * 0.06;
    final titleFontSize = sw * 0.038;
    final subFontSize = sw * 0.030;
    final iconSize = sw * 0.055;
    final cardRadius = sw * 0.04;
    final itemSpacing = MediaQuery.of(context).size.height * 0.014;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: sw * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.groupName.toUpperCase(),
          style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold),
        ),
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text("No contacts in this group"))
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sw * 0.04),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: itemSpacing),
                  child: AppCard(
                    borderRadius: cardRadius,
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContactDetailScreen(contactId: contact.id),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
                      leading: contact.photoUrl != null
                          ? CircleAvatar(
                              radius: avatarRadius,
                              backgroundImage: CachedNetworkImageProvider(
                                contact.photoUrl!.startsWith('http')
                                    ? contact.photoUrl!
                                    : "${ApiConstants.baseImageUrl}${contact.photoUrl}",
                              ),
                            )
                          : GradientAvatar(
                              radius: avatarRadius,
                              initials: contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
                            ),
                      title: Text(
                        contact.name,
                        style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: titleFontSize),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: sw * 0.008),
                        child: Text(
                          "${contact.designation ?? ''}${contact.designation != null && contact.city != null ? ' · ' : ''}${contact.city ?? ''}",
                          style: TextStyle(color: kTextSecondary, fontSize: subFontSize),
                        ),
                      ),
                      trailing: widget.isAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: kTextSecondary, size: iconSize),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditContactScreen(contactId: contact.id)),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: kError, size: iconSize),
                                  onPressed: () => _confirmDelete(context, contact.id),
                                ),
                              ],
                            )
                          : Icon(Icons.chevron_right, color: kTextTertiary, size: iconSize * 1.2),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

