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
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/marketplace/product_detail_page.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerProfilePage extends ConsumerStatefulWidget {
  final int sellerId;

  const SellerProfilePage({
    super.key,
    required this.sellerId,
  });

  @override
  ConsumerState<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends ConsumerState<SellerProfilePage> {
  User? sellerProfile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSellerProfile();
  }

  Future<void> _loadSellerProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final profile = await apiService.getUserProfile(widget.sellerId);
      if (mounted) {
        setState(() {
          sellerProfile = profile;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        Get.snackbar('call_failed'.tr(context), color: Colors.red);
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Remove any spaces or special characters
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Add country code if not present (Nepal country code is +977)
      if (!cleanNumber.startsWith('+') && !cleanNumber.startsWith('977')) {
        cleanNumber = '977$cleanNumber';
      }

      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
      }
    }
  }

  List<Product> get sellerProducts {
    if (sellerProfile?.sellerProducts == null) return [];
    return sellerProfile!.sellerProducts!
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .where((product) => product.isAvailable)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'seller_profile'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSellerProfile,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  80.verticalGap,
                  Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ],
              )
            : error != null
                ? Padding(
                    padding: const EdgeInsets.all(16).rt,
                    child: ErrorState(
                      title: 'problem_fetching_data'.tr(context),
                      subtitle: error,
                      onRetry: _loadSellerProfile,
                    ),
                  )
                : sellerProfile == null
                    ? Center(
                        child: AppText('seller_not_found'.tr(context)),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16).rt,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSellerInfoCard(),
                            16.verticalGap,
                            if (sellerProfile!.profile?.phoneNumber != null &&
                                sellerProfile!.profile!.phoneNumber!.isNotEmpty)
                              _buildContactButtons(),
                            if (sellerProfile!.profile?.phoneNumber != null &&
                                sellerProfile!.profile!.phoneNumber!.isNotEmpty)
                              16.verticalGap,
                            _buildProductsSection(),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildSellerInfoCard() {
    final profile = sellerProfile!.profile;
    final phoneNumber = profile?.phoneNumber;
    final address = profile?.address;

    return Container(
      padding: const EdgeInsets.all(20).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo
          CircleAvatar(
            radius: 50.rt,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage: profile?.profileImage != null
                ? NetworkImage(profile!.profileImage!)
                : null,
            child: profile?.profileImage == null
                ? Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 50.st,
                  )
                : null,
          ),
          16.verticalGap,
          // Name
          AppText(
            sellerProfile!.displayName,
            style: Get.bodyLarge.px20.w700.copyWith(
              color: Get.disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
          8.verticalGap,
          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 16.st,
                color: Get.disabledColor.withValues(alpha: 0.6),
              ),
              6.horizontalGap,
              Flexible(
                child: AppText(
                  sellerProfile!.email,
                  style: Get.bodyMedium.px14.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (phoneNumber != null && phoneNumber.isNotEmpty) ...[
            8.verticalGap,
            // Phone Number
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16.st,
                  color: Get.disabledColor.withValues(alpha: 0.6),
                ),
                6.horizontalGap,
                AppText(
                  phoneNumber,
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
          if (address != null && address.isNotEmpty) ...[
            12.verticalGap,
            // Address
            Container(
              padding: const EdgeInsets.all(12).rt,
              decoration: BoxDecoration(
                color: Get.disabledColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18.st,
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                  8.horizontalGap,
                  Expanded(
                    child: AppText(
                      address,
                      style: Get.bodyMedium.px13.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    final phoneNumber = sellerProfile!.profile?.phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: _buildContactButton(
            label: 'call'.tr(context),
            icon: Icons.phone,
            color: Colors.green,
            onTap: () => _makePhoneCall(phoneNumber),
          ),
        ),
        12.horizontalGap,
        Expanded(
          child: _buildContactButton(
            label: 'whatsapp'.tr(context),
            icon: Icons.chat,
            color: const Color(0xFF25D366),
            onTap: () => _openWhatsApp(phoneNumber),
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12).rt,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12).rt,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14).rt,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.st),
              8.horizontalGap,
              AppText(
                label,
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    final products = sellerProducts;

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48.st,
                color: Get.disabledColor.withValues(alpha: 0.3),
              ),
              12.verticalGap,
              AppText(
                'no_products'.tr(context),
                style: Get.bodyMedium.px14.w500.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'seller_products'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(
            color: Get.disabledColor,
          ),
        ),
        12.verticalGap,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, __) => 12.verticalGap,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16).rt,
      child: Container(
        padding: const EdgeInsets.all(12).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: Get.disabledColor.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12).rt,
              child: product.image != null
                  ? Image.network(
                      product.image!,
                      width: 80.wt,
                      height: 80.ht,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
            12.horizontalGap,
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    product.name,
                    style: Get.bodyMedium.px15.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                    maxLines: 2,
                  ),
                  6.verticalGap,
                  AppText(
                    '${product.priceAsDouble.toStringAsFixed(2)} NPR',
                    style: Get.bodyMedium.px14.w600.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  4.verticalGap,
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 14.st,
                        color: Get.disabledColor.withValues(alpha: 0.5),
                      ),
                      4.horizontalGap,
                      Expanded(
                        child: AppText(
                          product.categoryName,
                          style: Get.bodySmall.px12.w500.copyWith(
                            color: Get.disabledColor.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.st,
              color: Get.disabledColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80.wt,
      height: 80.ht,
      decoration: BoxDecoration(
        color: Get.disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12).rt,
      ),
      child: Icon(
        Icons.image_outlined,
        size: 32.st,
        color: Get.disabledColor.withValues(alpha: 0.3),
      ),
    );
  }
}

