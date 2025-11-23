import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/crop_detail_page.dart';
import 'package:krishi/models/resources.dart';

class CropCalendarPage extends ConsumerStatefulWidget {
  const CropCalendarPage({super.key});

  @override
  ConsumerState<CropCalendarPage> createState() => _CropCalendarPageState();
}

class _CropCalendarPageState extends ConsumerState<CropCalendarPage> {
  List<CropCalendar> _crops = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  Map<String, String> _getCropTypes(BuildContext context) {
    return {
      'all': 'all_crops'.tr(context),
      'cereal': 'cereals'.tr(context),
      'vegetable': 'vegetables'.tr(context),
      'fruit': 'fruits'.tr(context),
      'pulses': 'pulses'.tr(context),
      'cash_crop': 'cash_crops'.tr(context),
      'other': 'other'.tr(context),
    };
  }

  final Map<String, IconData> _cropIcons = {
    'cereal': Icons.grain_rounded,
    'vegetable': Icons.eco_rounded,
    'fruit': Icons.apple_rounded,
    'pulses': Icons.spa_rounded,
    'cash_crop': Icons.attach_money_rounded,
    'other': Icons.agriculture_rounded,
  };

  final Map<String, Color> _cropColors = {
    'cereal': Colors.amber,
    'vegetable': Colors.green,
    'fruit': Colors.red,
    'pulses': Colors.brown,
    'cash_crop': Colors.purple,
    'other': Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops({String? cropType}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final crops = await apiService.getCropCalendar(
        cropType: cropType == 'all' ? null : cropType,
      );
      setState(() {
        _crops = crops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar('Failed to load crop calendar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'crop_calendar'.tr(context),
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTypeFilter(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _crops.isEmpty
                ? _buildEmptyState(context)
                : _buildCropsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    final cropTypes = _getCropTypes(context);
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
                color: Colors.green.shade600,
                size: 20.st,
              ),
              8.horizontalGap,
              AppText(
                'filter_crops'.tr(context),
                style: Get.bodyMedium.w600.copyWith(
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          12.verticalGap,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cropTypes.entries.map((entry) {
                final isSelected = _selectedType == entry.key;
                final color = _cropColors[entry.key] ?? Colors.green;
                final icon = entry.key == 'all'
                    ? Icons.all_inclusive
                    : _cropIcons[entry.key] ?? Icons.agriculture_rounded;
                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: _buildFilterPill(
                    label: entry.value,
                    icon: icon,
                    color: color,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedType = entry.key;
                      });
                      _loadCrops(cropType: entry.key);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'no_crops_available'.tr(context),
            style: Get.bodyLarge.px18.w600.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          8.verticalGap,
          AppText(
            'check_back_later_info'.tr(context),
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCropsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadCrops(cropType: _selectedType),
      child: GridView.builder(
        padding: EdgeInsets.all(10.rt),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.65,
        ),
        itemCount: _crops.length,
        itemBuilder: (context, index) {
          final crop = _crops[index];
          return _buildCropCard(context, crop);
        },
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, CropCalendar crop) {
    final color = _cropColors[crop.cropType] ?? Colors.teal;
    final icon = _cropIcons[crop.cropType] ?? Icons.agriculture_rounded;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCropHeader(crop, color, icon),
              Padding(
                padding: EdgeInsets.all(16.rt),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeBadge(crop.cropTypeDisplay, color),
                    12.verticalGap,
                    AppText(
                      crop.cropName,
                      style: Get.bodyLarge.px16.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                        AppText(
                          '${crop.durationDays} days',
                          style: Get.bodyMedium.px10.copyWith(
                            color: Colors.grey.shade600,
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
      ),
    );
  }

  Widget _buildCropHeader(CropCalendar crop, Color color, IconData icon) {
    return SizedBox(
      height: 100.h,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: const Radius.circular(22)).rt,
        child: crop.image != null && crop.image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: crop.image!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: color.withValues(alpha: 0.15),
                  child: Center(child: CircularProgressIndicator(color: color)),
                ),
                errorWidget: (context, url, error) =>
                    _buildHeaderFallback(color, icon),
              )
            : _buildHeaderFallback(color, icon),
      ),
    );
  }

  Widget _buildHeaderFallback(Color color, IconData icon) {
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

  Widget _buildTypeBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30).rt,
      ),
      child: AppText(
        text,
        style: Get.bodySmall.px12.w600.copyWith(color: color),
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
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.85)])
              : null,
          color: isSelected ? null : Get.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24).rt,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : color.withValues(alpha: 0.3),
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
            Icon(icon, size: 16.st, color: isSelected ? Colors.white : color),
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
}
