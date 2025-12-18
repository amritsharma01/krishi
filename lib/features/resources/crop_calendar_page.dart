import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

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
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCrops();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops({String? cropType, bool force = false}) async {
    if (!mounted) return;

    final selectedType = cropType ?? ref.read(selectedCropTypeProvider);
    
    // Reset if crop type changed or force refresh
    if (cropType != null || force) {
      _hasLoaded = false;
    }
    
    if (!force && _hasLoaded && ref.read(cropCalendarListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingCropCalendarProvider.notifier).state = true;
    ref.read(cropCalendarCurrentPageProvider.notifier).state = 1;
    ref.read(cropCalendarHasMoreProvider.notifier).state = true;
    ref.read(cropCalendarListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getCropCalendar(
        cropType: selectedType == 'all' ? null : selectedType,
        page: 1,
        pageSize: 10,
      );

      if (!mounted) return;

      ref.read(cropCalendarListProvider.notifier).state = response.results;
      ref.read(isLoadingCropCalendarProvider.notifier).state = false;
      ref.read(cropCalendarHasMoreProvider.notifier).state = response.next != null;
      ref.read(cropCalendarCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingCropCalendarProvider.notifier).state = false;
      Get.snackbar('Failed to load crop calendar: $e');
    }
  }

  Future<void> _loadMoreCrops() async {
    final isLoading = ref.read(isLoadingMoreCropCalendarProvider);
    final hasMore = ref.read(cropCalendarHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreCropCalendarProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(cropCalendarCurrentPageProvider);
      final selectedType = ref.read(selectedCropTypeProvider);
      
      final response = await apiService.getCropCalendar(
        cropType: selectedType == 'all' ? null : selectedType,
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentCrops = ref.read(cropCalendarListProvider);
      ref.read(cropCalendarListProvider.notifier).state = [
        ...currentCrops,
        ...response.results,
      ];
      ref.read(cropCalendarHasMoreProvider.notifier).state = response.next != null;
      ref.read(cropCalendarCurrentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMoreCropCalendarProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreCropCalendarProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreCropCalendarProvider);
    final hasMore = ref.read(cropCalendarHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreCrops();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingCropCalendarProvider);
    final crops = ref.watch(cropCalendarListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreCropCalendarProvider);
    final hasCrops = crops.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'crop_calendar'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          CropCalendarFilter(
            cropTypes: _getCropTypes(context),
            cropIcons: _cropIcons,
            cropColors: _cropColors,
            onFilterChanged: (cropType) => _loadCrops(cropType: cropType, force: true),
          ),
          Expanded(
            child: isLoading && crops.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : !hasCrops
                    ? EmptyStateWidget(
                        icon: Icons.calendar_today_rounded,
                        title: 'no_crops_available'.tr(context),
                        subtitle: 'check_back_later_info'.tr(context),
                      )
                    : _buildCropsList(context, isLoadingMore),
          ),
        ],
      ),
    );
  }

  Widget _buildCropsList(BuildContext context, bool isLoadingMore) {
    final crops = ref.watch(cropCalendarListProvider);
    final selectedType = ref.watch(selectedCropTypeProvider);

    return RefreshIndicator(
      onRefresh: () => _loadCrops(cropType: selectedType, force: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.wt,
          mainAxisSpacing: 8.ht,
          childAspectRatio: 0.7,
        ),
        itemCount: crops.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == crops.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          final crop = crops[index];
          final icon = _cropIcons[crop.cropType] ?? Icons.agriculture_rounded;
          return CropCard(
            crop: crop,
            icon: icon,
          );
        },
      ),
    );
  }
}
