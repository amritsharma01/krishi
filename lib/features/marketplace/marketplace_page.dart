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
import 'package:krishi/features/widgets/app_text.dart';
import 'package:krishi/features/widgets/form_field.dart';
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

  @override
  void initState() {
    super.initState();
    _loadBuyProducts();
    _loadUserListings();
  }

  Future<void> _loadBuyProducts() async {
    setState(() {
      isLoadingBuyProducts = true;
      buyProductsError = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getProducts(
        page: 1,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      if (mounted) {
        setState(() {
          buyProducts = response.results;
          isLoadingBuyProducts = false;
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

  Future<void> _loadUserListings() async {
    setState(() {
      isLoadingUserListings = true;
      userListingsError = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      // Get current user first to filter their products
      final user = await apiService.getCurrentUser();
      final response = await apiService.getProducts(page: 1);
      if (mounted) {
        setState(() {
          // Filter products by current user
          userListings = response.results
              .where((product) => product.seller == user.id)
              .toList();
          isLoadingUserListings = false;
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

  @override
  void dispose() {
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
                Padding(
                  padding: const EdgeInsets.all(32).rt,
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48.st),
                      16.verticalGap,
                      AppText(
                        'error_loading_products'.tr(context),
                        style: Get.bodyMedium.px14.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                )
              else if (buyProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32).rt,
                  child: AppText(
                    'no_products_available'.tr(context),
                    style: Get.bodyMedium.px14.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.6),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.rt,
                    mainAxisSpacing: 12.rt,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: buyProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(buyProducts[index]);
                  },
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
                Padding(
                  padding: const EdgeInsets.all(32).rt,
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48.st),
                      16.verticalGap,
                      AppText(
                        'error_loading_listings'.tr(context),
                        style: Get.bodyMedium.px14.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                )
              else if (userListings.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32).rt,
                  child: AppText(
                    'no_listings_yet'.tr(context),
                    style: Get.bodyMedium.px14.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.6),
                    ),
                  ),
                )
              else
                ...userListings.map((listing) {
                  return _buildListingCard(listing);
                }),
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
          // Product Image
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
                      Get.baseUrl + product.image!,
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
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        product.name,
                        style: Get.bodyMedium.px13.w700.copyWith(
                          color: Get.disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.verticalGap,
                      AppText(
                        'Rs. ${product.price}/${product.unitName}',
                        style: Get.bodyMedium.px16.w800.copyWith(
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  // Add to Cart Button
                  GestureDetector(
                    onTap: () async {
                      try {
                        final apiService = ref.read(krishiApiServiceProvider);
                        await apiService.addToCart(
                          productId: product.id,
                          quantity: 1,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('added_to_cart'.tr(context)),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('error_adding_to_cart'.tr(context)),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7).rt,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8).rt,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AppText(
                          'add_to_cart'.tr(context),
                          style: Get.bodySmall.px11.w700.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
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

  void _showDeleteConfirmation(Product product) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Get.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'delete_product'.tr(context),
            style: Get.bodyLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'delete_confirmation'.tr(context),
            style: Get.bodyMedium.copyWith(
              fontSize: 14,
              color: Get.disabledColor.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'cancel'.tr(context),
                style: TextStyle(color: Get.disabledColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final apiService = ref.read(krishiApiServiceProvider);
                  await apiService.deleteProduct(product.id);

                  if (!mounted) return;

                  Navigator.pop(dialogContext);
                  _loadUserListings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Product deleted"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error deleting product"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
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
                      Get.baseUrl + listing.image!,
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
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditProductPage(product: listing),
                    ),
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
