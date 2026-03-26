import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _referenceController = TextEditingController();
  final _professionController = TextEditingController();
  final _specialityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _cityController = TextEditingController();

  DateTime? _birthday;
  DateTime? _anniversary;
  int _reminderDays = 1;

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Logic to save contact
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact saved successfully!"), backgroundColor: kButtonColor),
      );
    }
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
                          onPressed: _handleSave,
                          child: const Text("SAVE CONTACT"),
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
          const Text("Add Contact", style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: _handleSave,
            child: const Text("Save", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
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
