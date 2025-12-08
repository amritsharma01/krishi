import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/crop_detail_page.dart';
import 'package:krishi/features/resources/providers/crop_calendar_providers.dart';
import 'package:krishi/features/resources/widgets/filter_pill.dart';
import 'package:krishi/models/resources.dart';

class CropCalendarFilter extends ConsumerWidget {
  final Map<String, String> cropTypes;
  final Map<String, IconData> cropIcons;
  final Map<String, Color> cropColors;
  final Future<void> Function(String?) onFilterChanged;

  const CropCalendarFilter({
    super.key,
    required this.cropTypes,
    required this.cropIcons,
    required this.cropColors,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedCropTypeProvider);

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
          children: cropTypes.entries.map((entry) {
            final isSelected = selectedType == entry.key;
            final color = cropColors[entry.key] ?? Colors.green;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : cropIcons[entry.key] ?? Icons.agriculture_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedCropTypeProvider.notifier).state = entry.key;
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

class CropCard extends StatelessWidget {
  final CropCalendar crop;
  final Color color;
  final IconData icon;

  const CropCard({
    super.key,
    required this.crop,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(22).rt,
        border: Border.all(color: color.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22).rt,
        child: InkWell(
          borderRadius: BorderRadius.circular(22).rt,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CropDetailPage(crop: crop),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CropHeader(crop: crop, color: color, icon: icon),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(16.rt),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _TypeBadge(
                          text: crop.cropTypeDisplay,
                          color: color,
                        ),
                      ),
                      12.verticalGap,
                      Flexible(
                        child: AppText(
                          crop.cropName,
                          style: Get.bodyLarge.px16.w700.copyWith(
                            color: Get.disabledColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      10.verticalGap,
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12.st,
                            color: Colors.grey.shade600,
                          ),
                          6.horizontalGap,
                          Flexible(
                            child: AppText(
                              '${crop.durationDays} days',
                              style: Get.bodyMedium.px10.copyWith(
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropHeader extends StatelessWidget {
  final CropCalendar crop;
  final Color color;
  final IconData icon;

  const _CropHeader({
    required this.crop,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.ht,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(22)).rt,
        child: crop.image != null && crop.image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: crop.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: color.withValues(alpha: 0.15),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _HeaderFallback(color: color, icon: icon),
              )
            : _HeaderFallback(color: color, icon: icon),
      ),
    );
  }
}

class _HeaderFallback extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _HeaderFallback({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, size: 42.st, color: Colors.white),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _TypeBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wt, vertical: 4.ht),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30).rt,
      ),
      child: AppText(
        text,
        style: Get.bodySmall.px12.w600.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
