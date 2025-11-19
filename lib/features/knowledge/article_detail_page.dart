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
import 'package:krishi/models/article.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  final int articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  Article? article;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final articleData = await apiService.getArticle(widget.articleId);
      if (mounted) {
        setState(() {
          article = articleData;
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: Get.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Get.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Get.disabledColor),
            onPressed: () => Get.pop(),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (hasError || article == null) {
      return Scaffold(
        backgroundColor: Get.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Get.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Get.disabledColor),
            onPressed: () => Get.pop(),
          ),
        ),
        body: ErrorState(
          subtitle: 'error_loading_article'.tr(context),
          onRetry: _loadArticle,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    article!.title,
                    style: Get.bodyLarge.px28.w800.copyWith(
                      color: Get.disabledColor,
                      height: 1.3,
                    ),
                  ),
                  20.verticalGap,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8).rt,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8).rt,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20.st,
                        ),
                      ),
                      12.horizontalGap,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              article!.authorName,
                              style: Get.bodyMedium.px14.w600.copyWith(
                                color: Get.disabledColor,
                              ),
                            ),
                            4.verticalGap,
                            AppText(
                              _formatDate(article!.createdAt),
                              style: Get.bodySmall.px12.copyWith(
                                color: Get.disabledColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  24.verticalGap,
                  AppText(
                    article!.content,
                    style: Get.bodyMedium.px16.w400.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.85),
                      height: 1.7,
                    ),
                  ),
                  40.verticalGap,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250.rt,
      pinned: true,
      backgroundColor: Get.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8).rt,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(Icons.arrow_back, color: Get.disabledColor, size: 20.st),
        ),
        onPressed: () => Get.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: article?.image != null
            ? Image.network(
                Get.imageUrl(article!.image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.article,
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
                    Icons.article,
                    size: 80.st,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

