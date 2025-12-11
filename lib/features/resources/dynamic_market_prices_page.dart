import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/dynamic_market_prices_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/models/resources.dart';

class DynamicMarketPricesPage extends ConsumerStatefulWidget {
  const DynamicMarketPricesPage({super.key});

  @override
  ConsumerState<DynamicMarketPricesPage> createState() =>
      _DynamicMarketPricesPageState();
}

class _DynamicMarketPricesPageState
    extends ConsumerState<DynamicMarketPricesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrices();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final isLoading = ref.read(isLoadingDynamicMarketPricesProvider);
    final hasMore = ref.read(hasMoreDynamicMarketPricesProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadPrices();
    }
  }

  Future<void> _loadPrices({bool refresh = false}) async {
    if (!mounted) return;

    if (refresh) {
      ref.read(currentDynamicMarketPricesPageProvider.notifier).state = 1;
      ref.read(hasMoreDynamicMarketPricesProvider.notifier).state = true;
      ref.read(isLoadingDynamicMarketPricesProvider.notifier).state = true;
      ref.read(dynamicMarketPricesErrorProvider.notifier).state = null;
    } else {
      final isLoading = ref.read(isLoadingDynamicMarketPricesProvider);
      if (isLoading) return;
      // Set loading state before making the API call
      ref.read(isLoadingDynamicMarketPricesProvider.notifier).state = true;
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(currentDynamicMarketPricesPageProvider);

      debugPrint('Loading dynamic market prices page: $currentPage');
      final response = await apiService.getDynamicMarketPrices(
        page: currentPage,
      );

      if (!mounted) return;

      debugPrint(
        'Dynamic market prices loaded: ${response.results.columns.length} columns, ${response.results.data.length} rows',
      );
      debugPrint('Columns: ${response.results.columns}');

      final existingData = ref.read(dynamicMarketPricesDataProvider);

      if (currentPage == 1 || existingData == null) {
        // First page or refresh
        ref.read(dynamicMarketPricesDataProvider.notifier).state =
            response.results;
      } else {
        // Append data for pagination
        final newData = DynamicMarketPricesData(
          columns: response.results.columns,
          data: [...existingData.data, ...response.results.data],
        );
        ref.read(dynamicMarketPricesDataProvider.notifier).state = newData;
      }

      ref.read(hasMoreDynamicMarketPricesProvider.notifier).state =
          response.next != null;
      ref.read(dynamicMarketPricesNextPageProvider.notifier).state =
          response.next;

      if (response.next != null) {
        ref.read(currentDynamicMarketPricesPageProvider.notifier).state =
            currentPage + 1;
      }

      ref.read(isLoadingDynamicMarketPricesProvider.notifier).state = false;
    } catch (e, stackTrace) {
      debugPrint('Error loading dynamic market prices: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ref.read(isLoadingDynamicMarketPricesProvider.notifier).state = false;
        ref.read(dynamicMarketPricesErrorProvider.notifier).state = e
            .toString();

        if (refresh || ref.read(currentDynamicMarketPricesPageProvider) == 1) {
          Get.snackbar('failed_to_load_market_prices'.tr(context));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingDynamicMarketPricesProvider);
    final error = ref.watch(dynamicMarketPricesErrorProvider);
    final data = ref.watch(dynamicMarketPricesDataProvider);
    final hasData =
        data != null && data.columns.isNotEmpty && data.data.isNotEmpty;

    debugPrint(
      'Build - isLoading: $isLoading, error: $error, hasData: $hasData',
    );
    if (data != null) {
      debugPrint(
        'Data - columns: ${data.columns.length}, rows: ${data.data.length}',
      );
    }

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'market_prices'.tr(context),
          style: Get.bodyLarge.px18.w600.copyWith(color: Colors.white),
        ),
        backgroundColor: Get.primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPrices(refresh: true),
        child: isLoading && data == null
            ? const Center(child: CircularProgressIndicator.adaptive())
            : error != null && data == null
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildErrorState(),
                ),
              )
            : !hasData
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EmptyStateWidget(
                    icon: Icons.table_chart_rounded,
                    title: 'no_market_prices'.tr(context),
                    subtitle: 'market_prices_empty_state_subtitle'.tr(context),
                  ),
                ),
              )
            : _buildTable(data),
      ),
    );
  }

  Widget _buildErrorState() {
    final error = ref.read(dynamicMarketPricesErrorProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48.st,
          ),
          16.verticalGap,
          AppText(
            'market_prices_error'.tr(context),
            style: Get.bodyMedium.px14.w600.copyWith(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
          8.verticalGap,
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32).rt,
              child: AppText(
                error,
                style: Get.bodySmall.px12.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          16.verticalGap,
          ElevatedButton(
            onPressed: () => _loadPrices(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12).rt,
              ),
            ),
            child: AppText(
              'retry'.tr(context),
              style: Get.bodyMedium.px14.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(DynamicMarketPricesData data) {
    final isLoadingMore = ref.watch(isLoadingDynamicMarketPricesProvider);
    final columns = data.columns;
    final rows = data.data;

    if (columns.isEmpty || rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32).rt,
          child: AppText(
            'no_data_available'.tr(context),
            style: Get.bodyMedium.px14.copyWith(color: Get.disabledColor),
          ),
        ),
      );
    }

    // Calculate minimum width for table (150 per column)
    final minTableWidth = columns.length * 150.0;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8).rt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal scrollable table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minTableWidth),
                child: Container(
                  decoration: BoxDecoration(
                    color: Get.cardColor,
                    borderRadius: BorderRadius.circular(12).rt,
                    border: Border.all(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Table(
                    defaultColumnWidth: const FixedColumnWidth(150),
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Get.disabledColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      verticalInside: BorderSide(
                        color: Get.disabledColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      top: BorderSide(
                        color: Get.disabledColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Get.disabledColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Get.disabledColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Get.disabledColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    children: [
                      // Header row
                      TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        children: columns.map((column) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ).rt,
                            child: AppText(
                              column,
                              style: Get.bodyMedium.px13.w700.copyWith(
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                      // Data rows
                      ...rows.map((row) {
                        // Ensure row has same number of cells as columns
                        final paddedRow = List<String>.from(row);
                        while (paddedRow.length < columns.length) {
                          paddedRow.add('');
                        }
                        return TableRow(
                          children: paddedRow.take(columns.length).map((cell) {
                            return Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ).rt,
                                child: AppText(
                                  cell,
                                  style: Get.bodySmall.px12.w500.copyWith(
                                    color: Get.disabledColor,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            // Loading indicator for pagination
            if (isLoadingMore)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16).rt,
                child: Center(
                  child: SizedBox(
                    height: 24.st,
                    width: 24.st,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
