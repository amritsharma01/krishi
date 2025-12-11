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
import 'package:krishi/features/knowledge/news_detail_page.dart';
import 'package:krishi/features/knowledge/providers/knowledge_providers.dart';
import 'package:krishi/models/article.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNews();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNews({bool force = false}) async {
    if (!force && _hasLoaded && ref.read(newsListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingNewsProvider.notifier).state = true;
    ref.read(newsCurrentPageProvider.notifier).state = 1;
    ref.read(newsHasMoreProvider.notifier).state = true;
    ref.read(newsListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getNews(page: 1, pageSize: 10);

      if (mounted) {
        ref.read(newsListProvider.notifier).state = response.results;
        ref.read(isLoadingNewsProvider.notifier).state = false;
        ref.read(newsHasMoreProvider.notifier).state = response.next != null;
        ref.read(newsCurrentPageProvider.notifier).state = 2;
        _hasLoaded = true;
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingNewsProvider.notifier).state = false;
      }
    }
  }

  Future<void> _loadMoreNews() async {
    final isLoading = ref.read(isLoadingMoreNewsProvider);
    final hasMore = ref.read(newsHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreNewsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(newsCurrentPageProvider);
      final response = await apiService.getNews(page: currentPage, pageSize: 10);

      if (mounted) {
        final currentNews = ref.read(newsListProvider);
        ref.read(newsListProvider.notifier).state = [
          ...currentNews,
          ...response.results,
        ];
        ref.read(newsHasMoreProvider.notifier).state = response.next != null;
        ref.read(newsCurrentPageProvider.notifier).state = currentPage + 1;
        ref.read(isLoadingMoreNewsProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingMoreNewsProvider.notifier).state = false;
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreNewsProvider);
    final hasMore = ref.read(newsHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingNewsProvider);
    final news = ref.watch(newsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreNewsProvider);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
        title: AppText(
          'news_information'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNews(force: true),
        child: isLoading && news.isEmpty
            ? Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : news.isEmpty
                ? EmptyState(
                    title: 'no_news_available'.tr(context),
                    subtitle: 'no_news_subtitle'.tr(context),
                    icon: Icons.newspaper_outlined,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8).rt,
                    itemCount: news.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == news.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6).rt,
                          child: Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        );
                      }
                      return _buildNewsCard(context, news[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Get.to(NewsDetailPage(newsId: article.id));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 6.rt),
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
