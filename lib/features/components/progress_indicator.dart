import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/double.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/utils/assets_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({super.key, this.color});

  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PlatformCircularProgressIndicator(
        material: (context, platform) => MaterialProgressIndicatorData(
          key: key,
          color: color ?? Get.primaryColor,
          strokeWidth: 2.st,
        ),
        cupertino: (context, platform) => CupertinoProgressIndicatorData(
          radius: 10.st,
          key: key,
          color: color ?? Get.primaryColor,
          animating: true,
        ),
      ),
    );
  }
}

class OverlayLoading extends StatelessWidget {
  const OverlayLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 80.st,
      child: Card.filled(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.rt),
        ),
        color: Get.scaffoldBackgroundColor,
        child: Image.asset(Assets.images.logo),
      ),
    );
  }
}

class AppLinearProgressIndicator extends StatelessWidget {
  const AppLinearProgressIndicator({
    super.key,
    this.color,
    this.value,
    this.minHeight = 6,
    this.backGroundColor,
  });

  final Color? color;
  final double? value;
  final double minHeight;
  final Color? backGroundColor;
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      borderRadius: BorderRadiusDirectional.circular(20.rt),
      color: color ?? Get.primaryColor,
      value: value,
      minHeight: minHeight.ht,
      backgroundColor: backGroundColor ?? (color ?? Get.primaryColor).o2,
    );
  }
}
