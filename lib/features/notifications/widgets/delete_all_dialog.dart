import 'package:flutter/material.dart';
import 'package:krishi/core/extensions/translation_extension.dart';

class DeleteAllNotificationsDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_all_notifications'.tr(context)),
        content: Text('delete_all_notifications_warning'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('delete'.tr(context)),
          ),
        ],
      ),
    );
  }
}
