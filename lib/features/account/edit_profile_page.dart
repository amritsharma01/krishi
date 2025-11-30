import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/account/providers/user_profile_providers.dart';
import 'package:krishi/features/account/widgets/editable_profile_image.dart';
import 'package:krishi/features/account/widgets/profile_text_field.dart';
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

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.user.profile?.fullName ?? widget.user.email,
    );
    _phoneController = TextEditingController(
      text: widget.user.profile?.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: widget.user.profile?.address ?? '',
    );
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

    ref.read(isUpdatingProfileProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final selectedImage = ref.read(selectedProfileImageProvider);

      if (selectedImage != null) {
        await apiService.uploadAvatar(selectedImage.path);
      }

      await apiService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      // Reset selected image before navigating back
      ref.read(selectedProfileImageProvider.notifier).state = null;
      
      // Refresh profile data
      await ref.read(userProfileProvider.notifier).refresh();

      if (!mounted) return;
      Get.snackbar('profile_updated'.tr(context), color: Colors.green);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('profile_update_failed'.tr(context), color: Colors.red);
    } finally {
      ref.read(isUpdatingProfileProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isUpdatingProfileProvider);

    return WillPopScope(
      onWillPop: () async {
        // Reset selected image when user presses back button
        ref.read(selectedProfileImageProvider.notifier).state = null;
        return true;
      },
      child: Scaffold(
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
              EditableProfileImage(
                currentImagePath: widget.user.profile?.profileImage,
              ),
              24.verticalGap,
              ProfileTextField(
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
              ProfileTextField(
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
              ProfileTextField(
                label: 'address'.tr(context),
                controller: _addressController,
                hint: 'enter_address'.tr(context),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.trim().length < 10) {
                    return 'address_min_length'.tr(context);
                  }
                  return null;
                },
              ),
              32.verticalGap,
              AppButton(
                text: isSaving ? 'saving'.tr(context) : 'save'.tr(context),
                onTap: () {
                  if (!isSaving) {
                    _saveProfile();
                  }
                },
                height: 44.ht,
                radius: 14,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

