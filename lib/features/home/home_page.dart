import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:krishi/features/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: commonAppBar(
        AppText(
          'Appbar',
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: Get.scrollPhysics,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                30.verticalGap,

                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24).rt,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.o8],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16).rt,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Welcome to',
                        style: Get.bodyMedium.px14.copyWith(
                          color: AppColors.white.o8,
                        ),
                      ),
                      8.verticalGap,
                      AppText(
                        'Jaljala Connect',
                        style: Get.bodyLarge.px28.w700.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      12.verticalGap,
                      AppText(
                        'Your marketplace for connecting buyers and sellers',
                        style: Get.bodyMedium.px13.copyWith(
                          color: AppColors.white.o9,
                          height: 1.4,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                20.verticalGap,

                // Quick Stats
                AppText(
                  'Quick Overview',
                  style: Get.bodyLarge.px20.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),

                16.verticalGap,

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.store_outlined,
                        title: 'Products',
                        value: '0',
                        color: AppColors.primary,
                      ),
                    ),
                    12.horizontalGap,
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.shopping_cart_outlined,
                        title: 'Orders',
                        value: '0',
                        color: AppColors.cyan,
                      ),
                    ),
                  ],
                ),

                12.verticalGap,

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline,
                        title: 'Customers',
                        value: '0',
                        color: Colors.orange,
                      ),
                    ),
                    12.horizontalGap,
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.attach_money,
                        title: 'Revenue',
                        value: '0',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                30.verticalGap,

                // Recent Activity Section
                AppText(
                  'Recent Activity',
                  style: Get.bodyLarge.px20.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),

                16.verticalGap,

                _buildActivityCard(
                  icon: Icons.info_outline,
                  title: 'No Activity Yet',
                  subtitle: 'Start adding products to see your activity here',
                  time: 'Just now',
                ),

                12.verticalGap,

                _buildActivityCard(
                  icon: Icons.notifications_outlined,
                  title: 'Welcome!',
                  subtitle: 'You have successfully logged into the system',
                  time: 'Today',
                ),

                40.verticalGap,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Get.disabledColor.o1, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8).rt,
            decoration: BoxDecoration(
              color: color.o1,
              borderRadius: BorderRadius.circular(8).rt,
            ),
            child: Icon(icon, color: color, size: 24.st),
          ),
          12.verticalGap,
          AppText(
            value,
            style: Get.bodyLarge.px24.w700.copyWith(color: Get.disabledColor),
          ),
          4.verticalGap,
          AppText(
            title,
            style: Get.bodyMedium.px12.copyWith(color: Get.disabledColor.o6),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Get.disabledColor.o1, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12).rt,
            decoration: BoxDecoration(
              color: AppColors.primary.o1,
              borderRadius: BorderRadius.circular(10).rt,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.st),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                4.verticalGap,
                AppText(
                  subtitle,
                  style: Get.bodySmall.px12.copyWith(
                    color: Get.disabledColor.o6,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          8.horizontalGap,
          AppText(
            time,
            style: Get.bodySmall.px11.copyWith(color: Get.disabledColor.o5),
          ),
        ],
      ),
    );
  }
}
