import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/common_widgets.dart';
import '../../core/utils/date_helper.dart';
import '../../models/contact_model.dart';
import '../../providers/auth_provider.dart';
import 'add_contact_screen.dart';
import 'contact_detail_screen.dart';
import 'edit_contact_screen.dart';
import '../../providers/contacts_provider.dart';
import '../../core/widgets/custom_loader.dart';

class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final _searchController = TextEditingController();
  String _activeTab = 'All';
  final List<String> _filters = ['All', 'By Group'];

  String _selectedCityFilter = 'All';
  String _selectedProfessionFilter = 'All';

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
    ref.read(contactsProvider.notifier).loadContacts(search: value);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(isAdmin, sw),
      body: Column(
        children: [
          SizedBox(height: sh * 0.018),
          _buildSearchBar(hPad, searchHeight, sw),
          SizedBox(height: sh * 0.012),
          _buildFilterUI(contactsState.contacts, hPad, sw),
          SizedBox(height: sh * 0.01),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(contactsProvider.notifier).loadContacts(
                  search: _searchController.text,
                );
              },
              color: kPrimaryColor,
              child: Padding(
                padding: EdgeInsets.only(bottom: sh * 0.16),
                child: contactsState.isLoading
                    ? const Center(child: CustomLoader(message: "Loading..."))
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

  // ── Filter UI ─────────────────────────────────────────────────────────
  Widget _buildFilterUI(List<Contact> contacts, double hPad, double sw) {
    final cities = ['All', ...contacts.map((c) => c.city?.trim() ?? '').where((c) => c.isNotEmpty).toSet().toList()..sort()];
    final professions = ['All', ...contacts.map((c) => c.profession?.trim() ?? '').where((c) => c.isNotEmpty).toSet().toList()..sort()];

    if (!cities.contains(_selectedCityFilter)) _selectedCityFilter = 'All';
    if (!professions.contains(_selectedProfessionFilter)) _selectedProfessionFilter = 'All';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        children: [
          // Tabs
          SizedBox(
            height: sw * 0.12,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _activeTab == filter;
                return Padding(
                  padding: EdgeInsets.only(right: sw * 0.03),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = filter),
                    child: Chip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: sw * 0.032,
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
          ),
          SizedBox(height: sw * 0.02),
          // Dropdowns
          Row(
            children: [
              Expanded(child: _buildSmallDropdown("City", cities, _selectedCityFilter, (v) => setState(() => _selectedCityFilter = v!), sw)),
              SizedBox(width: sw * 0.02),
              Expanded(child: _buildSmallDropdown("Profession", professions, _selectedProfessionFilter, (v) => setState(() => _selectedProfessionFilter = v!), sw)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDropdown(String label, List<String> items, String value, Function(String?) onChanged, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.01),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(sw * 0.02),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: sw * 0.04),
          style: TextStyle(fontSize: sw * 0.032, color: kTextPrimary),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'All' ? '$label (All)' : item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
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
    final displayContacts = contacts.where((c) {
      if (_selectedCityFilter != 'All' && c.city?.trim() != _selectedCityFilter) return false;
      if (_selectedProfessionFilter != 'All' && c.profession?.trim() != _selectedProfessionFilter) return false;
      return true;
    }).toList();

    if (displayContacts.isEmpty) {
      return const Center(child: Text("No contacts match the selected filters"));
    }

    if (_activeTab == 'By Group') {
      final Map<String, List<Contact>> grouped = {};
      for (final contact in displayContacts) {
        if (contact.groups.isEmpty) {
          grouped.putIfAbsent('Uncategorized', () => []).add(contact);
        } else {
          for (final g in contact.groups) {
            grouped.putIfAbsent(g, () => []).add(contact);
          }
        }
      }
      final sortedGroups = grouped.keys.toList()..sort();
      
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: sortedGroups.length,
        itemBuilder: (context, index) {
          final groupName = sortedGroups[index];
          final groupContacts = grouped[groupName]!;
          return Padding(
            padding: EdgeInsets.only(bottom: sw * 0.03),
            child: AppCard(
              borderRadius: cardRadius,
              padding: EdgeInsets.all(sw * 0.02),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.01),
                leading: Container(
                  padding: EdgeInsets.all(sw * 0.025),
                  decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.style, color: kPrimaryColor, size: sw * 0.06),
                ),
                title: Text(groupName.toUpperCase(), style: TextStyle(color: kTextPrimary, fontSize: titleFontSize, fontWeight: FontWeight.bold)),
                subtitle: Text("${groupContacts.length} Contact${groupContacts.length == 1 ? '' : 's'}", style: TextStyle(color: kTextSecondary, fontSize: subFontSize)),
                trailing: Icon(Icons.chevron_right, color: kTextTertiary, size: iconSize),
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
              )
            ),
          );
        },
      );
    }

      // Default list view
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      itemCount: displayContacts.length,
      itemBuilder: (context, index) {
        return _buildContactCard(
          displayContacts[index], isAdmin, avatarRadius, titleFontSize, 
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contact.company != null && contact.company!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: sw * 0.008),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business, size: sw * 0.035, color: kPrimaryColor),
                        SizedBox(width: sw * 0.01),
                        Expanded(
                          child: Text(
                            contact.company!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: kPrimaryColor, fontSize: subFontSize, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  "${contact.designation ?? ''}${contact.designation != null && contact.city != null ? ' · ' : ''}${contact.city ?? ''}",
                  style: TextStyle(color: kTextSecondary, fontSize: subFontSize),
                ),
                // if (contact.upcomingEvent != null)
                //   Padding(
                //     padding: EdgeInsets.only(top: sw * 0.012),
                //     child: Container(
                //       padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.005),
                //       decoration: BoxDecoration(
                //         color: kPrimaryColor.withOpacity(0.1),
                //         borderRadius: BorderRadius.circular(sw * 0.01),
                //         border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Icon(Icons.event_note, size: sw * 0.03, color: kPrimaryColor),
                //           SizedBox(width: sw * 0.01),
                //           Text(
                //             "${contact.upcomingEvent!['name']}: ${DateHelper.countdownText(contact.upcomingEvent!['days'])}",
                //             style: TextStyle(
                //               color: kPrimaryColor,
                //               fontSize: sw * 0.026,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
              ],
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
        backgroundColor: Theme.of(context).dialogBackgroundColor,
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
        backgroundColor: Theme.of(context).dialogBackgroundColor,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (contact.company != null && contact.company!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: sw * 0.008),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.business, size: sw * 0.035, color: kPrimaryColor),
                                    SizedBox(width: sw * 0.01),
                                    Expanded(
                                      child: Text(
                                        contact.company!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kPrimaryColor, fontSize: subFontSize, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              "${contact.designation ?? ''}${contact.designation != null && contact.city != null ? ' · ' : ''}${contact.city ?? ''}",
                              style: TextStyle(color: kTextSecondary, fontSize: subFontSize),
                            ),
                          ],
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

