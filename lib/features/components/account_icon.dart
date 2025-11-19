import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/account/account_page.dart';
import 'package:flutter/material.dart';
import 'appicon.dart';

class AccountIcon extends StatelessWidget {
  const AccountIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return AppIcon(
      Icons.account_circle_outlined,
      size: 18,
      onTap: () {
        Get.to(const AccountPage());
      },
      color: Get.disabledColor.o5,
    );
  }
}

