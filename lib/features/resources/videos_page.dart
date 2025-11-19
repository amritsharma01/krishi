import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
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

  final Map<String, String> _categories = {
    'all': 'All Videos',
    'farming': 'Farming',
    'pest_control': 'Pest Control',
    'irrigation': 'Irrigation',
    'harvesting': 'Harvesting',
    'storage': 'Storage',
    'marketing': 'Marketing',
    'other': 'Other',
  };

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
        Get.snackbar('Failed to load videos: $e');
      }
    }
  }

  Future<void> _openVideo(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          Get.snackbar('Could not open video. Please check your internet connection');
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error opening video: $e');
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
          'Educational Videos',
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty
                    ? _buildEmptyState()
                    : _buildVideosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: 14.h,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: Colors.red.shade600,
                size: 20.st,
              ),
              8.horizontalGap,
              AppText(
                'Filter videos',
                style: Get.bodyMedium.w600.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          12.verticalGap,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.entries.map((entry) {
                final isSelected = _selectedCategory == entry.key;
                final color = _categoryColors[entry.key] ?? Colors.red;
                final icon = entry.key == 'all'
                    ? Icons.all_inclusive
                    : _categoryIcons[entry.key] ?? Icons.video_library_rounded;
                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
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
        ],
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
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                )
              : null,
          color: isSelected ? null : Get.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24).rt,
          border: Border.all(
            color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.st,
              color: isSelected ? Colors.white : color,
            ),
            8.horizontalGap,
            AppText(
              label,
              style: Get.bodySmall.w600.copyWith(
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No videos available',
            style: Get.bodyLarge.px18.w600.copyWith(color: Colors.grey.shade600),
          ),
          8.verticalGap,
          AppText(
            'Check back later for new content',
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList() {
    return RefreshIndicator(
      onRefresh: () => _loadVideos(category: _selectedCategory),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildVideoCard(Video video) {
    final thumbnailUrl = _getThumbnailUrl(video);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openVideo(video.youtubeUrl),
          borderRadius: BorderRadius.circular(16).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.rt),
                      topRight: Radius.circular(16.rt),
                    ),
                    child: thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumbnailUrl,
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200.h,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200.h,
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.video_library_rounded,
                                size: 60.st,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : Container(
                            height: 200.h,
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 60.st,
                              color: Colors.grey.shade600,
                            ),
                          ),
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.rt),
                          topRight: Radius.circular(16.rt),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(16.rt),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40.st,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4).rt,
                      ),
                      child: AppText(
                        video.duration,
                        style: Get.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(16.rt),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4).rt,
                          ),
                          child: AppText(
                            video.categoryDisplay,
                            style: Get.bodySmall.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.visibility_rounded,
                          size: 14.st,
                          color: Colors.grey.shade600,
                        ),
                        4.horizontalGap,
                        AppText(
                          '${video.viewsCount} views',
                          style: Get.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    12.verticalGap,
                    AppText(
                      video.title,
                      style: Get.bodyLarge.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.verticalGap,
                    AppText(
                      video.description,
                      style: Get.bodyMedium.copyWith(color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
