import 'dart:io';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/cart/cart_page.dart';
import 'package:krishi/features/marketplace/add_edit_product_page.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:flutter/material.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  bool isBuyTab = true;
  final TextEditingController _searchController = TextEditingController();

  // Dummy data for marketplace products
  final List<Map<String, dynamic>> buyProducts = [
    {
      'name': 'Premium Wheat',
      'nameNe': 'प्रिमियम गहुँ',
      'price': 'Rs. 20.50',
      'image': '🌾',
      'bgColor': Color(0xFFD4E7D4),
      'textColor': Color(0xFF2E7D32),
    },
    {
      'name': 'Fresh Tomatoes',
      'nameNe': 'ताजा गोलभेडा',
      'price': 'Rs. 5.00',
      'image': '🍅',
      'bgColor': Color(0xFFFFD4D4),
      'textColor': Color(0xFFC62828),
    },
    {
      'name': 'Organic Potatoes',
      'nameNe': 'जैविक आलु',
      'price': 'Rs. 8.75',
      'image': '🥔',
      'bgColor': Color(0xFFEEDDCC),
      'textColor': Color(0xFF8B5E34),
    },
    {
      'name': 'Modern Tractor',
      'nameNe': 'आधुनिक ट्रयाक्टर',
      'price': 'Rs. 15000.00',
      'image': '🚜',
      'bgColor': Color(0xFFD4D4E7),
      'textColor': Color(0xFF3949AB),
    },
  ];

  // Dummy user listings
  List<Map<String, dynamic>> userListings = [
    {
      'id': '1',
      'name': 'Modern Tractor',
      'nameNe': 'आधुनिक ट्रयाक्टर',
      'price': 'Rs. 15000.00',
      'image': '🚜',
      'bgColor': Color(0xFFD4D4E7),
    },
    {
      'id': '2',
      'name': 'High-Yield Seeds',
      'nameNe': 'उच्च उत्पादन बीउ',
      'price': 'Rs. 50.00',
      'image': '🌱',
      'bgColor': Color(0xFFD4E7D4),
    },
  ];

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
            16.verticalGap,
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
      title: AppText(
        'marketplace'.tr(context),
        style: Get.bodyLarge.px22.w700.copyWith(color: Get.disabledColor),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: Get.disabledColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
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
    return SingleChildScrollView(
      physics: Get.scrollPhysics,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).rt,
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).rt,
              decoration: BoxDecoration(
                color: Get.cardColor,
                borderRadius: BorderRadius.circular(8).rt,
                border: Border.all(
                  color: Get.disabledColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Get.disabledColor.withValues(alpha: 0.5),
                    size: 20.st,
                  ),
                  12.horizontalGap,
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'search_products'.tr(context),
                        hintStyle: Get.bodyMedium.px14.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: Get.bodyMedium.px14,
                    ),
                  ),
                ],
              ),
            ),
            16.verticalGap,
            // Products Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.rt,
                mainAxisSpacing: 12.rt,
                childAspectRatio: 0.8,
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
    );
  }

  Widget _buildSellContent() {
    return SingleChildScrollView(
      physics: Get.scrollPhysics,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).rt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Product Button
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditProductPage(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    userListings.add({
                      'id': DateTime.now().toString(),
                      ...result,
                      'bgColor': Color(0xFFD4E7D4),
                    });
                  });
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
            ...userListings.asMap().entries.map((entry) {
              final index = entry.key;
              final listing = entry.value;
              return _buildListingCard(listing, index);
            }),
            20.verticalGap,
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
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
            height: 110.rt,
            decoration: BoxDecoration(
              color: product['bgColor'],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.rt),
                topRight: Radius.circular(16.rt),
              ),
            ),
            child: product.containsKey('imagePath') && product['imagePath'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.rt),
                      topRight: Radius.circular(16.rt),
                    ),
                    child: Image.file(
                      File(product['imagePath']),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            product['image'],
                            style: TextStyle(fontSize: 42.st),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      product['image'],
                      style: TextStyle(fontSize: 42.st),
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
                        product['name'],
                        style: Get.bodyMedium.px13.w700.copyWith(
                          color: product['textColor'],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.verticalGap,
                      AppText(
                        product['price'],
                        style: Get.bodyMedium.px14.w800.copyWith(
                          color: Get.disabledColor,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  // Add to Cart Button
                  GestureDetector(
                    onTap: () {
                      Get.snackbar('Added to cart!');
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

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Get.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16).rt,
        ),
        title: AppText(
          'delete_product'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(
            color: Get.disabledColor,
          ),
        ),
        content: AppText(
          'delete_confirmation'.tr(context),
          style: Get.bodyMedium.px14.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
              'cancel'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                userListings.removeAt(index);
              });
              Navigator.pop(context);
              Get.snackbar('Product deleted successfully');
            },
            child: AppText(
              'delete'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing, int index) {
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
              color: listing['bgColor'],
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: listing.containsKey('imagePath') && listing['imagePath'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12).rt,
                    child: Image.file(
                      File(listing['imagePath']),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            listing['image'],
                            style: TextStyle(fontSize: 32.st),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      listing['image'],
                      style: TextStyle(fontSize: 32.st),
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
                  listing['name'],
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                6.verticalGap,
                AppText(
                  listing['price'],
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
                      builder: (context) => AddEditProductPage(product: listing),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      userListings[index] = {
                        ...listing,
                        ...result,
                      };
                    });
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
                onTap: () => _showDeleteConfirmation(index),
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
