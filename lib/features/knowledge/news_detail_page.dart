import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/article.dart';

class NewsDetailPage extends ConsumerWidget {
  final Article news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    news.title,
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
                              const Color(0xFF1976D2),
                              const Color(0xFF42A5F5),
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
                              news.authorName,
                              style: Get.bodyMedium.px14.w600.copyWith(
                                color: Get.disabledColor,
                              ),
                            ),
                            4.verticalGap,
                            AppText(
                              _formatDate(context, news.createdAt),
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
                    news.content,
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

  Widget _buildAppBar(BuildContext context) {
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
        background: news.image != null
            ? Image.network(
                Get.imageUrl(news.image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.newspaper,
                        size: 80.st,
                        color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                child: Center(
                  child: Icon(
                    Icons.newspaper,
                    size: 80.st,
                    color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                  ),
                ),
              ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
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

