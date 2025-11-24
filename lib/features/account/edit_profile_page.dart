import 'dart:io';
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
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isSaving = false;
  bool _isUploadingImage = false;

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('error_picking_image'.tr(context), color: Colors.red);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.rt),
            topRight: Radius.circular(24.rt),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.rt),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.rt,
                  height: 4.rt,
                  decoration: BoxDecoration(
                    color: Get.disabledColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2).rt,
                  ),
                ),
                20.verticalGap,
                AppText(
                  'select_image_source'.tr(context),
                  style: Get.bodyLarge.px18.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                24.verticalGap,
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'camera'.tr(context),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: _buildImageSourceOption(
                        icon: Icons.photo_library_rounded,
                        label: 'gallery'.tr(context),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                20.verticalGap,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.rt),
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: Get.disabledColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.rt),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32.st),
            ),
            12.verticalGap,
            AppText(
              label,
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.uploadAvatar(_selectedImage!.path);
      if (!mounted) return;
      Get.snackbar('profile_picture_updated'.tr(context), color: Colors.green);
      setState(() {
        _isUploadingImage = false;
        _selectedImage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      Get.snackbar('profile_picture_update_failed'.tr(context), color: Colors.red);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      
      // Upload image first if selected
      if (_selectedImage != null) {
        await apiService.uploadAvatar(_selectedImage!.path);
      }
      
      // Then update profile
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
              _buildProfileImageSection(),
              24.verticalGap,
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

  Widget _buildProfileImageSection() {
    final currentImage = widget.user.profile?.profileImage;
    final hasImage = _selectedImage != null || (currentImage != null && currentImage.isNotEmpty);

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 120.rt,
                height: 120.rt,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                      : currentImage != null && currentImage.isNotEmpty
                          ? Image.network(
                              Get.imageUrl(currentImage),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    padding: EdgeInsets.all(8.rt),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Get.cardColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      hasImage ? Icons.edit_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: 20.st,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        12.verticalGap,
        AppText(
          'profile_picture'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(
            color: Get.disabledColor,
          ),
        ),
        if (_selectedImage != null) ...[
          12.verticalGap,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isUploadingImage)
                Padding(
                  padding: EdgeInsets.only(right: 8.rt),
                  child: SizedBox(
                    width: 16.st,
                    height: 16.st,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: _isUploadingImage ? null : _uploadAvatar,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.rt, vertical: 8.rt),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12).rt,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: AppText(
                    'upload_image'.tr(context),
                    style: Get.bodySmall.px12.w600.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              12.horizontalGap,
              GestureDetector(
                onTap: _isUploadingImage
                    ? null
                    : () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.rt, vertical: 8.rt),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12).rt,
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: AppText(
                    'remove'.tr(context),
                    style: Get.bodySmall.px12.w600.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primary.withValues(alpha: 0.6),
        size: 60.st,
      ),
    );
  }
}

