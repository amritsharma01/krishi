import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class VideosPage extends ConsumerStatefulWidget {
  const VideosPage({super.key});

  @override
  ConsumerState<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends ConsumerState<VideosPage> {
  List<Video> _videos = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

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
    _loadVideos();
  }

  Future<void> _loadVideos({String? category}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final videos = await apiService.getVideos(
        category: category == 'all' ? null : category,
      );
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar('error_loading_products'.tr(context));
      }
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
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'educational_videos'.tr(context),
          style: Get.bodyLarge.px20.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty
                ? _buildEmptyState(context)
                : _buildVideosList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = _getCategories(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 12.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(28),
        ).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.entries.map((entry) {
            final isSelected = _selectedCategory == entry.key;
            final color = _categoryColors[entry.key] ?? Colors.red;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : _categoryIcons[entry.key] ?? Icons.video_library_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: _buildFilterPill(
                label: entry.value,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCategory = entry.key;
                  });
                  _loadVideos(category: entry.key);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.wt, vertical: 6.ht),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.st, color: isSelected ? Colors.white : color),
            6.horizontalGap,
            AppText(
              label,
              style: Get.bodySmall.px12.w600.copyWith(
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'no_videos_available'.tr(context),
            style: Get.bodyLarge.px18.w600.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          8.verticalGap,
          AppText(
            'check_back_later_videos'.tr(context),
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadVideos(category: _selectedCategory),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return _buildVideoCard(context, video);
        },
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video) {
    final thumbnailUrl = _getThumbnailUrl(video);
    final categoryColor = _categoryColors[video.category] ?? Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail tap target
          Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openVideo(context, video.youtubeUrl),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.rt),
                topRight: Radius.circular(20.rt),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.rt),
                      topRight: Radius.circular(20.rt),
                    ),
                    child: thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumbnailUrl,
                            width: double.infinity,
                            height: 180.ht,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 180.ht,
                              color: Get.cardColor.withValues(alpha: 0.3),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: categoryColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 180.ht,
                              color: Get.cardColor.withValues(alpha: 0.3),
                              child: Icon(
                                Icons.video_library_rounded,
                                size: 50.st,
                                color: Get.disabledColor.withValues(alpha: 0.5),
                              ),
                            ),
                          )
                        : Container(
                            height: 180.ht,
                            color: Get.cardColor.withValues(alpha: 0.3),
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 50.st,
                              color: Get.disabledColor.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.rt),
                          topRight: Radius.circular(20.rt),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(14.rt),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32.st,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 10.rt,
                    right: 10.rt,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.wt,
                        vertical: 4.ht,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8).rt,
                      ),
                      child: AppText(
                        video.duration,
                        style: Get.bodySmall.px11.w600.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(18.rt),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.wt,
                        vertical: 5.ht,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8).rt,
                      ),
                      child: AppText(
                        video.categoryDisplay,
                        style: Get.bodySmall.px12.w600.copyWith(
                          color: categoryColor,
                        ),
                      ),
                    ),
                    14.verticalGap,
                    // Title
                    AppText(
                      video.title,
                      style: Get.bodyLarge.px16.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    10.verticalGap,
                    // Description
                    AppText(
                      video.description,
                      style: Get.bodyMedium.px13.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    12.verticalGap,
                    // Views
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 14.st,
                          color: Get.disabledColor.withValues(alpha: 0.5),
                        ),
                        6.horizontalGap,
                        AppText(
                          '${video.viewsCount} ${'views'.tr(context)}',
                          style: Get.bodySmall.px12.copyWith(
                            color: Get.disabledColor.withValues(alpha: 0.6),
                          ),
                        ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _openVideo(context, video.youtubeUrl),
                      icon: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.red.shade600,
                        size: 18.st,
                      ),
                      label: AppText(
                        'watch_video'.tr(context),
                        style: Get.bodySmall.px12.w600.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
