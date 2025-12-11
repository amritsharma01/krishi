import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/market_prices_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/market_prices_widgets.dart';
import 'package:krishi/features/resources/widgets/search_field.dart';

class MarketPricesPage extends ConsumerStatefulWidget {
  const MarketPricesPage({super.key});

  @override
  ConsumerState<MarketPricesPage> createState() => _MarketPricesPageState();
}

class _MarketPricesPageState extends ConsumerState<MarketPricesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

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
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final isLoadingMore = ref.read(isLoadingMoreMarketPricesProvider);
    final hasMore = ref.read(hasMoreMarketPricesProvider);
    final isLoading = ref.read(isLoadingMarketPricesProvider);

    if (isLoadingMore || !hasMore || isLoading) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadPrices();
    }
  }

  Future<void> _loadPrices({bool refresh = false}) async {
    if (!mounted) return;

    if (refresh) {
      ref.read(currentMarketPricesPageProvider.notifier).state = 1;
      ref.read(hasMoreMarketPricesProvider.notifier).state = true;
      ref.read(isLoadingMarketPricesProvider.notifier).state = true;
      ref.read(isLoadingMoreMarketPricesProvider.notifier).state = false;
    } else {
      final currentPage = ref.read(currentMarketPricesPageProvider);
      if (currentPage == 1) {
        // First load
        ref.read(isLoadingMarketPricesProvider.notifier).state = true;
      } else {
        // Loading more
        final isLoadingMore = ref.read(isLoadingMoreMarketPricesProvider);
        if (isLoadingMore) return;
        ref.read(isLoadingMoreMarketPricesProvider.notifier).state = true;
      }
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(currentMarketPricesPageProvider);
      final searchQuery = ref.read(marketPricesSearchQueryProvider);
      final selectedCategory = ref.read(selectedMarketPriceCategoryProvider);

      debugPrint('Loading market prices page: $currentPage');
      final response = await apiService.getMarketPrices(
        page: currentPage,
        search: searchQuery.isEmpty ? null : searchQuery,
        category: selectedCategory == 'all' ? null : selectedCategory,
        ordering: '-updated_at',
      );

      if (!mounted) return;

      final prices = ref.read(marketPricesListProvider);
      if (currentPage == 1) {
        ref.read(marketPricesListProvider.notifier).state = response.results;
      } else {
        ref.read(marketPricesListProvider.notifier).state = [
          ...prices,
          ...response.results,
        ];
      }

      // Update categories
      final categories = ref.read(marketPricesCategoriesProvider);
      final updatedCategories = Map<String, String>.from(categories);
      for (final price in response.results) {
        if (price.category.isNotEmpty) {
          updatedCategories[price.category] = price.categoryDisplay;
        }
      }
      ref.read(marketPricesCategoriesProvider.notifier).state = updatedCategories;

      ref.read(hasMoreMarketPricesProvider.notifier).state = response.next != null;
      ref.read(currentMarketPricesPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMarketPricesProvider.notifier).state = false;
      ref.read(isLoadingMoreMarketPricesProvider.notifier).state = false;
    } catch (e) {
      debugPrint('Error loading market prices: $e');
      if (mounted) {
        ref.read(isLoadingMarketPricesProvider.notifier).state = false;
        ref.read(isLoadingMoreMarketPricesProvider.notifier).state = false;

        // Only show error if it's the initial load or a refresh
        final currentPage = ref.read(currentMarketPricesPageProvider);
        if (currentPage == 1 || refresh) {
          Get.snackbar('failed_to_load_market_prices'.tr(context));
        }
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final trimmedValue = value.trim();
      ref.read(marketPricesSearchQueryProvider.notifier).state = trimmedValue;
      _loadPrices(refresh: true);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(marketPricesSearchQueryProvider.notifier).state = '';
    _loadPrices(refresh: true);
  }

  void _selectCategory(String category) {
    final selectedCategory = ref.read(selectedMarketPriceCategoryProvider);
    if (selectedCategory == category) return;
    ref.read(selectedMarketPriceCategoryProvider.notifier).state = category;
    _loadPrices(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingMarketPricesProvider);
    final prices = ref.watch(marketPricesListProvider);
    final hasPrices = prices.isNotEmpty;

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
          MarketPricesHeader(
            searchField: SearchField(
              controller: _searchController,
              hintText: 'search_market_prices'.tr(context),
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
              showClearButton: ref.watch(marketPricesSearchQueryProvider).isNotEmpty,
            ),
          ),
          MarketPricesCategoryChips(
            onCategorySelected: (category) => _selectCategory(category),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : hasPrices
                    ? _buildPricesList()
                    : EmptyStateWidget(
                        icon: Icons.bar_chart_rounded,
                        title: 'no_market_prices'.tr(context),
                        subtitle: 'market_prices_empty_state_subtitle'.tr(context),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricesList() {
    final prices = ref.watch(marketPricesListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreMarketPricesProvider);

    return RefreshIndicator(
      onRefresh: () => _loadPrices(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16.wt, 16.ht, 16.wt, 24.ht),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: prices.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == prices.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.ht),
              child: Center(
                child: SizedBox(
                  height: 24.st,
                  width: 24.st,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Get.primaryColor),
                  ),
                ),
              ),
            );
          }
          return MarketPriceCard(price: prices[index]);
        },
      ),
    );
  }
}

