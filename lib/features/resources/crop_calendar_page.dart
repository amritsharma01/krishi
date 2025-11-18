import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
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

  final Map<String, String> _cropTypes = {
    'all': 'All Crops',
    'cereal': 'Cereals',
    'vegetable': 'Vegetables',
    'fruit': 'Fruits',
    'pulses': 'Pulses',
    'cash_crop': 'Cash Crops',
    'other': 'Other',
  };

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
          'Crop Calendar',
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTypeFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _crops.isEmpty
                    ? _buildEmptyState()
                    : _buildCropsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _cropTypes.entries.map((entry) {
            final isSelected = _selectedType == entry.key;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: FilterChip(
                label: AppText(
                  entry.value,
                  style: Get.bodySmall.copyWith(
                    color: isSelected ? Colors.white : Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = entry.key;
                  });
                  _loadCrops(cropType: entry.key);
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20).rt,
                  side: BorderSide(
                    color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }).toList(),
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
            Icons.calendar_today_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'No crops available',
            style: Get.bodyLarge.px18.w600.copyWith(color: Colors.grey.shade600),
          ),
          8.verticalGap,
          AppText(
            'Check back later for information',
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCropsList() {
    return RefreshIndicator(
      onRefresh: () => _loadCrops(cropType: _selectedType),
      child: GridView.builder(
        padding: EdgeInsets.all(16.rt),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.75,
        ),
        itemCount: _crops.length,
        itemBuilder: (context, index) {
          final crop = _crops[index];
          return _buildCropCard(crop);
        },
      ),
    );
  }

  Widget _buildCropCard(CropCalendar crop) {
    final color = _cropColors[crop.cropType] ?? Colors.teal;
    final icon = _cropIcons[crop.cropType] ?? Icons.agriculture_rounded;

    return Container(
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CropDetailPage(crop: crop),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or Icon
              if (crop.image != null && crop.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.rt),
                      topRight: Radius.circular(16.rt),
                    ),
                  child: CachedNetworkImage(
                    imageUrl: crop.image!,
                    width: double.infinity,
                    height: 120.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120.h,
                      color: color.withValues(alpha: 0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: color,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.7), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 50.st,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.7), color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.rt),
                      topRight: Radius.circular(16.rt),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 50.st,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.rt),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4).rt,
                        ),
                        child: AppText(
                          crop.cropTypeDisplay,
                          style: Get.bodySmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      8.verticalGap,
                      AppText(
                        crop.cropName,
                        style: Get.bodyLarge.w600,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14.st,
                            color: Colors.grey.shade600,
                          ),
                          4.horizontalGap,
                          Expanded(
                            child: AppText(
                              '${crop.durationDays} days',
                              style: Get.bodySmall.copyWith(
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
