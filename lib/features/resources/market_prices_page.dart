import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';

class MarketPricesPage extends ConsumerStatefulWidget {
  const MarketPricesPage({super.key});

  @override
  ConsumerState<MarketPricesPage> createState() => _MarketPricesPageState();
}

class _MarketPricesPageState extends ConsumerState<MarketPricesPage> {
  final List<MarketPrice> _prices = [];
  final Map<String, String> _categories = {};
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  final ValueNotifier<bool> _isInitialLoading = ValueNotifier(true);
  final ValueNotifier<bool> _isLoadingMore = ValueNotifier(false);
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';
  final ValueNotifier<String> _selectedCategory = ValueNotifier('all');

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _isInitialLoading.dispose();
    _isLoadingMore.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  Future<void> _loadPrices({bool refresh = false}) async {
    if (_isLoadingMore.value && !refresh) return;
    if (!_hasMore && !refresh && _currentPage > 1) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (_currentPage == 1) {
      _isInitialLoading.value = true;
    } else {
      _isLoadingMore.value = true;
    }

    try {
      final response = await ref.read(krishiApiServiceProvider).getMarketPrices(
            page: _currentPage,
            search: _searchQuery.isEmpty ? null : _searchQuery,
            category: _selectedCategory.value == 'all' ? null : _selectedCategory.value,
            ordering: '-updated_at',
          );
      if (!mounted) return;
      if (_currentPage == 1) {
        _prices
          ..clear()
          ..addAll(response.results);
      } else {
        _prices.addAll(response.results);
      }
      for (final price in response.results) {
        if (price.category.isNotEmpty) {
          _categories[price.category] = price.categoryDisplay;
        }
      }
      _hasMore = response.next != null;
      _currentPage += 1;
      _isInitialLoading.value = false;
      _isLoadingMore.value = false;
    } catch (e) {
      if (!mounted) return;
      _isInitialLoading.value = false;
      _isLoadingMore.value = false;
      Get.snackbar('failed_to_load_market_prices'.tr(context));
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = value.trim();
      _loadPrices(refresh: true);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _loadPrices(refresh: true);
  }

  void _selectCategory(String category) {
    if (_selectedCategory.value == category) return;
    _selectedCategory.value = category;
    _loadPrices(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          _buildHeader(context),
          _buildCategoryChips(context),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isInitialLoading,
              builder: (context, isInitialLoading, _) {
                return isInitialLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : _prices.isEmpty
                        ? _buildEmptyState(context)
                        : _buildPricesList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.wt, 20.ht, 16.wt, 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(bottom: const Radius.circular(28)).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'market_prices_overview'.tr(context),
            style: Get.bodyLarge.px14.w700.copyWith(color: Get.disabledColor),
          ),
          8.verticalGap,
          AppText(
            'market_prices_intro'.tr(context),
            maxLines: 4,
            style: Get.bodyMedium.px12.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          16.verticalGap,
          _buildSearchField(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'search_market_prices'.tr(context),
        prefixIcon: Icon(Icons.search_rounded, color: Get.disabledColor),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _clearSearch,
              )
            : null,
        filled: true,
        fillColor: Get.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16).rt,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final entries = [
      MapEntry('all', 'all_categories'.tr(context)),
      ..._categories.entries,
    ];

    return ValueListenableBuilder<String>(
      valueListenable: _selectedCategory,
      builder: (context, selectedCategory, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 12.ht),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: entries.map((entry) {
                final isSelected = entry.key == selectedCategory;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: GestureDetector(
                onTap: () => _selectCategory(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.wt, vertical: 8.ht),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.primaryColor
                        : Get.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20).rt,
                    border: Border.all(
                      color: isSelected
                          ? Get.primaryColor
                          : Get.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 14.st,
                        color: isSelected ? Colors.white : Get.primaryColor,
                      ),
                      6.horizontalGap,
                      AppText(
                        entry.value,
                        style: Get.bodySmall.px12.w600.copyWith(
                          color: isSelected ? Colors.white : Get.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPricesList() {
    return RefreshIndicator(
      onRefresh: () => _loadPrices(refresh: true),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.wt, 16.ht, 16.wt, 24.ht),
        itemCount: _prices.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _prices.length) {
            return _buildLoadMoreButton();
          }
          return _buildPriceCard(_prices[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!_hasMore) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingMore,
      builder: (context, isLoadingMore, _) {
        return Padding(
          padding: EdgeInsets.only(top: 8.ht),
          child: ElevatedButton(
            onPressed: isLoadingMore ? null : () => _loadPrices(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16).rt,
              ),
            ),
            child: isLoadingMore
                ? SizedBox(
                    height: 18.st,
                    width: 18.st,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : AppText(
                    'load_more'.tr(context),
                    style: Get.bodyMedium.copyWith(color: Colors.white),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPriceCard(MarketPrice price) {
    final updatedText = DateFormat('MMM dd, yyyy').format(price.updatedAt);
    final formattedPrice = _formatPrice(price.price);

    return Container(
      margin: EdgeInsets.only(bottom: 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.wt, vertical: 6.ht),
                  decoration: BoxDecoration(
                    color: Get.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20).rt,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_rounded,
                          size: 14.st, color: Get.primaryColor),
                      6.horizontalGap,
                      AppText(
                        price.categoryDisplay.isNotEmpty
                            ? price.categoryDisplay
                            : 'market_category_other'.tr(context),
                        style: Get.bodySmall.copyWith(
                          color: Get.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.update_rounded,
                  size: 14.st,
                  color: Get.disabledColor.withValues(alpha: 0.7),
                ),
                4.horizontalGap,
                AppText(
                  '${'updated_on'.tr(context)} $updatedText',
                  style: Get.bodySmall.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            12.verticalGap,
            AppText(
              price.name,
              style: Get.bodyLarge.px16.w700.copyWith(
                color:
                    Get.bodyLarge.color ?? (Get.isDark ? Colors.white : Colors.black87),
              ),
            ),
            12.verticalGap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  formattedPrice,
                  style: Get.bodyLarge.px26.w800.copyWith(
                    color: Get.primaryColor,
                  ),
                ),
                6.horizontalGap,
                AppText(
                  '/${price.unit}',
                  style: Get.bodyMedium.px14.w600.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    return price.toStringAsFixed(2);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.wt),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.rt),
              decoration: BoxDecoration(
                color: Get.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 48.st,
                color: Get.primaryColor,
              ),
            ),
            20.verticalGap,
            AppText(
              'no_market_prices'.tr(context),
              style: Get.bodyLarge.px18.w700,
              textAlign: TextAlign.center,
            ),
            8.verticalGap,
            AppText(
              'market_prices_empty_state_subtitle'.tr(context),
              style: Get.bodyMedium.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

