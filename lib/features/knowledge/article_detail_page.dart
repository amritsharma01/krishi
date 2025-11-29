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
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/knowledge/providers/knowledge_providers.dart';
import 'package:krishi/models/article.dart';

class ArticleDetailPage extends ConsumerWidget {
  final int articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));

    return articleAsync.when(
      data: (articleData) => _buildArticleContent(context, articleData),
      loading: () => Scaffold(
        backgroundColor: Get.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Get.scaffoldBackgroundColor,
          elevation: 0,
          leading: _buildBackButton(context),
        ),
        body: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Get.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Get.scaffoldBackgroundColor,
          elevation: 0,
          leading: _buildBackButton(context),
        ),
        body: ErrorState(
          subtitle: 'error_loading_article'.tr(context),
          onRetry: () {
            ref.invalidate(articleDetailProvider(articleId));
          },
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context, Article articleData) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(articleData),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    articleData.title,
                    style: Get.bodyLarge.px22.w700.copyWith(
                      color: Get.bodyLarge.color ??
                          (Get.isDark ? Colors.white : Colors.black87),
                      height: 1.35,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.visible,
                  ),
                  14.verticalGap,
                  Wrap(
                    spacing: 10.rt,
                    runSpacing: 8.rt,
                    children: [
                      _buildMetaChip(
                        icon: Icons.person_outline,
                        label: articleData.authorName,
                      ),
                      _buildMetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: _formatDate(articleData.createdAt, context),
                      ),
                    ],
                  ),
                  10.verticalGap,
                  Divider(
                    color: Get.disabledColor.withValues(alpha: 0.2),
                  ),
                  10.verticalGap,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18).rt,
                    decoration: BoxDecoration(
                      color: Get.cardColor,
                      borderRadius: BorderRadius.circular(16).rt,
                      border: Border.all(
                        color: Get.disabledColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: AppText(
                      articleData.content,
                      style: Get.bodyMedium.px15.w400.copyWith(
                        color: Get.bodyMedium.color ??
                            (Get.isDark ? Colors.white : Colors.black87),
                        height: 1.7,
                      ),
                      maxLines: 100,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  32.verticalGap,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Article articleData) {
    return SliverAppBar(
      expandedHeight: 240.rt,
      pinned: true,
      stretch: true,
      backgroundColor: Get.scaffoldBackgroundColor,
      leadingWidth: 70.rt,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.rt, top: 8.rt, bottom: 8.rt),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12).rt,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18.st,
            ),
            onPressed: () => Get.pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            articleData.image != null
                ? Image.network(
                    Get.imageUrl(articleData.image),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildHeroPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildHeroPlaceholder(
                        isLoading: true,
                      );
                    },
                  )
                : _buildHeroPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPlaceholder({bool isLoading = false}) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              )
            : Icon(
                Icons.article_outlined,
                size: 80.st,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.rt, vertical: 8.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.st, color: Get.disabledColor.withValues(alpha: 0.8)),
          6.horizontalGap,
          AppText(
            label,
            style: Get.bodySmall.copyWith(
              color: Get.bodySmall.color ??
                  (Get.isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.rt),
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Get.disabledColor),
        onPressed: () => Get.pop(),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${'today'.tr(context)} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'yesterday'.tr(context);
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'days_ago'.tr(context)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

