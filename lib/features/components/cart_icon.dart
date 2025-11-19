import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/get.dart';
import 'appicon.dart';

class CartIcon extends ConsumerWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartIcon = AppIcon(
      Icons.shopping_cart_outlined,
      key: Get.key(Get.brightness),
      size: 18,
      onTap: () {
        // TODO: Navigate to cart page
      },
      color: Get.disabledColor.o5,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        cartIcon,
        Positioned(
          top: -3.rt,
          right: -3.rt,
          child: Container(
            padding: EdgeInsets.all(4.rt),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              "0",
              style: Get.bodyMedium.px10.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
