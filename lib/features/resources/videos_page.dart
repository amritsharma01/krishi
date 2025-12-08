import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/videos_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/videos_widgets.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class VideosPage extends ConsumerStatefulWidget {
  const VideosPage({super.key});

  @override
  ConsumerState<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends ConsumerState<VideosPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

  Map<String, String> _getCategories(BuildContext context) {
    return {
      'all': 'all_videos'.tr(context),
      'farming': 'farming'.tr(context),
      'pest_control': 'pest_control'.tr(context),
      'irrigation': 'irrigation'.tr(context),
      'harvesting': 'harvesting'.tr(context),
      'storage': 'storage'.tr(context),
      'marketing': 'marketing'.tr(context),
      'other': 'other'.tr(context),
    };
  }

  final Map<String, IconData> _categoryIcons = {
    'farming': Icons.agriculture_rounded,
    'pest_control': Icons.pest_control_rounded,
    'irrigation': Icons.water_drop_rounded,
    'harvesting': Icons.grass_rounded,
    'storage': Icons.warehouse_rounded,
    'marketing': Icons.shopping_cart_rounded,
    'other': Icons.video_library_rounded,
  };

  final Map<String, Color> _categoryColors = {
    'farming': Colors.green,
    'pest_control': Colors.orange,
    'irrigation': Colors.blue,
    'harvesting': Colors.amber,
    'storage': Colors.brown,
    'marketing': Colors.purple,
    'other': Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideos();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos({String? category, bool force = false}) async {
    if (!mounted) return;

    final selectedCategory =
        category ?? ref.read(selectedVideoCategoryProvider);

    // Reset if category changed or force refresh
    if (category != null || force) {
      _hasLoaded = false;
    }

    if (!force && _hasLoaded && ref.read(videosListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingVideosProvider.notifier).state = true;
    ref.read(videosCurrentPageProvider.notifier).state = 1;
    ref.read(videosHasMoreProvider.notifier).state = true;
    ref.read(videosListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getVideos(
        category: selectedCategory == 'all' ? null : selectedCategory,
        page: 1,
        pageSize: 10,
      );

      if (!mounted) return;

      ref.read(videosListProvider.notifier).state = response.results;
      ref.read(isLoadingVideosProvider.notifier).state = false;
      ref.read(videosHasMoreProvider.notifier).state = response.next != null;
      ref.read(videosCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingVideosProvider.notifier).state = false;
      Get.snackbar('error_loading_products'.tr(context));
    }
  }

  Future<void> _loadMoreVideos() async {
    final isLoading = ref.read(isLoadingMoreVideosProvider);
    final hasMore = ref.read(videosHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreVideosProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(videosCurrentPageProvider);
      final selectedCategory = ref.read(selectedVideoCategoryProvider);

      final response = await apiService.getVideos(
        category: selectedCategory == 'all' ? null : selectedCategory,
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentVideos = ref.read(videosListProvider);
      ref.read(videosListProvider.notifier).state = [
        ...currentVideos,
        ...response.results,
      ];
      ref.read(videosHasMoreProvider.notifier).state = response.next != null;
      ref.read(videosCurrentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMoreVideosProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreVideosProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreVideosProvider);
    final hasMore = ref.read(videosHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreVideos();
    }
  }

  Future<void> _openVideo(BuildContext context, String url) async {
    try {
      // Normalize YouTube URL
      String videoUrl = url.trim();

      // If URL is empty, return early
      if (videoUrl.isEmpty) {
        if (mounted) {
          Get.snackbar('video_url_empty'.tr(context));
        }
        return;
      }

      // If URL is relative or doesn't start with http, prepend https://
      if (!videoUrl.startsWith('http://') && !videoUrl.startsWith('https://')) {
        // Check if it's just a video ID (11 characters)
        if (videoUrl.length == 11 &&
            RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(videoUrl)) {
          videoUrl = 'https://www.youtube.com/watch?v=$videoUrl';
        } else if (videoUrl.startsWith('www.') ||
            videoUrl.startsWith('youtube.com') ||
            videoUrl.startsWith('youtu.be')) {
          videoUrl = 'https://$videoUrl';
        } else {
          // Assume it's a video ID
          videoUrl = 'https://www.youtube.com/watch?v=$videoUrl';
        }
      }

      // Convert youtu.be to youtube.com format
      if (videoUrl.contains('youtu.be/')) {
        final parts = videoUrl.split('youtu.be/');
        if (parts.length > 1) {
          final videoId = parts[1].split('?').first.split('&').first;
          videoUrl = 'https://www.youtube.com/watch?v=$videoId';
        }
      }

      // Extract video ID if it's a full YouTube URL
      String? videoId;
      if (videoUrl.contains('youtube.com/watch?v=')) {
        final match = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(videoUrl);
        videoId = match?.group(1);
      } else if (videoUrl.contains('youtube.com/embed/')) {
        final match = RegExp(
          r'/embed/([a-zA-Z0-9_-]{11})',
        ).firstMatch(videoUrl);
        videoId = match?.group(1);
      }

      // If we have a video ID, construct proper URL
      if (videoId != null && videoId.isNotEmpty) {
        videoUrl = 'https://www.youtube.com/watch?v=$videoId';
      }

      // Ensure it's a valid YouTube URL
      if (!videoUrl.contains('youtube.com') && !videoUrl.contains('youtu.be')) {
        if (mounted) {
          Get.snackbar('invalid_video_url'.tr(context));
        }
        return;
      }

      final uri = Uri.parse(videoUrl);

      // Try to launch the URL - don't check canLaunchUrl first, just try
      try {
        // Try external application first (YouTube app or browser)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        // If external fails, try platform default
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          // Last resort: in-app web view
          try {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          } catch (e3) {
            if (mounted) {
              Get.snackbar('could_not_open_video'.tr(context));
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('error_opening_video'.tr(context));
      }
    }
  }

  String _getThumbnailUrl(Video video) {
    if (video.thumbnail != null && video.thumbnail!.isNotEmpty) {
      return video.thumbnail!;
    }

    // Extract YouTube video ID and generate thumbnail
    final videoId = video.youtubeVideoId;
    if (videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingVideosProvider);
    final videos = ref.watch(videosListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreVideosProvider);
    final hasVideos = videos.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'educational_videos'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          VideosCategoryFilter(
            categories: _getCategories(context),
            categoryIcons: _categoryIcons,
            categoryColors: _categoryColors,
            onFilterChanged: (category) =>
                _loadVideos(category: category, force: true),
          ),
          Expanded(
            child: isLoading && videos.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : !hasVideos
                ? EmptyStateWidget(
                    icon: Icons.video_library_rounded,
                    title: 'no_videos_available'.tr(context),
                    subtitle: 'check_back_later_videos'.tr(context),
                  )
                : _buildVideosList(context, isLoadingMore),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList(BuildContext context, bool isLoadingMore) {
    final videos = ref.watch(videosListProvider);
    final selectedCategory = ref.watch(selectedVideoCategoryProvider);

    return RefreshIndicator(
      onRefresh: () => _loadVideos(category: selectedCategory, force: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: videos.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == videos.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.red.shade700,
                  ),
                ),
              ),
            );
          }
          final video = videos[index];
          final thumbnailUrl = _getThumbnailUrl(video);
          final categoryColor = _categoryColors[video.category] ?? Colors.red;
          return VideoCard(
            video: video,
            thumbnailUrl: thumbnailUrl,
            categoryColor: categoryColor,
            onTap: () => _openVideo(context, video.youtubeUrl),
          );
        },
      ),
    );
  }
}
