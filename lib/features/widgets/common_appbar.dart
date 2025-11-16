import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:flutter/material.dart';

import 'account_icon.dart';
import 'cart_icon.dart';
import 'notification_icon.dart';

AppBar commonAppBar(Widget title) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5).rt, child: title),
    actions: [
      Center(child: const CartIcon()),
      15.horizontalGap,
      Center(child: const NotificationIcon()),
      15.horizontalGap,
      Center(child: const AccountIcon()),
      15.horizontalGap
    ],
  );
}
