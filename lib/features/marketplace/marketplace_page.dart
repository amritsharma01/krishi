import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/cart/cart_page.dart';
import 'package:krishi/features/marketplace/add_edit_product_page.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/dialog_box.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/form_field.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';
import 'package:krishi/features/marketplace/widgets/marketplace_widgets.dart';
import 'package:krishi/features/marketplace/widgets/marketplace_filter_widgets.dart';
import 'package:krishi/features/marketplace/widgets/marketplace_skeleton_widgets.dart';
import 'package:krishi/models/product.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _buyScrollController = ScrollController();
  final ScrollController _sellScrollController = ScrollController();
  int? _currentUserId;
  String? _currentSellerKrId;
  bool _hasLoadedBuyProducts = false;
  bool _hasLoadedSellProducts = false;

  @override
  void initState() {
    super.initState();
    _buyScrollController.addListener(_onBuyScroll);
    _sellScrollController.addListener(_onSellScroll);
    // Initial load based on current tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isBuyTab = ref.read(isMarketplaceBuyTabProvider);
      if (isBuyTab) {
        _loadBuyProducts();
      } else {
        _loadUserListings();
      }
    });
  }

  Future<void> _loadBuyProducts({bool force = false}) async {
    if (!force && _hasLoadedBuyProducts && ref.read(buyProductsProvider).isNotEmpty) {
      return; // Already loaded
    }

    ref.read(isLoadingBuyProductsProvider.notifier).state = true;
    ref.read(buyCurrentPageProvider.notifier).state = 1;
    ref.read(buyHasMoreProvider.notifier).state = true;
    ref.read(buyProductsProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final selectedCategoryId = ref.read(selectedCategoryIdProvider);

      final response = await apiService.getProducts(
        page: 1,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        category: selectedCategoryId,
      );
      final filteredResults = response.results
          .where((product) => product.isAvailable)
          .toList();

      if (mounted) {
        ref.read(buyProductsProvider.notifier).state = filteredResults;
        ref.read(isLoadingBuyProductsProvider.notifier).state = false;
        ref.read(buyHasMoreProvider.notifier).state = response.next != null;
        ref.read(buyCurrentPageProvider.notifier).state = 2;
        _hasLoadedBuyProducts = true;
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingBuyProductsProvider.notifier).state = false;
      }
    }
  }

  Future<void> _loadMoreBuyProducts() async {
    final isLoading = ref.read(isLoadingMoreBuyProductsProvider);
    final hasMore = ref.read(buyHasMoreProvider);
    
    if (isLoading || !hasMore) return;
    
    ref.read(isLoadingMoreBuyProductsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(buyCurrentPageProvider);
      final selectedCategoryId = ref.read(selectedCategoryIdProvider);
      
      final response = await apiService.getProducts(
        page: currentPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        category: selectedCategoryId,
      );
      final filteredResults = response.results
          .where((product) => product.isAvailable)
          .toList();
      
      if (mounted) {
        final currentProducts = ref.read(buyProductsProvider);
        ref.read(buyProductsProvider.notifier).state = [
          ...currentProducts,
          ...filteredResults
        ];
        ref.read(buyHasMoreProvider.notifier).state = response.next != null;
        ref.read(buyCurrentPageProvider.notifier).state = currentPage + 1;
        ref.read(isLoadingMoreBuyProductsProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingMoreBuyProductsProvider.notifier).state = false;
        Get.snackbar('problem_fetching_data'.tr(context), color: Colors.red);
      }
    }
  }

  Future<void> _loadUserListings({bool force = false}) async {
    if (!force && _hasLoadedSellProducts && ref.read(userListingsProvider).isNotEmpty) {
      return; // Already loaded
    }

    // Reset flag when forcing refresh
    if (force) {
      _hasLoadedSellProducts = false;
    }

    ref.read(isLoadingUserListingsProvider.notifier).state = true;
    ref.read(sellCurrentPageProvider.notifier).state = 1;
    ref.read(sellHasMoreProvider.notifier).state = true;
    ref.read(userListingsProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentUser = await apiService.getCurrentUser();
      _currentUserId ??= currentUser.id;
      _currentSellerKrId ??= currentUser.profile?.krUserId ?? currentUser.id.toString();

      final sellStatusFilter = ref.read(sellStatusFilterProvider);
      final response = await apiService.getProducts(
        page: 1,
        sellerId: _currentSellerKrId ?? _currentUserId?.toString(),
        approvalStatus: sellStatusFilter == 'all' ? null : sellStatusFilter,
      );

      if (mounted) {
        ref.read(userListingsProvider.notifier).state = response.results;
        ref.read(isLoadingUserListingsProvider.notifier).state = false;
        ref.read(sellHasMoreProvider.notifier).state = response.next != null;
        ref.read(sellCurrentPageProvider.notifier).state = 2;
        _hasLoadedSellProducts = true;
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingUserListingsProvider.notifier).state = false;
      }
    }
  }

  Future<void> _loadMoreUserListings() async {
    final isLoading = ref.read(isLoadingMoreUserListingsProvider);
    final hasMore = ref.read(sellHasMoreProvider);
    
    if (isLoading || !hasMore) return;
    if (_currentSellerKrId == null && _currentUserId == null) {
      await _loadUserListings();
      return;
    }

    ref.read(isLoadingMoreUserListingsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(sellCurrentPageProvider);
      final sellStatusFilter = ref.read(sellStatusFilterProvider);
      
      final response = await apiService.getProducts(
        page: currentPage,
        sellerId: _currentSellerKrId ?? _currentUserId?.toString(),
        approvalStatus: sellStatusFilter == 'all' ? null : sellStatusFilter,
      );
      
      if (mounted) {
        final currentListings = ref.read(userListingsProvider);
        ref.read(userListingsProvider.notifier).state = [
          ...currentListings,
          ...response.results
        ];
        ref.read(sellHasMoreProvider.notifier).state = response.next != null;
        ref.read(sellCurrentPageProvider.notifier).state = currentPage + 1;
        ref.read(isLoadingMoreUserListingsProvider.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ref.read(isLoadingMoreUserListingsProvider.notifier).state = false;
        Get.snackbar('problem_fetching_data'.tr(context), color: Colors.red);
      }
    }
  }

  void _onBuyScroll() {
    if (!_buyScrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreBuyProductsProvider);
    final hasMore = ref.read(buyHasMoreProvider);
    
    if (isLoading || !hasMore) return;
    
    final threshold = _buyScrollController.position.maxScrollExtent - 200;
    if (_buyScrollController.position.pixels >= threshold) {
      _loadMoreBuyProducts();
    }
  }

  void _onSellScroll() {
    if (!_sellScrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreUserListingsProvider);
    final hasMore = ref.read(sellHasMoreProvider);
    
    if (isLoading || !hasMore) return;
    
    final threshold = _sellScrollController.position.maxScrollExtent - 200;
    if (_sellScrollController.position.pixels >= threshold) {
      _loadMoreUserListings();
    }
  }

  void _onCategorySelected(int? categoryId) {
    final currentCategoryId = ref.read(selectedCategoryIdProvider);
    if (currentCategoryId == categoryId) return;
    
    ref.read(selectedCategoryIdProvider.notifier).state = categoryId;
    _hasLoadedBuyProducts = false; // Force reload
    _loadBuyProducts(force: true);
  }

  void _onSellStatusChanged(String status) {
    final currentStatus = ref.read(sellStatusFilterProvider);
    if (currentStatus == status) return;
    
    ref.read(sellStatusFilterProvider.notifier).state = status;
    _hasLoadedSellProducts = false; // Force reload
    _loadUserListings(force: true);
  }

  void _onTabChanged(bool isBuyTab) {
    if (isBuyTab) {
      _loadBuyProducts();
    } else {
      _loadUserListings();
    }
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
    final isBuyTab = ref.watch(isMarketplaceBuyTabProvider);
    
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTabSelector(),
            8.verticalGap,
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
                style: Get.bodyMedium.px14.w600.copyWith(color: AppColors.white),
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
    final isBuyTab = ref.watch(isMarketplaceBuyTabProvider);
    
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
                onTap: () {
                  if (isBuyTab) return;
                  ref.read(isMarketplaceBuyTabProvider.notifier).state = true;
                  _onTabChanged(true);
                },
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
                onTap: () {
                  if (!isBuyTab) return;
                  ref.read(isMarketplaceBuyTabProvider.notifier).state = false;
                  _onTabChanged(false);
                },
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
    final isLoading = ref.watch(isLoadingBuyProductsProvider);
    final products = ref.watch(buyProductsProvider);
    final isLoadingMore = ref.watch(isLoadingMoreBuyProductsProvider);
    
    return RefreshIndicator(
      onRefresh: () => _loadBuyProducts(force: true),
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
                onSubmitted: (_) => _loadBuyProducts(),
                onClear: _loadBuyProducts,
              ),
              3.verticalGap,
              CategoryFiltersSection(
                isNepali: isNepali,
                onCategorySelected: _onCategorySelected,
              ),
              3.verticalGap,
              if (isLoading)
                const BuyProductsSkeleton()
              else if (products.isEmpty)
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
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index], isNepali: isNepali);
                  },
                ),
              if (isLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16).rt,
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
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
    final isLoading = ref.watch(isLoadingUserListingsProvider);
    final listings = ref.watch(userListingsProvider);
    final isLoadingMore = ref.watch(isLoadingMoreUserListingsProvider);
    
    return RefreshIndicator(
      onRefresh: () => _loadUserListings(force: true),
      child: SingleChildScrollView(
        controller: _sellScrollController,
        physics: Get.scrollPhysics,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SellStatusFiltersSection(onStatusChanged: _onSellStatusChanged),
              9.verticalGap,
              if (isLoading)
                const SellListingsSkeleton()
              else if (listings.isEmpty)
                EmptyState(
                  title: 'no_listings_yet'.tr(context),
                  subtitle: 'no_listings_subtitle'.tr(context),
                  icon: Icons.inventory_2_outlined,
                )
              else
                ...listings.map((listing) {
                  return ListingCard(
                    listing: listing,
                    isNepali: isNepali,
                    onEdit: () async {
                      final result = await Get.to(AddEditProductPage(product: listing));
                      if (result == true) {
                        _loadUserListings();
                      }
                    },
                    onDelete: () => _showDeleteConfirmation(listing),
                  );
                }),
              if (isLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16).rt,
                  child: Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              20.verticalGap,
            ],
          ),
        ),
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

}
