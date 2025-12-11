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
import 'package:krishi/features/marketplace/widgets/product_detail_widgets.dart';

import 'package:krishi/models/comment.dart';
import 'package:krishi/models/review.dart';

class FeedbackTabSelector extends ConsumerWidget {
  const FeedbackTabSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ['reviews'.tr(context), 'comments'.tr(context)];
    final tabIndex = ref.watch(feedbackTabIndexProvider);
    
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
                ref.read(feedbackTabIndexProvider.notifier).state = index;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.ht),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
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
}

class ReviewsPanel extends ConsumerWidget {
  final int productId;

  const ReviewsPanel({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    
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
        return Column(
          children: reviewsList.map((review) => ReviewCard(review: review)).toList(),
        );
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
        onPressed: () => ref.invalidate(productReviewsProvider(productId)),
        child: AppText(
          'error_loading_reviews'.tr(context),
          style: Get.bodySmall.px12.w600.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

class CommentsPanel extends ConsumerWidget {
  final int productId;
  final TextEditingController commentController;
  final VoidCallback onSubmit;

  const CommentsPanel({
    super.key,
    required this.productId,
    required this.commentController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(productCommentsProvider(productId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentComposer(controller: commentController, onSubmit: onSubmit),
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
              children: commentsList.map((comment) => CommentCard(comment: comment)).toList(),
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
            onPressed: () => ref.invalidate(productCommentsProvider(productId)),
            child: AppText(
              'error_loading_comments'.tr(context),
              style: Get.bodySmall.px12.w600.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class AddReviewDialog extends ConsumerStatefulWidget {
  final int productId;
  final VoidCallback onSubmit;

  const AddReviewDialog({
    super.key,
    required this.productId,
    required this.onSubmit,
  });

  @override
  ConsumerState<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends ConsumerState<AddReviewDialog> {
  @override
  Widget build(BuildContext context) {
    final rating = ref.watch(reviewRatingProvider);
    
    return Container(
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
              'add_review'.tr(context),
              style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
            ),
            20.verticalGap,
            AppText(
              'rating'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
            ),
            12.verticalGap,
            Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
