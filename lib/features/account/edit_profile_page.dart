import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/button.dart';
import 'package:krishi/models/user_profile.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.user.profile?.fullName ?? widget.user.email);
    _phoneController =
        TextEditingController(text: widget.user.profile?.phoneNumber ?? '');
    _addressController =
        TextEditingController(text: widget.user.profile?.address ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );
      if (!mounted) return;
      Get.snackbar('profile_updated'.tr(context), color: Colors.green);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      Get.snackbar('profile_update_failed'.tr(context), color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'edit_profile'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16).rt,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                label: 'full_name'.tr(context),
                controller: _fullNameController,
                hint: 'enter_full_name'.tr(context),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'full_name_min'.tr(context);
                  }
                  return null;
                },
              ),
              16.verticalGap,
              _buildField(
                label: 'phone_number'.tr(context),
                controller: _phoneController,
                hint: 'enter_phone'.tr(context),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.trim().length < 10) {
                    return 'phone_min_length'.tr(context);
                  }
                  return null;
                },
              ),
              16.verticalGap,
              _buildField(
                label: 'address'.tr(context),
                controller: _addressController,
                hint: 'enter_address'.tr(context),
                maxLines: 3,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      value.trim().length < 10) {
                    return 'address_min_length'.tr(context);
                  }
                  return null;
                },
              ),
              32.verticalGap,
              AppButton(
                text: _isSaving ? 'saving'.tr(context) : 'save'.tr(context),
                onTap: () async {
                  if (_isSaving) return;
                  await _saveProfile();
                },
                height: 44.ht,
                radius: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: Get.bodyMedium.px13.w600.copyWith(color: Get.disabledColor),
        ),
        6.verticalGap,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Get.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ).rt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14).rt,
              borderSide: BorderSide(
                color: Get.disabledColor.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14).rt,
              borderSide: BorderSide(color: AppColors.primary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}


