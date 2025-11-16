import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';

class AppDialog {
  /// Shows a confirmation dialog with customizable title, content, and actions
  static Future<bool?> showConfirmation({
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    Color? cancelColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    BuildContext? context,
  }) {
    final dialogContext = context ?? Get.context;
    return showDialog<bool>(
      context: dialogContext,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          backgroundColor: Get.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16).rt,
          ),
          title: Text(
            title,
            style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
          ),
          content: Text(
            content,
            style: Get.bodyMedium.px14.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.pop();
                if (onCancel != null) onCancel();
              },
              child: Text(
                cancelText ?? 'cancel'.tr(builderContext),
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: cancelColor ?? Get.disabledColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.pop();
                if (onConfirm != null) onConfirm();
              },
              child: Text(
                confirmText ?? 'confirm'.tr(builderContext),
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: confirmColor ?? AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a simple alert dialog with a title and message
  static Future<void> showAlert({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
    bool barrierDismissible = true,
    BuildContext? context,
  }) {
    final dialogContext = context ?? Get.context;
    return showDialog(
      context: dialogContext,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          backgroundColor: Get.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16).rt,
          ),
          title: Text(
            title,
            style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
          ),
          content: Text(
            message,
            style: Get.bodyMedium.px14.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.pop();
                if (onPressed != null) onPressed();
              },
              child: Text(
                buttonText ?? 'ok'.tr(builderContext),
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows a custom dialog with custom content widget
  static Future<T?> showCustom<T>({
    required Widget content,
    String? title,
    bool barrierDismissible = true,
    EdgeInsets? contentPadding,
    BuildContext? context,
  }) {
    final dialogContext = context ?? Get.context;
    return showDialog<T>(
      context: dialogContext,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext builderContext) {
        return AlertDialog(
          backgroundColor: Get.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16).rt,
          ),
          title: title != null
              ? Text(
                  title,
                  style: Get.bodyLarge.px18.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                )
              : null,
          content: content,
          contentPadding: contentPadding ?? EdgeInsets.all(16.rt),
        );
      },
    );
  }
}
