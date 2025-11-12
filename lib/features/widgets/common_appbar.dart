import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:flutter/material.dart';

import '../../core/services/get.dart';
import '../../core/utils/app_icons.dart';
import 'appicon.dart';
import 'notification_icon.dart';

AppBar commonAppBar(Widget title) {
  return AppBar(
    automaticallyImplyLeading: false,
    key: Get.key(title),
    title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5).rt, child: title),
    actions: [
      Center(child: const NotificationIcon()),
      15.horizontalGap,
      AppIcon(AppIcons.search, size: 18, onTap: () {
        // Get.to(SearchView()); // TODO: Implement SearchView
      }, color: Get.disabledColor.o5),
      15.horizontalGap
    ],
  );
}
