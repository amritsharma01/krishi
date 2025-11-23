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
import 'package:krishi/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool isLoadingBuyProducts = true;
  bool isLoadingUserListings = true;
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

  @override
  void initState() {
    super.initState();
    _buyScrollController.addListener(_onBuyScroll);
    _sellScrollController.addListener(_onSellScroll);
    _loadBuyProducts();
    _loadUserListings();
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
      
      // Only use cache if there's no search query
      if (_searchController.text.isEmpty) {
        final cachedProducts = await cacheService.getBuyProductsCache();
        if (cachedProducts != null) {
          final products = cachedProducts.map((json) => Product.fromJson(json)).toList();
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
      );
      
      // Save to cache only if no search query
      if (_searchController.text.isEmpty) {
        await cacheService.saveBuyProductsCache(
          response.results.map((p) => p.toJson()).toList(),
        );
      }
      
      if (mounted) {
        setState(() {
          buyProducts = response.results;
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
      );
      if (mounted) {
        setState(() {
          buyProducts = [...buyProducts, ...response.results];
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
      _currentUserId ??= (await apiService.getCurrentUser()).id;
      
      // Try to load from cache first
      final cachedProducts = await cacheService.getSellProductsCache();
      if (cachedProducts != null) {
        final products = cachedProducts.map((json) => Product.fromJson(json)).toList();
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
        sellerId: _currentUserId,
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
    if (_currentUserId == null) {
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
        sellerId: _currentUserId,
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
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Selector
            _buildTabSelector(),
            16.verticalGap,
            // Content
            Expanded(
              child: isBuyTab ? _buildBuyContent() : _buildSellContent(),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16).rt,
      child: Container(
        padding: const EdgeInsets.all(4).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(12).rt,
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
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10).rt,
                  decoration: BoxDecoration(
                    color: isBuyTab ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10).rt,
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
                      style: Get.bodyMedium.px15.w700.copyWith(
                        color: isBuyTab
                            ? AppColors.white
                            : Get.disabledColor.withValues(alpha: 0.6),
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
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10).rt,
                  decoration: BoxDecoration(
                    color: !isBuyTab ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10).rt,
                    boxShadow: !isBuyTab
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
                      'sell'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
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

  Widget _buildBuyContent() {
    return RefreshIndicator(
      onRefresh: _loadBuyProducts,
      child: SingleChildScrollView(
        controller: _buyScrollController,
        physics: Get.scrollPhysics,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).rt,
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
                radius: 8,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _loadBuyProducts(),
                onClear: () {
                  setState(() {});
                  _loadBuyProducts();
                },
              ),

              16.verticalGap,
              // Products Grid
              if (isLoadingBuyProducts)
                Padding(
                  padding: const EdgeInsets.all(32).rt,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
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
                    crossAxisSpacing: 12.rt,
                    mainAxisSpacing: 12.rt,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: buyProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(buyProducts[index]);
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

  Widget _buildSellContent() {
    return RefreshIndicator(
      onRefresh: _loadUserListings,
      child: SingleChildScrollView(
        controller: _sellScrollController,
        physics: Get.scrollPhysics,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add New Product Button
              GestureDetector(
                onTap: () async {
                  final result = await Get.to(AddEditProductPage());
                  if (result == true) {
                    _loadUserListings();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14).rt,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12).rt,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.white,
                        size: 22.st,
                      ),
                      10.horizontalGap,
                      AppText(
                        'add_new_product'.tr(context),
                        style: Get.bodyMedium.px15.w700.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              20.verticalGap,
              // Your Listings
              AppText(
                'your_listings'.tr(context),
                style: Get.bodyLarge.px18.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              16.verticalGap,
              // Listings
              if (isLoadingUserListings)
                Padding(
                  padding: const EdgeInsets.all(32).rt,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
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
                  return _buildListingCard(listing);
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

  Widget _buildProductCard(Product product) {
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
            child: Container(
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
                              color: AppColors.primary.withValues(alpha: 0.3),
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
          ),
          Padding(
            padding: const EdgeInsets.all(12).rt,
            child: GestureDetector(
              onTap: () => Get.to(ProductDetailPage(product: product)),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    product.name,
                    style: Get.bodyLarge.px16.w800.copyWith(
                      color: Get.disabledColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalGap,
                  AppText(
                    'Rs. ${product.price}/${product.unitName}',
                    style: Get.bodyMedium.px12.w700.copyWith(
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
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

  Widget _buildListingCard(Product listing) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.rt),
      padding: const EdgeInsets.all(14).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
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
          // Product Image
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
          16.horizontalGap,
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  listing.name,
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                6.verticalGap,
                AppText(
                  'Rs. ${listing.price}/${listing.unitName}',
                  style: Get.bodyMedium.px14.w700.copyWith(
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
}
