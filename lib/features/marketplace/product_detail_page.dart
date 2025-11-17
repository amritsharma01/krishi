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

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addComment(
        widget.product.id,
        _commentController.text.trim(),
      );
      _commentController.clear();
      _loadComments();
      Get.snackbar('comment_added'.tr(context), color: Colors.green);
    } catch (e) {
      Get.snackbar('error_adding_comment'.tr(context), color: Colors.red);
    }
  }

  Future<void> _submitReview() async {
    if (_reviewCommentController.text.trim().length < 10) {
      Get.snackbar('review_too_short'.tr(context), color: Colors.red);
      return;
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addReview(
        productId: widget.product.id,
        rating: _rating,
        comment: _reviewCommentController.text.trim(),
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
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.verticalGap,
                  _buildProductInfo(),
                  16.verticalGap,
                  _buildSellerInfo(),
                  16.verticalGap,
                  _buildDescription(),
                  20.verticalGap,
                  _buildReviewsSection(),
                  20.verticalGap,
                  _buildCommentsSection(),
                  24.verticalGap,
                  _buildAddToCartButton(),
                  40.verticalGap,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rt),
      child: SizedBox(
        width: double.infinity,
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
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300.rt,
      pinned: true,
      stretch: true,
      backgroundColor: Get.scaffoldBackgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8).rt,
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8).rt,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              color: Get.disabledColor,
              size: 20.st,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.product.image != null
                ? Image.network(
                    Get.imageUrl(widget.product.image),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80.st,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80.st,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100.rt,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Get.scaffoldBackgroundColor.withValues(alpha: 0.7),
                      Get.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
      _metaChip(Icons.inventory_2_outlined, widget.product.sellerEmail),
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
    final phone = widget.product.sellerPhoneNumber;
    return _sectionCard(
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
                  widget.product.sellerEmail,
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  4.verticalGap,
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14.st,
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                      6.horizontalGap,
                      AppText(
                        phone,
                        style: Get.bodySmall.px12.w600.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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

  Widget _buildReviewsSection() {
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
          if (isLoadingReviews)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16).rt,
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (reviewsError)
            TextButton(
              onPressed: _loadReviews,
              child: AppText(
                'error_loading_reviews'.tr(context),
                style: Get.bodySmall.px12.w600.copyWith(
                  color: AppColors.primary,
                ),
              ),
            )
          else if (reviews.isEmpty)
            AppText(
              'no_reviews_yet'.tr(context),
              style: Get.bodySmall.px13.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.7),
              ),
            )
          else
            ...reviews.map(_buildReviewCard),
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
                      review.userEmail,
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

  Widget _buildCommentsSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'comments'.tr(context),
            style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
          ),
          12.verticalGap,
          _buildCommentInput(),
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
                style: Get.bodySmall.px12.w600.copyWith(
                  color: AppColors.primary,
                ),
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
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12).rt,
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
          IconButton(
            onPressed: _submitComment,
            icon: Icon(Icons.send_rounded, color: AppColors.primary),
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
                  comment.userEmail,
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
