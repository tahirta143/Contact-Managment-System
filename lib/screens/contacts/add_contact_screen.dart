import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/contacts_provider.dart';
import '../../models/contact_event_model.dart';

const Color kBirthdayColor    = Color(0xFFFF6B9D);
const Color kAnniversaryColor = Color(0xFFFF9500);

class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController             = TextEditingController();
  final _designationController      = TextEditingController();
  final _referenceController        = TextEditingController();
  final _professionController       = TextEditingController();
  final _companyController          = TextEditingController();
  final _specialityController       = TextEditingController();
  final _phoneController            = TextEditingController();
  final _mobileController           = TextEditingController();
  final _whatsappController         = TextEditingController();
  final _addressController          = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _cityController             = TextEditingController();

  DateTime? _birthday;
  DateTime? _anniversary;
  int _reminderDays = 1;
  
  String? _imagePath;
  final List<ContactEvent> _customEvents = [];
  final List<String> _selectedGroups = [];
  final TextEditingController _groupController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _referenceController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _specialityController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _permanentAddressController.dispose();
    _cityController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) setState(() => _imagePath = pickedFile.path);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) setState(() => _imagePath = pickedFile.path);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addCustomEvent() {
    if (_customEvents.isNotEmpty && (_customEvents.last.label?.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill the previous event label before adding a new one."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _customEvents.add(ContactEvent(
        type: 'Other',
        date: DateTime.now(),
        label: '',
      ));
    });
  }

  void _removeCustomEvent(int index) {
    setState(() {
      _customEvents.removeAt(index);
    });
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGroups.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least one group."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      final contactData = {
        "name": _nameController.text.trim(),
        "designation": _designationController.text.trim(),
        "reference": _referenceController.text.trim(),
        "profession": _professionController.text.trim(),
        "company": _companyController.text.trim(),
        "speciality": _specialityController.text.trim(),
        "phone": _phoneController.text.trim(),
        "mobile": _mobileController.text.trim(),
        "whatsapp": _whatsappController.text.trim(),
        "address": _addressController.text.trim(),
        "permanentAddress": _permanentAddressController.text.trim(),
        "city": _cityController.text.trim(),
        "birthday": _birthday?.toIso8601String().split('T')[0],
        "anniversary": _anniversary?.toIso8601String().split('T')[0],
        "events": _customEvents.map((e) => e.toJson()).toList(),
        "groups": _selectedGroups.join(','),
      };

      await ref.read(contactsProvider.notifier).addContact(contactData, imagePath: _imagePath);
      
      final error = ref.read(contactsProvider).error;
      if (error == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Contact saved successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size         = MediaQuery.of(context).size;
    final sw           = size.width;
    final sh           = size.height;
    final hPad         = sw * 0.05;
    final avatarRadius = sw * 0.15;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: sw * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Contact",
          style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: sw * 0.038),
            ),
          ),
          SizedBox(width: sw * 0.02),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sh * 0.02),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPhotoSection(avatarRadius, sw),
              SizedBox(height: sh * 0.035),

              _buildGroupsSection(context, sw, sh),
              SizedBox(height: sh * 0.028),

              _buildSectionHeader(context, "Personal Info"),
              _buildTextField(context, _nameController, "Full Name*", Icons.person_outline, required: true),
              _buildTextField(context, _designationController, "Designation", Icons.work_outline),
              _buildTextField(context, _referenceController, "Reference", Icons.people_outline),
              _buildTextField(context, _professionController, "Profession", Icons.business_center_outlined),
              _buildTextField(context, _companyController, "Company", Icons.apartment_outlined),
              _buildTextField(context, _specialityController, "Speciality", Icons.star_outline),

              SizedBox(height: sh * 0.028),
              _buildSectionHeader(context, "Contact Details"),
              _buildTextField(context, _phoneController, "Phone", Icons.phone_outlined, keyboard: TextInputType.phone),
              _buildTextField(context, _mobileController, "Mobile", Icons.smartphone, keyboard: TextInputType.phone),
              _buildTextField(context, _whatsappController, "WhatsApp", Icons.chat_outlined, keyboard: TextInputType.phone),

              SizedBox(height: sh * 0.028),
              _buildSectionHeader(context, "Address"),
              _buildTextField(context, _addressController, "Current Address", Icons.location_on_outlined, maxLines: 2),
              _buildTextField(context, _permanentAddressController, "Permanent Address", Icons.home_outlined, maxLines: 2),
              _buildTextField(context, _cityController, "City", Icons.location_city),

              SizedBox(height: sh * 0.028),
              _buildSectionHeader(context, "Important Dates"),
              _buildDatePicker(context, "Birthday", _birthday, (d) => setState(() => _birthday = d), Icons.cake_outlined, kBirthdayColor),
              _buildDatePicker(context, "Anniversary", _anniversary, (d) => setState(() => _anniversary = d), Icons.favorite_outline, kAnniversaryColor),

              SizedBox(height: sh * 0.028),
              _buildDynamicEventsSection(context, sw, sh),

              SizedBox(height: sh * 0.028),
              _buildReminderSection(context, sw),

              SizedBox(height: sh * 0.048),
              _buildSaveButton(context, sw, sh),
              SizedBox(height: sh * 0.048),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(double avatarRadius, double sw) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            _imagePath != null
                ? CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: FileImage(File(_imagePath!)),
                  )
                : GradientAvatar(radius: avatarRadius, initials: ""),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(sw * 0.022),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: sw * 0.048),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {Widget? trailing}) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.018),
      child: Row(
        children: [
          Container(width: sw * 0.008, height: sh * 0.022, color: Theme.of(context).primaryColor),
          SizedBox(width: sw * 0.025),
          Text(
            title,
            style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: sw * 0.038, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          if (trailing != null) ...[
            SizedBox(width: sw * 0.02),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String hint, IconData icon, {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.014),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: sw * 0.034),
          prefixIcon: Icon(icon, size: sw * 0.052),
          contentPadding: EdgeInsets.symmetric(vertical: sh * 0.018, horizontal: sw * 0.04),
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
        validator: required ? (v) => (v == null || v.isEmpty) ? "$hint is required" : null : null,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? value, Function(DateTime) onSelect, IconData icon, Color accent) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.014),
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) onSelect(date);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.018),
          decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: [
              Icon(icon, color: accent, size: sw * 0.055),
              SizedBox(width: sw * 0.03),
              Text(
                value != null ? DateFormat('d MMMM yyyy').format(value) : "Select $label",
                style: TextStyle(color: value != null ? Theme.of(context).textTheme.titleLarge?.color : Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w600, fontSize: sw * 0.036),
              ),
              const Spacer(),
              Icon(Icons.calendar_today_outlined, color: Theme.of(context).textTheme.labelSmall?.color, size: sw * 0.045),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsSection(BuildContext context, double sw, double sh) {
    final allContacts = ref.read(contactsProvider).contacts;
    final Set<String> allExistingGroups = {};
    for (final c in allContacts) {
      allExistingGroups.addAll(c.groups);
    }
    final availableGroups = allExistingGroups.where((g) => !_selectedGroups.contains(g)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, "Groups *"),
        // Tag input
        Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.012),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(Icons.group_outlined, color: Theme.of(context).textTheme.bodyMedium?.color, size: sw * 0.052),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: TextField(
                  controller: _groupController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: sw * 0.036),
                  decoration: InputDecoration(
                    hintText: "Type group name and press Enter",
                    hintStyle: TextStyle(fontSize: sw * 0.033, color: Theme.of(context).textTheme.bodyMedium?.color),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    final trimmed = val.trim();
                    if (trimmed.isNotEmpty && !_selectedGroups.contains(trimmed)) {
                      setState(() => _selectedGroups.add(trimmed));
                    }
                    _groupController.clear();
                  },
                ),
              ),
              if (availableGroups.isNotEmpty)
                PopupMenuButton<String>(
                  icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyMedium?.color, size: sw * 0.06),
                  tooltip: "Select from previous groups",
                  onSelected: (val) {
                    setState(() => _selectedGroups.add(val));
                  },
                  itemBuilder: (context) {
                    return availableGroups.map((g) => PopupMenuItem(value: g, child: Text(g))).toList();
                  },
                ),
              GestureDetector(
                onTap: () {
                  final trimmed = _groupController.text.trim();
                  if (trimmed.isNotEmpty && !_selectedGroups.contains(trimmed)) {
                    setState(() => _selectedGroups.add(trimmed));
                  }
                  _groupController.clear();
                },
                child: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: sw * 0.06),
              ),
            ],
          ),
        ),
        if (_selectedGroups.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: sh * 0.008, left: sw * 0.02),
            child: Text(
              "* At least one group is required",
              style: TextStyle(color: Colors.red.shade400, fontSize: sw * 0.029),
            ),
          ),
        if (_selectedGroups.isNotEmpty) ...[
          SizedBox(height: sh * 0.012),
          Wrap(
            spacing: sw * 0.02,
            runSpacing: sh * 0.008,
            children: _selectedGroups.map((group) {
              return Chip(
                label: Text(group, style: TextStyle(color: Colors.white, fontSize: sw * 0.032)),
                backgroundColor: Theme.of(context).primaryColor,
                deleteIconColor: Colors.white70,
                onDeleted: () => setState(() => _selectedGroups.remove(group)),
                padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDynamicEventsSection(BuildContext context, double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          "Custom Events",
          trailing: TextButton.icon(
            onPressed: _addCustomEvent,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Add Event"),
          ),
        ),
        ...List.generate(_customEvents.length, (index) {
          final event = _customEvents[index];
          return AppCard(
            borderRadius: 15,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: event.type,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ['Meeting', 'Work', 'Personal', 'Other'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _customEvents[index] = ContactEvent(
                              type: val!,
                              date: event.date,
                              label: event.label,
                            );
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeCustomEvent(index),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: event.date,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _customEvents[index] = ContactEvent(
                          type: event.type,
                          date: date,
                          label: event.label,
                        );
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 20, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(DateFormat('d MMM yyyy').format(event.date), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Label (e.g. First Meeting)",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _customEvents[index] = ContactEvent(
                        type: event.type,
                        date: event.date,
                        label: val,
                      );
                    });
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReminderSection(BuildContext context, double sw) {
    return Row(
      children: [
        Icon(Icons.notifications_active_outlined, color: Theme.of(context).textTheme.bodyMedium?.color, size: sw * 0.05),
        SizedBox(width: sw * 0.03),
        Text("Remind me", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: sw * 0.036)),
        const Spacer(),
        DropdownButton<int>(
          value: _reminderDays,
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          icon: Icon(Icons.keyboard_arrow_down, size: sw * 0.05),
          items: [0, 1, 2, 3, 7].map((val) {
            return DropdownMenuItem<int>(
              value: val,
              child: Text(
                val == 0 ? "Same day" : "$val day(s) before",
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.033),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _reminderDays = val ?? 1),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, double sw, double sh) {
    final isLoading = ref.watch(contactsProvider).isLoading;
    return SizedBox(
      width: double.infinity,
      height: sh * 0.065,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.075)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("SAVE CONTACT", style: TextStyle(fontSize: sw * 0.038, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
