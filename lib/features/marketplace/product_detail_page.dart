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
import 'package:krishi/features/cart/cart_page.dart';
import 'package:krishi/features/cart/checkout_page.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';
import 'package:krishi/features/seller/seller_public_listings_page.dart';
import 'package:krishi/models/comment.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/review.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isInCart = ValueNotifier(false);
  final ValueNotifier<bool> isAddingToCart = ValueNotifier(false);
  final ValueNotifier<bool> _isFetchingSellerListings = ValueNotifier(false);
  final ValueNotifier<bool> _isSubmittingComment = ValueNotifier(false);
  final ValueNotifier<int> _feedbackTabIndex = ValueNotifier(0);

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _reviewCommentController =
      TextEditingController();
  int _rating = 5;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _reviewCommentController.dispose();
    _animationController.dispose();
    isInCart.dispose();
    isAddingToCart.dispose();
    _isFetchingSellerListings.dispose();
    _isSubmittingComment.dispose();
    _feedbackTabIndex.dispose();
    super.dispose();
  }

  Future<void> _handleSellerInfoTap() async {
    if (_isFetchingSellerListings.value) return;
    _isFetchingSellerListings.value = true;
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final latestProduct = await apiService.getProduct(widget.product.id);
      final sellerKrId =
          latestProduct.sellerId ?? widget.product.sellerId ?? '';
      if (sellerKrId.isEmpty) {
        Get.snackbar('seller_id_unavailable'.tr(context), color: Colors.red);
        return;
      }
      final publicProfile = await apiService.getSellerPublicProfile(sellerKrId);
      if (!mounted) return;
      if (publicProfile.sellerProducts.isEmpty) {
        Get.snackbar(
          'seller_no_listings'.tr(context),
          color: Colors.orange.shade700,
        );
        return;
      }
      Get.to(
        SellerPublicListingsPage(
          userKrId: sellerKrId,
          initialListings: publicProfile.sellerProducts,
        ),
      );
    } catch (e) {
      Get.snackbar('error_loading_seller'.tr(context), color: Colors.red);
    } finally {
      if (mounted) {
        _isFetchingSellerListings.value = false;
      }
    }
  }

  Future<void> _addToCart() async {
    if (isInCart.value) return;

    isAddingToCart.value = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addToCart(productId: widget.product.id, quantity: 1);
      if (mounted) {
        isInCart.value = true;
        isAddingToCart.value = false;
        _animationController.forward();
        Get.snackbar('added_to_cart'.tr(context), color: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        isAddingToCart.value = false;
      }
      Get.snackbar('error_adding_to_cart'.tr(context), color: Colors.red);
    }
  }

  Future<void> _checkoutDirectly() async {
    isAddingToCart.value = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      // Clear cart to ensure only this product is checked out
      await apiService.clearCart();
      // Add product to cart
      await apiService.addToCart(productId: widget.product.id, quantity: 1);
      // Get the updated cart (will contain only this product)
      final cart = await apiService.getCart();
      if (mounted) {
        isInCart.value = true;
        isAddingToCart.value = false;
        // Navigate directly to checkout page (user won't see cart page)
        Get.to(CheckoutPage(cart: cart));
      }
    } catch (e) {
      if (mounted) {
        isAddingToCart.value = false;
      }
      Get.snackbar('error_adding_to_cart'.tr(context), color: Colors.red);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmittingComment.value) return;

    _isSubmittingComment.value = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addComment(widget.product.id, text);
      _commentController.clear();
      ref.invalidate(productCommentsProvider(widget.product.id));
      Get.snackbar('comment_added'.tr(context), color: Colors.green);
    } catch (e) {
      Get.snackbar('error_adding_comment'.tr(context), color: Colors.red);
    } finally {
      if (mounted) {
        _isSubmittingComment.value = false;
      }
    }
  }

  Future<void> _submitReview() async {
    final comment = _reviewCommentController.text.trim();
    if (comment.isEmpty) {
      Get.snackbar('review_too_short'.tr(context), color: Colors.red);
      return;
    }
    final rating = _rating.clamp(1, 5);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addReview(
        productId: widget.product.id,
        rating: rating,
        comment: comment,
      );
      _reviewCommentController.clear();
      _rating = 5;
      ref.invalidate(productReviewsProvider(widget.product.id));
      Get.pop();
      Get.snackbar('review_added'.tr(context), color: Colors.green);
    } catch (e) {
      Get.snackbar(
        e.toString().contains('purchase')
            ? 'must_purchase_to_review'.tr(context)
            : 'error_adding_review'.tr(context),
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Get.disabledColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppText(
          widget.product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Get.disabledColor),
            onPressed: () {
              Get.to(const CartPage());
            },
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 160.ht),
        children: [
          _buildHeroSection(),
          6.verticalGap,
          _buildProductInfo(),
          6.verticalGap,
          _buildSellerInfo(),
          6.verticalGap,
          _buildDescription(),
          6.verticalGap,
          _buildFeedbackSection(),
          6.verticalGap,
        ],
      ),
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  Widget _buildAddToCartButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: isAddingToCart,
      builder: (context, adding, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isInCart,
          builder: (context, inCart, child) {
            return SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(16.rt, 12.ht, 16.rt, 16.ht),
                decoration: BoxDecoration(
                  color: Get.cardColor,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(20),
                  ).rt,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: adding ? null : _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: inCart
                              ? Colors.green.shade500
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.rt),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12).rt,
                          ),
                          elevation: inCart ? 2 : 3,
                          shadowColor:
                              (inCart ? Colors.green : AppColors.primary)
                                  .withValues(alpha: 0.3),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: adding
                              ? SizedBox(
                                  key: const ValueKey('loading'),
                                  height: 20.st,
                                  width: 20.st,
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : inCart
                              ? Row(
                                  key: const ValueKey('added'),
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, size: 20.st),
                                    8.horizontalGap,
                                    AppText(
                                      'added_to_cart'.tr(context),
                                      style: Get.bodyMedium.px15.w600.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  key: const ValueKey('add'),
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_cart, size: 20.st),
                                    8.horizontalGap,
                                    AppText(
                                      'add_to_cart'.tr(context),
                                      style: Get.bodyMedium.px15.w600.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    12.horizontalGap,
                    // Checkout Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: adding ? null : _checkoutDirectly,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.9,
                          ),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.rt),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12).rt,
                          ),
                          elevation: 3,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: adding
                            ? SizedBox(
                                height: 20.st,
                                width: 20.st,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.payment, size: 20.st),
                                  8.horizontalGap,
                                  AppText(
                                    'checkout'.tr(context),
                                    style: Get.bodyMedium.px15.w600.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroSection() {
    final imageUrl = widget.product.image != null
        ? Get.imageUrl(widget.product.image)
        : '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rt),
      child: Hero(
        tag: 'product-image-${widget.product.id}',
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
                        _buildHeroFallback(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildHeroShimmer();
                    },
                  )
                else
                  _buildHeroFallback(),
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

  Widget _buildHeroFallback() {
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

  Widget _buildHeroShimmer() {
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

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16).rt,
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }

  Widget _metaChip(IconData icon, String label) {
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

  Widget _featureChip(IconData icon, String label, Color color) {
    // Get darker shade for text/icon
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

  Widget _buildProductInfo() {
    final reviewsAsync = ref.watch(productReviewsProvider(widget.product.id));
    final reviews = reviewsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <Review>[],
    );
    final averageRating = _calculateAverageRating(reviews);
    final chips = <Widget>[
      if (widget.product.categoryName.trim().isNotEmpty)
        _metaChip(Icons.category_outlined, widget.product.categoryName),
      if (widget.product.unitName.trim().isNotEmpty)
        _metaChip(Icons.monitor_weight_outlined, widget.product.unitName),
      if (widget.product.freeDelivery == true)
        _featureChip(
          Icons.local_shipping,
          'free_delivery'.tr(context),
          Colors.green,
        ),
      if (widget.product.recommend == true)
        _featureChip(Icons.star, 'recommended'.tr(context), Colors.amber),
    ];

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            widget.product.name,
            style: Get.bodyLarge.px22.w800.copyWith(
              color: Get.disabledColor,
              height: 1.2,
            ),
          ),
          5.verticalGap,
          Row(
            children: [
              AppText(
                'Rs. ${widget.product.price}',
                style: Get.bodyLarge.px16.w900.copyWith(
                  color: AppColors.primary,
                ),
              ),
              6.horizontalGap,
              AppText(
                '/${widget.product.unitName}',
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

  Widget _buildSellerInfo() {
    final sellerKrId =
        widget.product.sellerId ?? widget.product.seller.toString();
    return _sectionCard(
      child: InkWell(
        onTap: _handleSellerInfoTap,
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
                    AppText(
                      'seller_information'.tr(context),
                      style: Get.bodySmall.px11.w600.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                    4.verticalGap,
                    AppText(
                      'seller_id_label'.tr(context),
                      style: Get.bodySmall.px11.w600.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                    4.verticalGap,
                    AppText(
                      sellerKrId,
                      style: Get.bodyMedium.px15.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    if (widget.product.sellerDescription != null &&
                        widget.product.sellerDescription!
                            .trim()
                            .isNotEmpty) ...[
                      8.verticalGap,
                      AppText(
                        widget.product.sellerDescription!,
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
              ValueListenableBuilder<bool>(
                valueListenable: _isFetchingSellerListings,
                builder: (context, fetching, _) => fetching
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            maxLines: 10,
            'description'.tr(context),
            style: Get.bodyLarge.px16.w700.copyWith(color: Get.disabledColor),
          ),

          AppText(
            widget.product.description,
            style: Get.bodyMedium.px12.w400.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'reviews'.tr(context),
                style: Get.bodyLarge.px18.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddReviewDialog,
                icon: Icon(Icons.add, size: 18.st, color: AppColors.primary),
                label: AppText(
                  'add_review'.tr(context),
                  style: Get.bodySmall.px13.w600.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          12.verticalGap,
          _buildFeedbackTabs(),
          16.verticalGap,
          ValueListenableBuilder<int>(
            valueListenable: _feedbackTabIndex,
            builder: (context, tabIndex, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: tabIndex == 0
                    ? KeyedSubtree(
                        key: const ValueKey('reviews'),
                        child: _buildReviewsPanel(),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('comments'),
                        child: _buildCommentsPanel(),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTabs() {
    final tabs = ['reviews'.tr(context), 'comments'.tr(context)];
    return ValueListenableBuilder<int>(
      valueListenable: _feedbackTabIndex,
      builder: (context, tabIndex, child) {
        return Container(
          padding: const EdgeInsets.all(4).rt,
          decoration: BoxDecoration(
            color: Get.disabledColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12).rt,
          ),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isActive = tabIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (tabIndex == index) return;
                    _feedbackTabIndex.value = index;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(vertical: 10.ht),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10).rt,
                    ),
                    child: Center(
                      child: AppText(
                        tabs[index],
                        style: Get.bodySmall.px13.w700.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : Get.disabledColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildReviewsPanel() {
    final reviewsAsync = ref.watch(productReviewsProvider(widget.product.id));

    return reviewsAsync.when(
      data: (reviewsList) {
        if (reviewsList.isEmpty) {
          return AppText(
            'no_reviews_yet'.tr(context),
            style: Get.bodySmall.px13.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
          );
        }
        return Column(children: reviewsList.map(_buildReviewCard).toList());
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(16).rt,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (error, stack) => TextButton(
        onPressed: () {
          ref.invalidate(productReviewsProvider(widget.product.id));
        },
        child: AppText(
          'error_loading_reviews'.tr(context),
          style: Get.bodySmall.px12.w600.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildCommentsPanel() {
    final commentsAsync = ref.watch(productCommentsProvider(widget.product.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentComposer(),
        6.verticalGap,
        commentsAsync.when(
          data: (commentsList) {
            if (commentsList.isEmpty) {
              return AppText(
                'no_comments_yet'.tr(context),
                style: Get.bodySmall.px13.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
              );
            }
            return Column(
              children: commentsList.map(_buildCommentCard).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(12).rt,
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          error: (error, stack) => TextButton(
            onPressed: () {
              ref.invalidate(productCommentsProvider(widget.product.id));
            },
            child: AppText(
              'error_loading_comments'.tr(context),
              style: Get.bodySmall.px12.w600.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentComposer() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSubmittingComment,
      builder: (context, submitting, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Get.disabledColor.withValues(alpha: 0.08),
            ),
            borderRadius: BorderRadius.circular(14).rt,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8).rt,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
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
                onPressed: submitting ? null : _submitComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.wt,
                    vertical: 12.ht,
                  ),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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
      },
    );
  }

  Widget _buildReviewCard(Review review) {
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

  Widget _buildCommentCard(Comment comment) {
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

  void _showAddReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Get.scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.rt),
              topRight: Radius.circular(24.rt),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24).rt,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'add_review'.tr(this.context),
                  style: Get.bodyLarge.px20.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                20.verticalGap,
                AppText(
                  'rating'.tr(this.context),
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                12.verticalGap,
                Row(
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _rating = index + 1;
                        });
                      },
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32.st,
                      ),
                    ),
                  ),
                ),
                20.verticalGap,
                TextField(
                  controller: _reviewCommentController,
                  decoration: InputDecoration(
                    hintText: 'write_review'.tr(this.context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12).rt,
                    ),
                  ),
                  maxLines: 5,
                ),
                20.verticalGap,
                GestureDetector(
                  onTap: _submitReview,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14).rt,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12).rt,
                    ),
                    child: Center(
                      child: AppText(
                        'submit_review'.tr(this.context),
                        style: Get.bodyMedium.px16.w700.copyWith(
                          color: Colors.white,
                        ),
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

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }
}
