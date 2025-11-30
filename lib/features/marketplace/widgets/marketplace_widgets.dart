import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/marketplace/product_detail_page.dart';
import 'package:krishi/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isNepali;

  const ProductCard({
    super.key,
    required this.product,
    required this.isNepali,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Get.to(ProductDetailPage(product: product)),
            child: Stack(
              children: [
                _buildProductImage(),
                if (product.freeDelivery == true)
                  _buildBadge(
                    Icons.local_shipping,
                    Colors.green.shade700,
                    isLeft: true,
                  ),
                if (product.recommend == true)
                  _buildBadge(
                    Icons.star,
                    Colors.amber.shade700,
                    isLeft: false,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12).rt,
            child: GestureDetector(
              onTap: () => Get.to(ProductDetailPage(product: product)),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    product.name,
                    style: Get.bodyLarge.px16.w800.copyWith(
                      color: Get.disabledColor,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalGap,
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Rs. ${product.price}/${product.localizedUnitName(isNepali)}',
                          style: Get.bodyMedium.px12.w700.copyWith(color: AppColors.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.rating != null && product.rating!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14.st, color: Colors.amber),
                            4.horizontalGap,
                            AppText(
                              product.rating!,
                              style: Get.bodySmall.px11.w600.copyWith(color: Get.disabledColor),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 112.ht,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.rt),
          topRight: Radius.circular(16.rt),
        ),
      ),
      child: product.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.rt),
                topRight: Radius.circular(16.rt),
              ),
              child: Image.network(
                Get.imageUrl(product.image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.primary.withValues(alpha: 0.3),
                    size: 40.st,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.image_not_supported,
                color: AppColors.primary.withValues(alpha: 0.3),
                size: 42.st,
              ),
            ),
    );
  }

  Widget _buildBadge(IconData icon, Color color, {required bool isLeft}) {
    return Positioned(
      top: 8.rt,
      left: isLeft ? 8.rt : null,
      right: isLeft ? null : 8.rt,
      child: Container(
        padding: EdgeInsets.all(4.rt),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6).rt,
        ),
        child: Icon(icon, size: 14.st, color: color),
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  final Product listing;
  final bool isNepali;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ListingCard({
    super.key,
    required this.listing,
    required this.isNepali,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.rt),
      padding: const EdgeInsets.all(6).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildListingImage(),
              4.verticalGap,
              ApprovalStatusChip(approvalStatus: listing.approvalStatus),
            ],
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  listing.name,
                  style: Get.bodyMedium.px14.w700.copyWith(color: Get.disabledColor),
                ),
                4.verticalGap,
                AppText(
                  maxLines: 2,
                  'Rs. ${listing.price}/${listing.localizedUnitName(isNepali)}',
                  style: Get.bodyMedium.px10.w700.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(Icons.edit_outlined, Colors.blue, onEdit),
              8.horizontalGap,
              _buildActionButton(Icons.delete_outline, Colors.red, onDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListingImage() {
    return Container(
      width: 70.rt,
      height: 70.rt,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12).rt,
      ),
      child: listing.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12).rt,
              child: Image.network(
                Get.imageUrl(listing.image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.primary.withValues(alpha: 0.3),
                    size: 32.st,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.image_not_supported,
                color: AppColors.primary.withValues(alpha: 0.3),
                size: 32.st,
              ),
            ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8).rt,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8).rt,
        ),
        child: Icon(icon, color: color, size: 18.st),
      ),
    );
  }
}

class ApprovalStatusChip extends StatelessWidget {
  final String? approvalStatus;

  const ApprovalStatusChip({super.key, this.approvalStatus});

  @override
  Widget build(BuildContext context) {
    if (approvalStatus == null) return const SizedBox.shrink();

    final (bgColor, textColor, label) = _getStatusColors(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rt, vertical: 2.rt),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6).rt,
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: AppText(
        label,
        style: Get.bodySmall.px08.w600.copyWith(color: textColor),
      ),
    );
  }

  (Color, Color, String) _getStatusColors(BuildContext context) {
    switch (approvalStatus!.toLowerCase()) {
      case 'approved':
        return (
          Colors.green.withValues(alpha: 0.15),
          Colors.green.shade700,
          'approved'.tr(context),
        );
      case 'pending':
        return (
          Colors.orange.withValues(alpha: 0.15),
          Colors.orange.shade700,
          'pending'.tr(context),
        );
      case 'rejected':
        return (
          Colors.red.withValues(alpha: 0.15),
          Colors.red.shade700,
          'rejected'.tr(context),
        );
      default:
        return (Colors.grey, Colors.grey, '');
    }
  }
}

class CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const CategoryPill({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 8.rt, vertical: 6.rt),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                )
              : null,
          color: isSelected ? null : Get.disabledColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24).rt,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Get.disabledColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14.st,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              6.horizontalGap,
            ],
            AppText(
              label,
              style: Get.bodySmall.w600.copyWith(
                fontSize: 12.sp,
                color: isSelected ? Colors.white : Get.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
