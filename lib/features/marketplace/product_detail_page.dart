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
import 'package:krishi/features/cart/checkout_page.dart';
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
  List<Review> reviews = [];
  List<Comment> comments = [];
  bool isLoadingReviews = true;
  bool isLoadingComments = true;
  bool reviewsError = false;
  bool commentsError = false;
  bool isInCart = false;
  bool isAddingToCart = false;
  bool _isFetchingSellerListings = false;
  bool _isSubmittingComment = false;
  int _feedbackTabIndex = 0;

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
    _loadReviews();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _reviewCommentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      isLoadingReviews = true;
      reviewsError = false;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final reviewsData = await apiService.getProductReviews(widget.product.id);
      if (mounted) {
        setState(() {
          reviews = reviewsData;
          isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          reviewsError = true;
          isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoadingComments = true;
      commentsError = false;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final commentsData = await apiService.getProductComments(
        widget.product.id,
      );
      if (mounted) {
        setState(() {
          comments = commentsData;
          isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          commentsError = true;
          isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _handleSellerInfoTap() async {
    if (_isFetchingSellerListings) return;
    setState(() {
      _isFetchingSellerListings = true;
    });
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
        setState(() {
          _isFetchingSellerListings = false;
        });
      }
    }
  }

  Future<void> _addToCart() async {
    if (isInCart) return;

    setState(() => isAddingToCart = true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addToCart(productId: widget.product.id, quantity: 1);
      if (mounted) {
        setState(() {
          isInCart = true;
          isAddingToCart = false;
        });
        _animationController.forward();
        Get.snackbar('added_to_cart'.tr(context), color: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isAddingToCart = false);
      }
      Get.snackbar('error_adding_to_cart'.tr(context), color: Colors.red);
    }
  }

  Future<void> _checkoutDirectly() async {
    setState(() => isAddingToCart = true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      // Clear cart to ensure only this product is checked out
      await apiService.clearCart();
      // Add product to cart
      await apiService.addToCart(productId: widget.product.id, quantity: 1);
      // Get the updated cart (will contain only this product)
      final cart = await apiService.getCart();
      if (mounted) {
        setState(() {
          isInCart = true;
          isAddingToCart = false;
        });
        // Navigate directly to checkout page (user won't see cart page)
        Get.to(CheckoutPage(cart: cart));
      }
    } catch (e) {
      if (mounted) {
        setState(() => isAddingToCart = false);
      }
      Get.snackbar('error_adding_to_cart'.tr(context), color: Colors.red);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmittingComment) return;

    setState(() => _isSubmittingComment = true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addComment(widget.product.id, text);
      _commentController.clear();
      await _loadComments();
      Get.snackbar('comment_added'.tr(context), color: Colors.green);
    } catch (e) {
      Get.snackbar('error_adding_comment'.tr(context), color: Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
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
      _loadReviews();
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
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 160.ht),
        children: [
          8.verticalGap,
          _buildHeroSection(),
          20.verticalGap,
          _buildProductInfo(),
          16.verticalGap,
          _buildSellerInfo(),
          16.verticalGap,
          _buildDescription(),
          20.verticalGap,
          _buildFeedbackSection(),
          32.verticalGap,
        ],
      ),
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  Widget _buildAddToCartButton() {
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
                onPressed: isAddingToCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart
                      ? Colors.green.shade500
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.rt),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                  elevation: isInCart ? 2 : 3,
                  shadowColor: (isInCart ? Colors.green : AppColors.primary)
                      .withValues(alpha: 0.3),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isAddingToCart
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          height: 20.st,
                          width: 20.st,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : isInCart
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
                onPressed: isAddingToCart ? null : _checkoutDirectly,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.rt),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                  elevation: 3,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                child: isAddingToCart
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
          height: 280.ht,
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
                Positioned(
                  bottom: 18.rt,
                  left: 18.rt,
                  right: 18.rt,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _heroMetaPill(widget.product.categoryName),
                      _heroMetaPill(widget.product.unitName),
                    ],
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
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _heroMetaPill(String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wt, vertical: 6.ht),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(30).rt,
      ),
      child: AppText(
        text,
        style: Get.bodySmall.px11.w600.copyWith(color: Colors.white),
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

  Widget _buildProductInfo() {
    final averageRating = _calculateAverageRating();
    final chips = <Widget>[
      if (widget.product.categoryName.trim().isNotEmpty)
        _metaChip(Icons.category_outlined, widget.product.categoryName),
      if (widget.product.unitName.trim().isNotEmpty)
        _metaChip(Icons.monitor_weight_outlined, widget.product.unitName),
    ];

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            widget.product.name,
            style: Get.bodyLarge.px24.w800.copyWith(
              color: Get.disabledColor,
              height: 1.2,
            ),
          ),
          12.verticalGap,
          Row(
            children: [
              AppText(
                'Rs. ${widget.product.price}',
                style: Get.bodyLarge.px30.w900.copyWith(
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
          16.verticalGap,
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
                  ],
                ),
              ),
              _isFetchingSellerListings
                  ? SizedBox(
                      width: 18.st,
                      height: 18.st,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
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

  Widget _buildDescription() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'description'.tr(context),
            style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          AppText(
            widget.product.description,
            style: Get.bodyMedium.px14.w400.copyWith(
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _feedbackTabIndex == 0
                ? KeyedSubtree(
                    key: const ValueKey('reviews'),
                    child: _buildReviewsPanel(),
                  )
                : KeyedSubtree(
                    key: const ValueKey('comments'),
                    child: _buildCommentsPanel(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTabs() {
    final tabs = ['reviews'.tr(context), 'comments'.tr(context)];
    return Container(
      padding: const EdgeInsets.all(4).rt,
      decoration: BoxDecoration(
        color: Get.disabledColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12).rt,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = _feedbackTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_feedbackTabIndex == index) return;
                setState(() => _feedbackTabIndex = index);
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
                      color: isActive ? AppColors.primary : Get.disabledColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReviewsPanel() {
    if (isLoadingReviews) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16).rt,
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (reviewsError) {
      return TextButton(
        onPressed: _loadReviews,
        child: AppText(
          'error_loading_reviews'.tr(context),
          style: Get.bodySmall.px12.w600.copyWith(color: AppColors.primary),
        ),
      );
    }

    if (reviews.isEmpty) {
      return AppText(
        'no_reviews_yet'.tr(context),
        style: Get.bodySmall.px13.copyWith(
          color: Get.disabledColor.withValues(alpha: 0.7),
        ),
      );
    }

    return Column(children: reviews.map(_buildReviewCard).toList());
  }

  Widget _buildCommentsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentComposer(),
        16.verticalGap,
        if (isLoadingComments)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12).rt,
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (commentsError)
          TextButton(
            onPressed: _loadComments,
            child: AppText(
              'error_loading_comments'.tr(context),
              style: Get.bodySmall.px12.w600.copyWith(color: AppColors.primary),
            ),
          )
        else if (comments.isEmpty)
          AppText(
            'no_comments_yet'.tr(context),
            style: Get.bodySmall.px13.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.7),
            ),
          )
        else
          ...comments.map(_buildCommentCard),
      ],
    );
  }

  Widget _buildCommentComposer() {
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
            onPressed: _isSubmittingComment ? null : _submitComment,
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
              child: _isSubmittingComment
                  ? SizedBox(
                      key: const ValueKey('comment-loading'),
                      width: 18.st,
                      height: 18.st,
                      child: const CircularProgressIndicator(
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
                          setState(() {
                            _rating = index + 1;
                          });
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

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }
}
