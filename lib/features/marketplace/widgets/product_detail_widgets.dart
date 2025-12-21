import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';
import 'package:krishi/models/comment.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/review.dart';

class ProductHeroSection extends StatelessWidget {
  final Product product;

  const ProductHeroSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.image != null ? Get.imageUrl(product.image) : '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.rt),
      child: Hero(
        tag: 'product-image-${product.id}',
        child: Container(
          height: 200.ht,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26).rt,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26).rt,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _HeroFallback(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const _HeroShimmer();
                    },
                  )
                else
                  const _HeroFallback(),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primary.withValues(alpha: 0.3),
          size: 48.st,
        ),
      ),
    );
  }
}

class _HeroShimmer extends StatelessWidget {
  const _HeroShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Center(
        child: SizedBox(
          width: 28.st,
          height: 28.st,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class ProductSectionCard extends StatelessWidget {
  final Widget child;

  const ProductSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6).rt,
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }
}

class ProductMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProductMetaChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).rt,
      decoration: BoxDecoration(
        color: Get.disabledColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30).rt,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.st,
            color: Get.disabledColor.withValues(alpha: 0.7),
          ),
          6.horizontalGap,
          AppText(
            label,
            style: Get.bodySmall.px11.w600.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductFeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ProductFeatureChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color == Colors.amber
        ? Colors.amber.shade700
        : color == Colors.green
        ? Colors.green.shade700
        : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).rt,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30).rt,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.st, color: textColor),
          6.horizontalGap,
          AppText(
            label,
            style: Get.bodySmall.px11.w600.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class ProductInfoCard extends ConsumerWidget {
  final Product product;

  const ProductInfoCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));
    final reviews = reviewsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <Review>[],
    );
    final averageRating = _calculateAverageRating(reviews);

    final chips = <Widget>[
      if (product.categoryName.trim().isNotEmpty)
        ProductMetaChip(
          icon: Icons.category_outlined,
          label: product.categoryName,
        ),
      if (product.unitName.trim().isNotEmpty)
        ProductMetaChip(
          icon: Icons.monitor_weight_outlined,
          label: product.unitName,
        ),
      if (product.freeDelivery == true)
        ProductFeatureChip(
          icon: Icons.local_shipping,
          label: 'free_delivery'.tr(context),
          color: Colors.green,
        ),
      if (product.recommend == true)
        ProductFeatureChip(
          icon: Icons.star,
          label: 'recommended'.tr(context),
          color: Colors.amber,
        ),
    ];

    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            product.name,
            style: Get.bodyLarge.px22.w800.copyWith(
              color: Get.disabledColor,
              height: 1.2,
            ),
          ),
          5.verticalGap,
          Row(
            children: [
              AppText(
                'Rs. ${product.price}',
                style: Get.bodyLarge.px16.w900.copyWith(
                  color: AppColors.primary,
                ),
              ),
              6.horizontalGap,
              AppText(
                '/${product.unitName}',
                style: Get.bodySmall.px12.w600.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              if (reviews.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 18.st),
                    4.horizontalGap,
                    AppText(
                      averageRating.toStringAsFixed(1),
                      style: Get.bodyMedium.px14.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    4.horizontalGap,
                    AppText(
                      '(${reviews.length})',
                      style: Get.bodySmall.px11.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          8.verticalGap,
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }
}

class SellerInfoCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;

  const SellerInfoCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerKrId = product.sellerId ?? product.seller.toString();
    final fetching = ref.watch(isFetchingSellerListingsProvider);

    return ProductSectionCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12).rt,
        child: Padding(
          padding: const EdgeInsets.all(4).rt,
          child: Row(
            children: [
              CircleAvatar(
                radius: 26.rt,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Icon(Icons.store_rounded, color: AppColors.primary),
              ),
              16.horizontalGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AppText(
                    //   'seller_information'.tr(context),
                    //   style: Get.bodySmall.px11.w600.copyWith(
                    //     color: Get.disabledColor.withValues(alpha: 0.6),
                    //   ),
                    // ),
                    // 4.verticalGap,
                    AppText(
                      'seller_id_label'.tr(context),
                      style: Get.bodySmall.px10.w600.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),

                    AppText(
                      sellerKrId,
                      style: Get.bodyMedium.px14.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    if (product.sellerDescription != null &&
                        product.sellerDescription!.trim().isNotEmpty) ...[
                      4.verticalGap,
                      AppText(
                        product.sellerDescription!,
                        style: Get.bodySmall.px12.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              fetching
                  ? SizedBox(
                      width: 18.st,
                      height: 18.st,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 16.st,
                      color: Get.disabledColor.withValues(alpha: 0.3),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDescriptionCard extends StatelessWidget {
  final Product product;

  const ProductDescriptionCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            maxLines: 10,
            'description'.tr(context),
            style: Get.bodyLarge.px16.w700.copyWith(color: Get.disabledColor),
          ),
          AppText(
            maxLines: 10,
            product.description,
            style: Get.bodyMedium.px12.w400.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.rt),
      padding: const EdgeInsets.all(14).rt,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.rt,
                backgroundColor: Colors.amber.withValues(alpha: 0.15),
                child: Icon(
                  Icons.person,
                  color: Colors.amber.shade700,
                  size: 16.st,
                ),
              ),
              10.horizontalGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      review.userName?.trim().isNotEmpty == true
                          ? review.userName!
                          : review.userEmail,
                      style: Get.bodyMedium.px14.w600.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    2.verticalGap,
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 16.st,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.verticalGap,
          AppText(
            review.comment,
            style: Get.bodySmall.px13.w400.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.rt),
      padding: const EdgeInsets.all(12).rt,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.rt,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            child: Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 16.st,
            ),
          ),
          12.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  comment.userName?.trim().isNotEmpty == true
                      ? comment.userName!
                      : comment.userEmail,
                  style: Get.bodyMedium.px13.w600.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                4.verticalGap,
                AppText(
                  maxLines: 3,
                  comment.text,
                  style: Get.bodySmall.px12.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.8),
                    height: 1.5,
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

class CommentComposer extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CommentComposer({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = ref.watch(isSubmittingCommentProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(14).rt,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8).rt,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'add_comment'.tr(context),
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          12.horizontalGap,
          ElevatedButton(
            onPressed: submitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 12.ht),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10).rt,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: submitting
                  ? SizedBox(
                      key: const ValueKey('comment-loading'),
                      width: 18.st,
                      height: 18.st,
                      child: const CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      key: const ValueKey('comment-action'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_rounded, size: 16.st),
                        6.horizontalGap,
                        AppText(
                          'add_comment'.tr(context),
                          style: Get.bodySmall.px12.w600.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
