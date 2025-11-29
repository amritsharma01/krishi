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
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/knowledge/news_detail_page.dart';
import 'package:krishi/features/knowledge/providers/knowledge_providers.dart';
import 'package:krishi/models/article.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
        title: AppText(
          'news_information'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: newsAsync.when(
        data: (newsList) {
          if (newsList.isEmpty) {
            return EmptyState(
              title: 'no_news_available'.tr(context),
              subtitle: 'no_news_subtitle'.tr(context),
              icon: Icons.newspaper_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(newsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16).rt,
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return _buildNewsCard(context, newsList[index]);
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stack) => ErrorState(
          subtitle: 'error_loading_news_subtitle'.tr(context),
          onRetry: () {
            ref.invalidate(newsProvider);
          },
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Get.to(NewsDetailPage(news: article));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.rt),
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: Get.disabledColor.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.image != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.rt),
                  topRight: Radius.circular(16.rt),
                ),
                child: Image.network(
                  Get.imageUrl(article.image),
                  width: double.infinity,
                  height: 200.rt,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200.rt,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48.st,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 200.rt,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    article.title,
                    style: Get.bodyLarge.px18.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                    maxLines: 2,
                  ),
                  12.verticalGap,
                  AppText(
                    article.content,
                    style: Get.bodyMedium.px14.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 3,
                  ),
                  12.verticalGap,
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.st,
                        color: Get.disabledColor.withValues(alpha: 0.5),
                      ),
                      6.horizontalGap,
                      AppText(
                        article.authorName,
                        style: Get.bodySmall.px12.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.6),
                        ),
                      ),
                      16.horizontalGap,
                      Icon(
                        Icons.calendar_today,
                        size: 16.st,
                        color: Get.disabledColor.withValues(alpha: 0.5),
                      ),
                      6.horizontalGap,
                      AppText(
                        _formatDate(article.createdAt, context),
                        style: Get.bodySmall.px12.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today'.tr(context);
    } else if (difference.inDays == 1) {
      return 'yesterday'.tr(context);
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'days_ago'.tr(context)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
