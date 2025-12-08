import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/crop_calendar_providers.dart';
import 'package:krishi/features/resources/widgets/crop_calendar_widgets.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';

class CropCalendarPage extends ConsumerStatefulWidget {
  const CropCalendarPage({super.key});

  @override
  ConsumerState<CropCalendarPage> createState() => _CropCalendarPageState();
}

class _CropCalendarPageState extends ConsumerState<CropCalendarPage> {

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCrops();
    });
  }

  Future<void> _loadCrops({String? cropType}) async {
    if (!mounted) return;

    final selectedType = cropType ?? ref.read(selectedCropTypeProvider);
    ref.read(isLoadingCropCalendarProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final crops = await apiService.getCropCalendar(
        cropType: selectedType == 'all' ? null : selectedType,
      );

      if (!mounted) return;

      ref.read(cropCalendarListProvider.notifier).state = crops;
      ref.read(isLoadingCropCalendarProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingCropCalendarProvider.notifier).state = false;
      Get.snackbar('Failed to load crop calendar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingCropCalendarProvider);
    final crops = ref.watch(cropCalendarListProvider);
    final hasCrops = crops.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'crop_calendar'.tr(context),
          style: Get.bodyLarge.px20.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          CropCalendarFilter(
            cropTypes: _getCropTypes(context),
            cropIcons: _cropIcons,
            cropColors: _cropColors,
            onFilterChanged: (cropType) => _loadCrops(cropType: cropType),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : hasCrops
                    ? _buildCropsList(context)
                    : EmptyStateWidget(
                        icon: Icons.calendar_today_rounded,
                        title: 'no_crops_available'.tr(context),
                        subtitle: 'check_back_later_info'.tr(context),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropsList(BuildContext context) {
    final crops = ref.watch(cropCalendarListProvider);
    final selectedType = ref.watch(selectedCropTypeProvider);

    return RefreshIndicator(
      onRefresh: () => _loadCrops(cropType: selectedType),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.wt,
          mainAxisSpacing: 16.ht,
          childAspectRatio: 0.65,
        ),
        itemCount: crops.length,
        itemBuilder: (context, index) {
          final crop = crops[index];
          final color = _cropColors[crop.cropType] ?? Colors.teal;
          final icon = _cropIcons[crop.cropType] ?? Icons.agriculture_rounded;
          return CropCard(
            crop: crop,
            color: color,
            icon: icon,
          );
        },
      ),
    );
  }
}
