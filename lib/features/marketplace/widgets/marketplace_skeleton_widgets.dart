import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/services/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BuyProductsSkeleton extends StatelessWidget {
  const BuyProductsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.rt,
          mainAxisSpacing: 12.rt,
          childAspectRatio: 0.75,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _ProductCardSkeleton(),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
      ),
      child: Column(
        children: [
          Container(
            height: 112.ht,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.rt),
                topRight: Radius.circular(16.rt),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.rt,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Get.disabledColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8).rt,
                  ),
                ),
                8.verticalGap,
                Container(
                  height: 12.rt,
                  width: 80.rt,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8).rt,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SellListingsSkeleton extends StatelessWidget {
  const SellListingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18).rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              borderRadius: BorderRadius.circular(12).rt,
            ),
          ),
          20.verticalGap,
          Container(
            height: 20.rt,
            width: 140.rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              borderRadius: BorderRadius.circular(8).rt,
            ),
          ),
          16.verticalGap,
          Column(
            children: List.generate(3, (_) => _ListingCardSkeleton()),
          ),
        ],
      ),
    );
  }
}

class _ListingCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.rt),
      padding: const EdgeInsets.all(14).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
      ),
      child: Row(
        children: [
          Container(
            width: 70.rt,
            height: 70.rt,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12).rt,
            ),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.rt,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Get.disabledColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8).rt,
                  ),
                ),
                8.verticalGap,
                Container(
                  height: 12.rt,
                  width: 100.rt,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8).rt,
                  ),
                ),
              ],
            ),
          ),
          16.horizontalGap,
          Container(
            width: 32.rt,
            height: 32.rt,
            decoration: BoxDecoration(
              color: Get.disabledColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8).rt,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryFiltersSkeleton extends StatelessWidget {
  const CategoryFiltersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Row(
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(right: 10.rt),
            padding: EdgeInsets.symmetric(horizontal: 20.rt, vertical: 10.rt),
            decoration: BoxDecoration(
              color: Get.disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24).rt,
            ),
            child: const SizedBox(width: 60, height: 12),
          ),
        ),
      ),
    );
  }
}
