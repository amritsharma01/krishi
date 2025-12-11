import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/videos_providers.dart';
import 'package:krishi/features/resources/widgets/filter_pill.dart';
import 'package:krishi/models/resources.dart';

class VideosCategoryFilter extends ConsumerWidget {
  final Map<String, String> categories;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;
  final Future<void> Function(String?) onFilterChanged;

  const VideosCategoryFilter({
    super.key,
    required this.categories,
    required this.categoryIcons,
    required this.categoryColors,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedVideoCategoryProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wt, vertical: 5.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(20),
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
            final isSelected = selectedCategory == entry.key;
            final color = categoryColors[entry.key] ?? Colors.red;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : categoryIcons[entry.key] ?? Icons.video_library_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 5.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedVideoCategoryProvider.notifier).state =
                      entry.key;
                  onFilterChanged(entry.key);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final Video video;
  final String thumbnailUrl;
  final Color categoryColor;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.video,
    required this.thumbnailUrl,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.rt),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20).rt,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.rt),
                  topRight: Radius.circular(20.rt),
                ),
                child: Stack(
                  children: [
                    thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumbnailUrl,
                            width: double.infinity,
                            height: 100.ht,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: 100.ht,
                              color: Get.cardColor.withValues(alpha: 0.3),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: categoryColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height: 100.ht,
                              color: Get.cardColor.withValues(alpha: 0.3),
                              child: Icon(
                                Icons.video_library_rounded,
                                size: 30.st,
                                color: Get.disabledColor.withValues(alpha: 0.5),
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 100.ht,
                            color: Get.cardColor.withValues(alpha: 0.3),
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 30.st,
                              color: Get.disabledColor.withValues(alpha: 0.5),
                            ),
                          ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.rt),
                            topRight: Radius.circular(20.rt),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(10.rt),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26.st,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.rt),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    4.verticalGap,
                    AppText(
                      video.title,
                      style: Get.bodyLarge.px14.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.verticalGap,
                    AppText(
                      video.description,
                      style: Get.bodyMedium.px12.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                      maxLines: null,
                      overflow: TextOverflow.visible,
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
