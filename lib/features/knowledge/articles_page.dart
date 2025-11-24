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
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/knowledge/article_detail_page.dart';
import 'package:krishi/models/article.dart';

class ArticlesPage extends ConsumerStatefulWidget {
  const ArticlesPage({super.key});

  @override
  ConsumerState<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends ConsumerState<ArticlesPage> {
  List<Article> articles = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getArticles(page: 1);
      if (mounted) {
        setState(() {
          articles = response.results;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
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
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
        title: AppText(
          'kishan_gyaan'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (hasError) {
      return ErrorState(
        subtitle: 'error_loading_articles_subtitle'.tr(context),
        onRetry: _loadArticles,
      );
    }

    if (articles.isEmpty) {
      return EmptyState(
        title: 'no_articles_available'.tr(context),
        subtitle: 'no_articles_subtitle'.tr(context),
        icon: Icons.article_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16).rt,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return _buildArticleCard(articles[index]);
        },
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () {
        Get.to(ArticleDetailPage(articleId: article.id));
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
                        _formatDate(article.createdAt),
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

  String _formatDate(DateTime date) {
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
