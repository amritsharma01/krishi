import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/account/providers/user_profile_providers.dart';
import 'package:krishi/features/components/app_text.dart';

class EditableProfileImage extends ConsumerWidget {
  final String? currentImagePath;

  const EditableProfileImage({
    super.key,
    this.currentImagePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = ref.watch(selectedProfileImageProvider);
    final hasImage = selectedImage != null || (currentImagePath != null && currentImagePath!.isNotEmpty);

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              _buildImageContainer(selectedImage, currentImagePath),
              _buildEditButton(context, ref, hasImage),
            ],
          ),
        ),
        12.verticalGap,
        AppText(
          'profile_picture'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
        ),
        if (selectedImage != null) ...[
          8.verticalGap,
          GestureDetector(
            onTap: () => ref.read(selectedProfileImageProvider.notifier).state = null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.rt, vertical: 6.rt),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8).rt,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 14.st, color: Colors.red),
                  4.horizontalGap,
                  AppText(
                    'remove_selection'.tr(context),
                    style: Get.bodySmall.px12.w500.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContainer(File? selectedImage, String? currentImagePath) {
    return Container(
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
        child: selectedImage != null
            ? Image.file(selectedImage, fit: BoxFit.cover)
            : currentImagePath != null && currentImagePath.isNotEmpty
                ? Image.network(
                    Get.imageUrl(currentImagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, WidgetRef ref, bool hasImage) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => _showImageSourceDialog(context, ref),
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
    );
  }

  Widget _buildPlaceholder() {
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

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/compressed_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 512,
      minHeight: 512,
    );

    if (result != null) {
      return File(result.path);
    }
    return null;
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final originalFile = File(pickedFile.path);
        final compressedFile = await _compressImage(originalFile);
        
        ref.read(selectedProfileImageProvider.notifier).state = compressedFile ?? originalFile;
      }
    } catch (e) {
      if (context.mounted) {
        Get.snackbar('error_picking_image'.tr(context), color: Colors.red);
      }
    }
  }

  void _showImageSourceDialog(BuildContext context, WidgetRef ref) {
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
                  style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
                ),
                24.verticalGap,
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceOption(
                        context,
                        ref,
                        icon: Icons.camera_alt_rounded,
                        label: 'camera'.tr(context),
                        source: ImageSource.camera,
                      ),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: _buildImageSourceOption(
                        context,
                        ref,
                        icon: Icons.photo_library_rounded,
                        label: 'gallery'.tr(context),
                        source: ImageSource.gallery,
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

  Widget _buildImageSourceOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _pickImage(context, ref, source);
      },
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
              style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
            ),
          ],
        ),
      ),
    );
  }
}
