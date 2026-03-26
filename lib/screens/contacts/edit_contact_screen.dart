import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';

class EditContactScreen extends StatefulWidget {
  final String contactId;
  const EditContactScreen({super.key, required this.contactId});

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers (Pre-filled for Edit)
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _referenceController;
  late TextEditingController _professionController;
  late TextEditingController _specialityController;
  late TextEditingController _phoneController;
  late TextEditingController _mobileController;
  late TextEditingController _whatsappController;
  late TextEditingController _addressController;
  late TextEditingController _permanentAddressController;
  late TextEditingController _cityController;

  DateTime? _birthday;
  DateTime? _anniversary;
  int _reminderDays = 3;

  @override
  void initState() {
    super.initState();
    // In a real app, you'd load contact data from a provider
    _nameController = TextEditingController(text: "Tahir Ahmed");
    _designationController = TextEditingController(text: "Senior Software Engineer");
    _referenceController = TextEditingController(text: "Self");
    _professionController = TextEditingController(text: "Software Engineer");
    _specialityController = TextEditingController(text: "Flutter/Dart");
    _phoneController = TextEditingController(text: "+92 300 1234567");
    _mobileController = TextEditingController(text: "+92 321 7654321");
    _whatsappController = TextEditingController(text: "+92 300 1234567");
    _addressController = TextEditingController(text: "Street 12, Model Town");
    _permanentAddressController = TextEditingController(text: "N/A");
    _cityController = TextEditingController(text: "Lahore");
    _birthday = DateTime(1998, 9, 10);
    _anniversary = DateTime(2013, 1, 15);
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact updated successfully!"), backgroundColor: kPrimaryColor),
      );
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Contact", style: TextStyle(color: kTextPrimary)),
        content: const Text("Are you sure you want to delete this contact?", style: TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: kTextTertiary))),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // return to list
            },
            child: const Text("DELETE", style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(horizontalPadding),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildPhotoSection(size.width),
                        const SizedBox(height: 30),
                        _buildSectionHeader("Personal Info"),
                        _buildTextField(_nameController, "Full Name*", Icons.person_outline, required: true),
                        _buildTextField(_designationController, "Designation", Icons.work_outline),
                        _buildTextField(_referenceController, "Reference", Icons.people_outline),
                        _buildTextField(_professionController, "Profession", Icons.business_center_outlined),
                        _buildTextField(_specialityController, "Speciality", Icons.star_outline),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader("Contact Details"),
                        _buildTextField(_phoneController, "Phone", Icons.phone_outlined, keyboard: TextInputType.phone),
                        _buildTextField(_mobileController, "Mobile", Icons.smartphone, keyboard: TextInputType.phone),
                        _buildTextField(_whatsappController, "WhatsApp", Icons.chat_outlined, keyboard: TextInputType.phone),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader("Address"),
                        _buildTextField(_addressController, "Current Address", Icons.location_on_outlined, maxLines: 2),
                        _buildTextField(_permanentAddressController, "Permanent Address", Icons.home_outlined, maxLines: 2),
                        _buildTextField(_cityController, "City", Icons.location_city),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader("Important Dates"),
                        _buildDatePicker("Birthday", _birthday, (date) => setState(() => _birthday = date), Icons.cake_outlined, kButtonColor),
                        _buildDatePicker("Anniversary", _anniversary, (date) => setState(() => _anniversary = date), Icons.favorite_outline, Colors.purple),
                        
                        const SizedBox(height: 24),
                        _buildReminderSection(),
                        
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _handleUpdate,
                          child: const Text("UPDATE CONTACT"),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _handleDelete,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: const BorderSide(color: kError, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("DELETE CONTACT", style: TextStyle(color: kError, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildAppBar(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.5, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const Text("Edit Contact", style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: _handleUpdate,
            child: const Text("Update", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(double size) {
    return Center(
      child: Stack(
        children: [
          GradientAvatar(radius: size * 0.15, initials: "TA"),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 3, height: 16, color: kPrimaryColor),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: kTextTertiary.withValues(alpha: 0.1))),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: required ? (value) => value == null || value.isEmpty ? "$hint is required" : null : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, Function(DateTime) onSelect, IconData icon, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: kPrimaryColor, onPrimary: Colors.white, onSurface: kTextPrimary),
                ),
                child: child!,
              );
            },
          );
          if (date != null) onSelect(date);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 22),
              const SizedBox(width: 12),
              Text(
                value != null ? DateFormat('d MMMM yyyy').format(value) : "Select $label",
                style: TextStyle(color: value != null ? kTextPrimary : kTextSecondary, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined, color: kTextTertiary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    return Row(
      children: [
        const Icon(Icons.notifications_active_outlined, color: kTextSecondary, size: 20),
        const SizedBox(width: 12),
        const Text("Remind me", style: TextStyle(color: kTextPrimary, fontSize: 14)),
        const Spacer(),
        DropdownButton<int>(
          value: _reminderDays,
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          items: [0, 1, 2, 3, 7].map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value == 0 ? "Same day" : "$value day(s) before", style: const TextStyle(color: kTextSecondary)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _reminderDays = val ?? 1),
        ),
      ],
    );
  }
}
