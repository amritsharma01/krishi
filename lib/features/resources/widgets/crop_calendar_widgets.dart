import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
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
          children: cropTypes.entries.map((entry) {
            final isSelected = selectedType == entry.key;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : cropIcons[entry.key] ?? Icons.agriculture_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 5.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
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
  final IconData icon;

  const CropCard({
    super.key,
    required this.crop,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16).rt,
        child: InkWell(
          borderRadius: BorderRadius.circular(16).rt,
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
              _CropHeader(crop: crop, icon: icon),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(10.rt),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _TypeBadge(
                          text: crop.cropTypeDisplay,
                        ),
                      ),
                      6.verticalGap,
                      Flexible(
                        child: AppText(
                          crop.cropName,
                          style: Get.bodyMedium.px13.w600.copyWith(
                            color: Get.disabledColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      6.verticalGap,
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 10.st,
                            color: Get.disabledColor.withValues(alpha: 0.6),
                          ),
                          4.horizontalGap,
                          Flexible(
                            child: AppText(
                              '${crop.durationDays} ${'days'.tr(context)}',
                              style: Get.bodySmall.px10.copyWith(
                                color: Get.disabledColor.withValues(alpha: 0.6),
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
  final IconData icon;

  const _CropHeader({
    required this.crop,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.ht,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(16)).rt,
        child: crop.image != null && crop.image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: crop.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _HeaderFallback(icon: icon),
              )
            : _HeaderFallback(icon: icon),
      ),
    );
  }
}

class _HeaderFallback extends StatelessWidget {
  final IconData icon;

  const _HeaderFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Icon(icon, size: 32.st, color: AppColors.primary),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String text;

  const _TypeBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wt, vertical: 3.ht),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12).rt,
      ),
      child: AppText(
        text,
        style: Get.bodySmall.px10.w600.copyWith(color: AppColors.primary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
