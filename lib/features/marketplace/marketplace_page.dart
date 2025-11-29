import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/services/cache_service.dart';
import 'package:krishi/features/cart/cart_page.dart';
import 'package:krishi/features/marketplace/add_edit_product_page.dart';
import 'package:krishi/features/marketplace/product_detail_page.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/dialog_box.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/components/form_field.dart';
import 'package:krishi/models/category.dart';
import 'package:krishi/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  bool isBuyTab = true;
  final TextEditingController _searchController = TextEditingController();

  List<Product> buyProducts = [];
  List<Product> userListings = [];
  List<Category> categories = [];
  bool isLoadingBuyProducts = true;
  bool isLoadingUserListings = true;
  bool isLoadingCategoryFilters = true;
  String? buyProductsError;
  String? userListingsError;
  final ScrollController _buyScrollController = ScrollController();
  final ScrollController _sellScrollController = ScrollController();
  int _buyCurrentPage = 1;
  bool _buyHasMore = true;
  bool _isLoadingMoreBuyProducts = false;
  int _sellCurrentPage = 1;
  bool _sellHasMore = true;
  bool _isLoadingMoreUserListings = false;
  int? _currentUserId;
  String? _currentSellerKrId;
  int? _selectedCategoryId;
  String _sellStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _buyScrollController.addListener(_onBuyScroll);
    _sellScrollController.addListener(_onSellScroll);
    _loadBuyProducts();
    _loadUserListings();
    _loadMarketplaceCategories();
  }

  Future<void> _loadBuyProducts() async {
    setState(() {
      isLoadingBuyProducts = true;
      buyProductsError = null;
      _buyCurrentPage = 1;
      _buyHasMore = true;
      buyProducts = [];
    });

    try {
      final cacheService = ref.read(cacheServiceProvider);
      final apiService = ref.read(krishiApiServiceProvider);
      final shouldUseCache =
          _searchController.text.isEmpty && _selectedCategoryId == null;

      // Only use cache if there's no search query or category filter
      if (shouldUseCache) {
        final cachedProducts = await cacheService.getBuyProductsCache();
        if (cachedProducts != null) {
          final products = cachedProducts
              .map((json) => Product.fromJson(json))
              .where((product) => product.isAvailable)
              .toList();
          if (mounted) {
            setState(() {
              buyProducts = products;
              isLoadingBuyProducts = false;
            });
          }
        }
      }

      // Fetch fresh data from API
      final response = await apiService.getProducts(
        page: _buyCurrentPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        category: _selectedCategoryId,
      );
      final filteredResults = response.results
          .where((product) => product.isAvailable)
          .toList();

      // Save to cache only if no search query
      if (shouldUseCache) {
        await cacheService.saveBuyProductsCache(
          filteredResults.map((p) => p.toJson()).toList(),
        );
      }

      if (mounted) {
        setState(() {
          buyProducts = filteredResults;
          isLoadingBuyProducts = false;
          _buyHasMore = response.next != null;
          _buyCurrentPage = _buyCurrentPage + 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          buyProductsError = e.toString();
          isLoadingBuyProducts = false;
        });
      }
    }
  }

  Future<void> _loadMarketplaceCategories() async {
    setState(() {
      isLoadingCategoryFilters = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final fetchedCategories = await apiService.getCategories();
      if (mounted) {
        setState(() {
          categories = fetchedCategories;
          isLoadingCategoryFilters = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingCategoryFilters = false;
        });
      }
    }
  }

  Future<void> _loadMoreBuyProducts() async {
    if (_isLoadingMoreBuyProducts || !_buyHasMore) return;
    setState(() {
      _isLoadingMoreBuyProducts = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getProducts(
        page: _buyCurrentPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        category: _selectedCategoryId,
      );
      final filteredResults = response.results
          .where((product) => product.isAvailable)
          .toList();
      if (mounted) {
        setState(() {
          buyProducts = [...buyProducts, ...filteredResults];
          _buyHasMore = response.next != null;
          _buyCurrentPage = _buyCurrentPage + 1;
          _isLoadingMoreBuyProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMoreBuyProducts = false;
        });
        Get.snackbar('problem_fetching_data'.tr(context), color: Colors.red);
      }
    }
  }

  Future<void> _loadUserListings() async {
    setState(() {
      isLoadingUserListings = true;
      userListingsError = null;
      _sellCurrentPage = 1;
      _sellHasMore = true;
      userListings = [];
    });

    try {
      final cacheService = ref.read(cacheServiceProvider);
      final apiService = ref.read(krishiApiServiceProvider);
      final currentUser = await apiService.getCurrentUser();
      _currentUserId ??= currentUser.id;
      _currentSellerKrId ??=
          currentUser.profile?.krUserId ?? currentUser.id.toString();

      // Try to load from cache first
      final cachedProducts = await cacheService.getSellProductsCache();
      if (cachedProducts != null) {
        final products = cachedProducts
            .map((json) => Product.fromJson(json))
            .toList();
        if (mounted) {
          setState(() {
            userListings = products;
            isLoadingUserListings = false;
          });
        }
      }

      // Fetch fresh data from API
      final response = await apiService.getProducts(
        page: _sellCurrentPage,
        sellerId: _currentSellerKrId ?? _currentUserId?.toString(),
        approvalStatus: _sellStatusFilter == 'all' ? null : _sellStatusFilter,
      );

      // Save to cache
      await cacheService.saveSellProductsCache(
        response.results.map((p) => p.toJson()).toList(),
      );

      if (mounted) {
        setState(() {
          userListings = response.results;
          isLoadingUserListings = false;
          _sellHasMore = response.next != null;
          _sellCurrentPage = _sellCurrentPage + 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userListingsError = e.toString();
          isLoadingUserListings = false;
        });
      }
    }
  }

  Future<void> _loadMoreUserListings() async {
    if (_isLoadingMoreUserListings || !_sellHasMore) return;
    if (_currentSellerKrId == null && _currentUserId == null) {
      await _loadUserListings();
      return;
    }

    setState(() {
      _isLoadingMoreUserListings = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getProducts(
        page: _sellCurrentPage,
        sellerId: _currentSellerKrId ?? _currentUserId?.toString(),
        approvalStatus: _sellStatusFilter == 'all' ? null : _sellStatusFilter,
      );
      if (mounted) {
        setState(() {
          userListings = [...userListings, ...response.results];
          _sellHasMore = response.next != null;
          _sellCurrentPage = _sellCurrentPage + 1;
          _isLoadingMoreUserListings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMoreUserListings = false;
        });
        Get.snackbar('problem_fetching_data'.tr(context), color: Colors.red);
      }
    }
  }

  void _onBuyScroll() {
    if (!_buyScrollController.hasClients ||
        _isLoadingMoreBuyProducts ||
        !_buyHasMore) {
      return;
    }
    final threshold = _buyScrollController.position.maxScrollExtent - 200;
    if (_buyScrollController.position.pixels >= threshold) {
      _loadMoreBuyProducts();
    }
  }

  void _onSellScroll() {
    if (!_sellScrollController.hasClients ||
        _isLoadingMoreUserListings ||
        !_sellHasMore) {
      return;
    }
    final threshold = _sellScrollController.position.maxScrollExtent - 200;
    if (_sellScrollController.position.pixels >= threshold) {
      _loadMoreUserListings();
    }
  }

  void _onCategorySelected(int? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadBuyProducts();
  }

  void _onSellStatusChanged(String status) {
    if (_sellStatusFilter == status) return;
    setState(() {
      _sellStatusFilter = status;
    });
    _loadUserListings();
  }

  @override
  void dispose() {
    _buyScrollController.removeListener(_onBuyScroll);
    _sellScrollController.removeListener(_onSellScroll);
    _buyScrollController.dispose();
    _sellScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = ref.watch(languageProvider);
    final isNepali = langProvider.isNepali;
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Selector
            _buildTabSelector(),
            8.verticalGap,
            // Content
            Expanded(
              child: isBuyTab
                  ? _buildBuyContent(isNepali)
                  : _buildSellContent(isNepali),
            ),
          ],
        ),
      ),
      floatingActionButton: !isBuyTab
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.to(AddEditProductPage());
                if (result == true) {
                  _loadUserListings();
                }
              },
              backgroundColor: AppColors.primary,
              icon: Icon(Icons.add, color: AppColors.white, size: 20.st),
              label: AppText(
                'add_new_product'.tr(context),
                style: Get.bodyMedium.px14.w600.copyWith(
                  color: AppColors.white,
                ),
              ),
            )
          : null,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Get.scaffoldBackgroundColor,
      elevation: 0,

      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: Get.disabledColor),
          onPressed: () {
            Get.to(CartPage());
          },
        ),
        8.horizontalGap,
      ],
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6).rt,
      child: Container(
        padding: const EdgeInsets.all(6).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          border: Border.all(
            color: Get.disabledColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isBuyTab = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(vertical: 10).rt,
                  decoration: BoxDecoration(
                    color: isBuyTab ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20).rt,
                    boxShadow: isBuyTab
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AppText(
                      'buy'.tr(context),
                      style: Get.bodyMedium.px12.w700.copyWith(
                        color: isBuyTab
                            ? AppColors.white
                            : Get.disabledColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isBuyTab = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(vertical: 10).rt,
                  decoration: BoxDecoration(
                    color: !isBuyTab ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20).rt,
                    boxShadow: !isBuyTab
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AppText(
                      'sell'.tr(context),
                      style: Get.bodyMedium.px12.w700.copyWith(
                        color: !isBuyTab
                            ? AppColors.white
                            : Get.disabledColor.withValues(alpha: 0.6),
                      ),
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

  Widget _buildBuyContent(bool isNepali) {
    return RefreshIndicator(
      onRefresh: _loadBuyProducts,
      child: SingleChildScrollView(
        controller: _buyScrollController,
        physics: Get.scrollPhysics,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7).rt,
          child: Column(
            children: [
              AppTextFormField(
                controller: _searchController,
                isSearchField: true,
                hintText: 'search_products'.tr(context),
                hintTextStyle: Get.bodyMedium.px14.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.5),
                ),
                fillColor: Get.cardColor,
                radius: 20,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _loadBuyProducts(),
                onClear: () {
                  setState(() {});
                  _loadBuyProducts();
                },
              ),

              3.verticalGap,
              _buildCategoryFilters(isNepali),
              3.verticalGap,
              // Products Grid
              if (isLoadingBuyProducts)
                _buildBuySkeleton()
              else if (buyProductsError != null)
                ErrorState(
                  subtitle: 'error_loading_products_subtitle'.tr(context),
                  onRetry: _loadBuyProducts,
                )
              else if (buyProducts.isEmpty)
                EmptyState(
                  title: 'no_products_available'.tr(context),
                  subtitle: 'no_products_subtitle'.tr(context),
                  icon: Icons.shopping_bag_outlined,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6.rt,
                    mainAxisSpacing: 6.rt,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: buyProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(buyProducts[index], isNepali);
                  },
                ),
              if (_isLoadingMoreBuyProducts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16).rt,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              20.verticalGap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellContent(bool isNepali) {
    return RefreshIndicator(
      onRefresh: _loadUserListings,
      child: SingleChildScrollView(
        controller: _sellScrollController,
        physics: Get.scrollPhysics,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Your Listings
              _buildSellStatusFilters(),
              9.verticalGap,
              // Listings
              if (isLoadingUserListings)
                _buildSellSkeleton()
              else if (userListingsError != null)
                ErrorState(
                  subtitle: 'error_loading_listings_subtitle'.tr(context),
                  onRetry: _loadUserListings,
                )
              else if (userListings.isEmpty)
                EmptyState(
                  title: 'no_listings_yet'.tr(context),
                  subtitle: 'no_listings_subtitle'.tr(context),
                  icon: Icons.inventory_2_outlined,
                )
              else
                ...userListings.map((listing) {
                  return _buildListingCard(listing, isNepali);
                }),
              if (_isLoadingMoreUserListings)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16).rt,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              20.verticalGap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuySkeleton() {
    return Skeletonizer(
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.rt,
              mainAxisSpacing: 12.rt,
              childAspectRatio: 0.75,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: Get.cardColor,
                borderRadius: BorderRadius.circular(20).rt,
              ),
              child: Column(
                children: [
                  Container(
                    height: 112.ht,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.rt),
                        topRight: Radius.circular(16.rt),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12).rt,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14.rt,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Get.disabledColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8).rt,
                          ),
                        ),
                        8.verticalGap,
                        Container(
                          height: 12.rt,
                          width: 80.rt,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8).rt,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellSkeleton() {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18).rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              borderRadius: BorderRadius.circular(12).rt,
            ),
          ),
          20.verticalGap,
          Container(
            height: 20.rt,
            width: 140.rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              borderRadius: BorderRadius.circular(8).rt,
            ),
          ),
          16.verticalGap,
          Column(
            children: List.generate(
              3,
              (_) => Container(
                margin: EdgeInsets.only(bottom: 12.rt),
                padding: const EdgeInsets.all(14).rt,
                decoration: BoxDecoration(
                  color: Get.cardColor,
                  borderRadius: BorderRadius.circular(16).rt,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70.rt,
                      height: 70.rt,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12).rt,
                      ),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14.rt,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Get.disabledColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8).rt,
                            ),
                          ),
                          8.verticalGap,
                          Container(
                            height: 12.rt,
                            width: 100.rt,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8).rt,
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.horizontalGap,
                    Container(
                      width: 32.rt,
                      height: 32.rt,
                      decoration: BoxDecoration(
                        color: Get.disabledColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8).rt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellStatusFilters() {
    final filters = [
      {'key': 'all', 'label': 'all_statuses'.tr(context)},
      {'key': 'approved', 'label': 'approved'.tr(context)},
      {'key': 'pending', 'label': 'pending'.tr(context)},
      {'key': 'rejected', 'label': 'rejected'.tr(context)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _sellStatusFilter == filter['key'];
          return Padding(
            padding: EdgeInsets.only(right: 8.rt),
            child: GestureDetector(
              onTap: () => _onSellStatusChanged(filter['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: 14.rt,
                  vertical: 8.rt,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.85),
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : Get.disabledColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24).rt,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Get.disabledColor.withValues(alpha: 0.2),
                  ),
                ),
                child: AppText(
                  filter['label']!,
                  style: Get.bodySmall.w600.copyWith(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : Get.disabledColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilters(bool isNepali) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(30).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
      ),
      child: isLoadingCategoryFilters
          ? _buildCategoryFilterSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _buildCategoryChips(isNepali)),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildCategoryChips(bool isNepali) {
    final chips = <Widget>[
      _buildCategoryPill(
        label: 'all_categories'.tr(context),
        isSelected: _selectedCategoryId == null,
        icon: Icons.all_inclusive,
        onTap: () => _onCategorySelected(null),
      ),
      ...categories.map(
        (category) => _buildCategoryPill(
          label: category.localizedName(isNepali),
          isSelected: _selectedCategoryId == category.id,
          onTap: () => _onCategorySelected(category.id),
        ),
      ),
    ];

    return chips
        .map(
          (chip) => Padding(
            padding: EdgeInsets.only(right: 6.rt),
            child: chip,
          ),
        )
        .toList();
  }

  Widget _buildCategoryFilterSkeleton() {
    return Skeletonizer(
      child: Row(
        children: List.generate(
          3,
          (index) => Container(
            margin: EdgeInsets.only(right: 10.rt),
            padding: EdgeInsets.symmetric(horizontal: 20.rt, vertical: 10.rt),
            decoration: BoxDecoration(
              color: Get.disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24).rt,
            ),
            child: const SizedBox(width: 60, height: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 8.rt, vertical: 6.rt),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                )
              : null,
          color: isSelected ? null : Get.disabledColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24).rt,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Get.disabledColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14.st,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              6.horizontalGap,
            ],
            AppText(
              label,
              style: Get.bodySmall.w600.copyWith(
                fontSize: 12.sp,
                color: isSelected ? Colors.white : Get.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isNepali) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image - Tappable for navigation
          GestureDetector(
            onTap: () {
              Get.to(ProductDetailPage(product: product));
            },
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 112.ht,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.rt),
                      topRight: Radius.circular(16.rt),
                    ),
                  ),
                  child: product.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.rt),
                            topRight: Radius.circular(16.rt),
                          ),
                          child: Image.network(
                            Get.imageUrl(product.image),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  size: 40.st,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.primary.withValues(alpha: 0.3),
                            size: 42.st,
                          ),
                        ),
                ),
                // Free Delivery Icon at top left
                if (product.freeDelivery == true)
                  Positioned(
                    top: 8.rt,
                    left: 8.rt,
                    child: Container(
                      padding: EdgeInsets.all(4.rt),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6).rt,
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        size: 14.st,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                // Recommend Icon at top right
                if (product.recommend == true)
                  Positioned(
                    top: 8.rt,
                    right: 8.rt,
                    child: Container(
                      padding: EdgeInsets.all(4.rt),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6).rt,
                      ),
                      child: Icon(
                        Icons.star,
                        size: 14.st,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12).rt,
            child: GestureDetector(
              onTap: () => Get.to(ProductDetailPage(product: product)),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  AppText(
                    product.name,
                    style: Get.bodyLarge.px16.w800.copyWith(
                      color: Get.disabledColor,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalGap,
                  // Price and Rating
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          'Rs. ${product.price}/${product.localizedUnitName(isNepali)}',
                          style: Get.bodyMedium.px12.w700.copyWith(
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.rating != null && product.rating!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14.st, color: Colors.amber),
                            4.horizontalGap,
                            AppText(
                              product.rating!,
                              style: Get.bodySmall.px11.w600.copyWith(
                                color: Get.disabledColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    AppDialog.showConfirmation(
      title: 'delete_product'.tr(Get.context),
      content: 'delete_confirmation'.tr(Get.context),
      confirmText: 'delete'.tr(Get.context),
      confirmColor: Colors.red,
      onConfirm: () async {
        try {
          final apiService = ref.read(krishiApiServiceProvider);
          await apiService.deleteProduct(product.id);
          _loadUserListings();
          Get.snackbar('product_deleted'.tr(Get.context), color: Colors.green);
        } catch (e) {
          Get.snackbar(
            'error_deleting_product'.tr(Get.context),
            color: Colors.red,
          );
        }
      },
    );
  }

  Widget _buildListingCard(Product listing, bool isNepali) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.rt),
      padding: const EdgeInsets.all(6).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image with Status Chip
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70.rt,
                height: 70.rt,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12).rt,
                ),
                child: listing.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12).rt,
                        child: Image.network(
                          Get.imageUrl(listing.image),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.primary.withValues(alpha: 0.3),
                                size: 32.st,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.primary.withValues(alpha: 0.3),
                          size: 32.st,
                        ),
                      ),
              ),
              4.verticalGap,
              _buildStatusChip(listing.approvalStatus),
            ],
          ),
          16.horizontalGap,
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  listing.name,
                  style: Get.bodyMedium.px14.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),

                4.verticalGap,
                AppText(
                  maxLines: 2,
                  'Rs. ${listing.price}/${listing.localizedUnitName(isNepali)}',
                  style: Get.bodyMedium.px10.w700.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Get.to(
                    AddEditProductPage(product: listing),
                  );
                  if (result == true) {
                    _loadUserListings();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8).rt,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8).rt,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                    size: 18.st,
                  ),
                ),
              ),
              8.horizontalGap,
              GestureDetector(
                onTap: () {
                  _showDeleteConfirmation(listing);
                },
                child: Container(
                  padding: const EdgeInsets.all(8).rt,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8).rt,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18.st,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? approvalStatus) {
    if (approvalStatus == null) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;
    String label;

    switch (approvalStatus.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade700;
        label = 'approved'.tr(context);
        break;
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange.shade700;
        label = 'pending'.tr(context);
        break;
      case 'rejected':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.shade700;
        label = 'rejected'.tr(context);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.rt, vertical: 2.rt),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6).rt,
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: AppText(
        label,
        style: Get.bodySmall.px08.w600.copyWith(color: textColor),
      ),
    );
  }
}
