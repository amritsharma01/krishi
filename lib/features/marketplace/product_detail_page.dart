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
import 'package:krishi/models/product.dart';
import 'package:krishi/features/marketplace/widgets/product_detail_widgets.dart';
import 'package:krishi/features/marketplace/widgets/feedback_widgets.dart';
import 'package:krishi/features/marketplace/widgets/cart_button_widget.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _reviewCommentController = TextEditingController();
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
    super.dispose();
  }

  Future<void> _handleSellerInfoTap() async {
    if (ref.read(isFetchingSellerListingsProvider)) return;
    ref.read(isFetchingSellerListingsProvider.notifier).state = true;
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final latestProduct = await apiService.getProduct(widget.product.id);
      final sellerKrId = latestProduct.sellerId ?? widget.product.sellerId ?? '';
      if (sellerKrId.isEmpty) {
        Get.snackbar('seller_id_unavailable'.tr(context), color: Colors.red);
        return;
      }
      final publicProfile = await apiService.getSellerPublicProfile(sellerKrId);
      if (!mounted) return;
      if (publicProfile.sellerProducts.isEmpty) {
        Get.snackbar('seller_no_listings'.tr(context), color: Colors.orange.shade700);
        return;
      }
      Get.to(SellerPublicListingsPage(
        userKrId: sellerKrId,
        initialListings: publicProfile.sellerProducts,
      ));
    } catch (e) {
      Get.snackbar('error_loading_seller'.tr(context), color: Colors.red);
    } finally {
      if (mounted) {
        ref.read(isFetchingSellerListingsProvider.notifier).state = false;
      }
    }
  }

  Future<void> _addToCart() async {
    final isInCart = ref.read(isInCartProvider(widget.product.id));
    if (isInCart) return;

    ref.read(isAddingToCartProvider(widget.product.id).notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addToCart(productId: widget.product.id, quantity: 1);
      if (mounted) {
        ref.read(isInCartProvider(widget.product.id).notifier).state = true;
        ref.read(isAddingToCartProvider(widget.product.id).notifier).state = false;
        _animationController.forward();
        Get.snackbar('added_to_cart'.tr(context), color: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        ref.read(isAddingToCartProvider(widget.product.id).notifier).state = false;
      }
      Get.snackbar('error_adding_to_cart'.tr(context), color: Colors.red);
    }
  }

  Future<void> _checkoutDirectly() async {
    ref.read(isAddingToCartProvider(widget.product.id).notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.clearCart();
      await apiService.addToCart(productId: widget.product.id, quantity: 1);
      final cart = await apiService.getCart();
      if (mounted) {
        ref.read(isInCartProvider(widget.product.id).notifier).state = true;
        ref.read(isAddingToCartProvider(widget.product.id).notifier).state = false;
        Get.to(CheckoutPage(cart: cart));
      }
    } catch (e) {
      if (mounted) {
        ref.read(isAddingToCartProvider(widget.product.id).notifier).state = false;
      }
      Get.snackbar('error_adding_to_cart'.tr(context), color: Colors.red);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    final isSubmitting = ref.read(isSubmittingCommentProvider);
    if (text.isEmpty || isSubmitting) return;

    ref.read(isSubmittingCommentProvider.notifier).state = true;

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
        ref.read(isSubmittingCommentProvider.notifier).state = false;
      }
    }
  }

  Future<void> _submitReview() async {
    final comment = _reviewCommentController.text.trim();
    if (comment.isEmpty) {
      Get.snackbar('review_too_short'.tr(context), color: Colors.red);
      return;
    }
    final rating = ref.read(reviewRatingProvider).clamp(1, 5);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addReview(
        productId: widget.product.id,
        rating: rating,
        comment: comment,
      );
      _reviewCommentController.clear();
      ref.read(reviewRatingProvider.notifier).state = 5;
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
      appBar: _buildAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 160.ht),
        children: [
          ProductHeroSection(product: widget.product),
          6.verticalGap,
          ProductInfoCard(product: widget.product),
          6.verticalGap,
          SellerInfoCard(product: widget.product, onTap: _handleSellerInfoTap),
          6.verticalGap,
          ProductDescriptionCard(product: widget.product),
          6.verticalGap,
          _buildFeedbackSection(),
          6.verticalGap,
        ],
      ),
      bottomNavigationBar: AddToCartBottomBar(
        productId: widget.product.id,
        onAddToCart: _addToCart,
        onCheckout: _checkoutDirectly,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Get.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Get.disabledColor),
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
          onPressed: () => Get.to(const CartPage()),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'reviews'.tr(context),
                style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
              ),
              TextButton.icon(
                onPressed: _showAddReviewDialog,
                icon: Icon(Icons.add, size: 18.st, color: AppColors.primary),
                label: AppText(
                  'add_review'.tr(context),
                  style: Get.bodySmall.px13.w600.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          12.verticalGap,
          const FeedbackTabSelector(),
          16.verticalGap,
          Consumer(
            builder: (context, ref, child) {
              final tabIndex = ref.watch(feedbackTabIndexProvider);
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: tabIndex == 0
                    ? KeyedSubtree(
                        key: const ValueKey('reviews'),
                        child: ReviewsPanel(productId: widget.product.id),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('comments'),
                        child: CommentsPanel(
                          productId: widget.product.id,
                          commentController: _commentController,
                          onSubmit: _submitComment,
                        ),
                      ),
              );
            },
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
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
              ),
              20.verticalGap,
              AppText(
                'rating'.tr(this.context),
                style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
              ),
              12.verticalGap,
              Consumer(
                builder: (context, ref, child) {
                  final rating = ref.watch(reviewRatingProvider);
                  return Row(
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () {
                          ref.read(reviewRatingProvider.notifier).state = index + 1;
                        },
                        child: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32.st,
                        ),
                      ),
                    ),
                  );
                },
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
                      style: Get.bodyMedium.px16.w700.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
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
