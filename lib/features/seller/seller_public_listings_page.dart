import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/marketplace/product_detail_page.dart';
import 'package:krishi/models/product.dart';

class SellerPublicListingsPage extends ConsumerStatefulWidget {
  final String userKrId;
  final List<Product> initialListings;
  final String? titleKey;

  const SellerPublicListingsPage({
    super.key,
    required this.userKrId,
    required this.initialListings,
    this.titleKey,
  });

  @override
  ConsumerState<SellerPublicListingsPage> createState() =>
      _SellerPublicListingsPageState();
}

class _SellerPublicListingsPageState
    extends ConsumerState<SellerPublicListingsPage> {
  late List<Product> listings;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    listings = widget.initialListings;
    _refreshListings();
  }

  Future<void> _refreshListings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final profile = await apiService.getSellerPublicProfile(widget.userKrId);
      if (mounted) {
        setState(() {
          listings = profile.sellerProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              (widget.titleKey ?? 'seller_public_listings').tr(context),
              style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
            ),
            AppText(
              widget.userKrId,
              style: Get.bodySmall.px12.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshListings,
        child: ListView(
          padding: const EdgeInsets.all(8).rt,
          children: [
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32).rt,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (errorMessage != null)
              Column(
                children: [
                  AppText(
                    'error_loading_seller'.tr(context),
                    style: Get.bodyMedium.px15.w700.copyWith(color: Colors.red),
                  ),
                  8.verticalGap,
                  AppText(
                    errorMessage!,
                    style: Get.bodySmall.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              )
            else if (listings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32).rt,
                child: Center(
                  child: AppText(
                    'seller_no_listings'.tr(context),
                    style: Get.bodyMedium.px15.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              )
            else
              ...listings.map(_buildListingCard),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(Product product) {
    return GestureDetector(
      onTap: () => Get.to(ProductDetailPage(product: product)),
      child: Container(
        margin: EdgeInsets.only(bottom: 6.rt),
        padding: const EdgeInsets.all(8).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
              child: product.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12).rt,
                      child: Image.network(
                        Get.imageUrl(product.image),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.image_not_supported,
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          product.name,
                          style: Get.bodyMedium.px15.w700.copyWith(
                            color: Get.disabledColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.rating != null && product.rating!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            8.horizontalGap,
                            Icon(Icons.star, size: 14.st, color: Colors.amber),
                            4.horizontalGap,
                            AppText(
                              product.rating!,
                              style: Get.bodySmall.px11.w600.copyWith(
                                color: Get.disabledColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  4.verticalGap,
                  AppText(
                    'Rs. ${product.price}/${product.localizedUnitName(false)}',
                    style: Get.bodySmall.px12.w700.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  4.verticalGap,
                  AppText(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Get.bodySmall.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
