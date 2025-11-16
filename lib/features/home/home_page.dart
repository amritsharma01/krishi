import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/cart/cart_page.dart';
import 'package:krishi/features/knowledge/articles_page.dart';
import 'package:krishi/features/knowledge/news_page.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:krishi/features/widgets/notification_icon.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Weather? weather;
  List<Product> trendingProducts = [];
  bool isLoadingWeather = true;
  bool isLoadingProducts = true;
  String? weatherError;
  String? productsError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadWeather(), _loadTrendingProducts()]);
  }

  Future<void> _loadWeather() async {
    setState(() {
      isLoadingWeather = true;
      weatherError = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final weatherData = await apiService.getCurrentWeather();
      if (mounted) {
        setState(() {
          weather = weatherData;
          isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          weatherError = e.toString();
          isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> _loadTrendingProducts() async {
    setState(() {
      isLoadingProducts = true;
      productsError = null;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getProducts(page: 1);
      if (mounted) {
        setState(() {
          trendingProducts = response.results.take(5).toList();
          isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          productsError = e.toString();
          isLoadingProducts = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 17) return 'good_afternoon';
    return 'good_evening';
  }

  IconData _getWeatherIcon() {
    if (weather == null) return Icons.wb_sunny_rounded;
    final condition = weather!.condition.toLowerCase();
    if (condition.contains('clear')) return Icons.wb_sunny_rounded;
    if (condition.contains('cloud')) return Icons.wb_cloudy_rounded;
    if (condition.contains('rain')) return Icons.umbrella_rounded;
    if (condition.contains('snow')) return Icons.ac_unit_rounded;
    return Icons.wb_sunny_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: _buildCustomAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card with Weather
                  _buildWelcomeCard(),

                  20.verticalGap,

                  // Four Feature Cards
                  _buildFeatureCards(),

                  24.verticalGap,

                  // Trending Products Section
                  _buildTrendingProductsHeader(),

                  16.verticalGap,

                  _buildTrendingProductsList(),

                  20.verticalGap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildCustomAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Get.scaffoldBackgroundColor,
      elevation: 0,
      title: Row(
        children: [
          // Agriculture Icon
          Container(
            padding: const EdgeInsets.all(8).rt,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: Icon(
              Icons.agriculture_rounded,
              color: AppColors.white,
              size: 24.st,
            ),
          ),
          12.horizontalGap,
          // Krishi Text
          AppText(
            'krishi'.tr(context),
            style: Get.bodyLarge.px22.w700.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      actions: [
        Center(child: const NotificationIcon()),
        16.horizontalGap,
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20).rt,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100.rt,
              height: 100.rt,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120.rt,
              height: 120.rt,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20).rt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            _getGreeting().tr(context),
                            style: Get.bodyMedium.px15.w500.copyWith(
                              color: AppColors.white.withValues(alpha: 0.95),
                              letterSpacing: 0.5,
                            ),
                          ),
                          6.verticalGap,
                          AppText(
                            'welcome_user'.tr(context),
                            style: Get.bodyLarge.px28.w800.copyWith(
                              color: AppColors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Weather Icon
                    Container(
                      padding: const EdgeInsets.all(14).rt,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16).rt,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: isLoadingWeather
                          ? SizedBox(
                              width: 36.st,
                              height: 36.st,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _getWeatherIcon(),
                              color: AppColors.white,
                              size: 30.st,
                            ),
                    ),
                  ],
                ),
                18.verticalGap,
                // Location and Weather Info
                Container(
                  padding: const EdgeInsets.all(14).rt,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14).rt,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: isLoadingWeather
                      ? Center(
                          child: AppText(
                            'loading_weather'.tr(context),
                            style: Get.bodyMedium.px14.w600.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        )
                      : weatherError != null
                      ? Center(
                          child: AppText(
                            'weather_error'.tr(context),
                            style: Get.bodyMedium.px14.w600.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: AppColors.white,
                              size: 20.st,
                            ),
                            8.horizontalGap,
                            Expanded(
                              child: AppText(
                                weather?.location ?? 'Unknown',
                                style: Get.bodyMedium.px14.w600.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Container(
                              height: 24.rt,
                              width: 1.5,
                              color: AppColors.white.withValues(alpha: 0.4),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ).rt,
                            ),
                            Icon(
                              Icons.thermostat_rounded,
                              color: AppColors.white,
                              size: 20.st,
                            ),
                            6.horizontalGap,
                            AppText(
                              '${weather?.temperatureC.toStringAsFixed(1) ?? '--'}°C',
                              style: Get.bodyMedium.px14.w700.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'kishan_gyaan',
                subtitle: 'farming_knowledge',
                icon: Icons.local_library_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                ),
                onTap: () {
                  Get.to(ArticlesPage());
                },
              ),
            ),
            12.horizontalGap,
            Expanded(
              child: _buildFeatureCard(
                title: 'your_activity',
                subtitle: 'track_activity',
                icon: Icons.timeline_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                ),
                onTap: () {
                  // TODO: Navigate to Activity page
                },
              ),
            ),
          ],
        ),
        12.verticalGap,
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'news_information',
                subtitle: 'latest_updates',
                icon: Icons.article_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewsPage()),
                  );
                },
              ),
            ),
            12.horizontalGap,
            Expanded(
              child: _buildFeatureCard(
                title: 'view_cart',
                subtitle: 'items_in_cart',
                icon: Icons.shopping_cart_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFE57373)],
                ),
                onTap: () {
                  Get.to(CartPage());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    int? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.rt,
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(20).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10).rt,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                  child: Icon(icon, color: AppColors.white, size: 22.st),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4).rt,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Get.cardColor, width: 2),
                      ),
                      child: AppText(
                        '$badge',
                        style: Get.bodySmall.px10.w700.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title.tr(context),
                  style: Get.bodyMedium.px13.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                2.verticalGap,
                AppText(
                  subtitle.tr(context),
                  style: Get.bodySmall.px10.w500.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingProductsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          'trending_products'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to all products page
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6).rt,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20).rt,
            ),
            child: Row(
              children: [
                AppText(
                  'view_all'.tr(context),
                  style: Get.bodyMedium.px12.w600.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                4.horizontalGap,
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 14.st,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingProductsList() {
    if (isLoadingProducts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32).rt,
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (productsError != null) {
      return Center(
        child: Padding(
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
        ),
      );
    }

    if (trendingProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32).rt,
          child: AppText(
            'no_products_available'.tr(context),
            style: Get.bodyMedium.px14.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trendingProducts.length,
      itemBuilder: (context, index) {
        final product = trendingProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.rt),
      padding: const EdgeInsets.all(12).rt,
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
            width: 80.rt,
            height: 80.rt,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: product.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12).rt,
                    child: Image.network(
                      Get.baseUrl + product.image!,
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
                  product.name,
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 1,
                ),
                4.verticalGap,
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      color: Get.disabledColor.withValues(alpha: 0.5),
                      size: 14.st,
                    ),
                    4.horizontalGap,
                    Expanded(
                      child: AppText(
                        product.sellerEmail,
                        style: Get.bodySmall.px11.w500.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                8.verticalGap,
                Row(
                  children: [
                    AppText(
                      'Rs. ${product.price}',
                      style: Get.bodyMedium.px18.w800.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    AppText(
                      '/${product.unitName}',
                      style: Get.bodySmall.px11.w500.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add to Cart Button
          GestureDetector(
            onTap: () async {
              try {
                final apiService = ref.read(krishiApiServiceProvider);
                await apiService.addToCart(productId: product.id, quantity: 1);
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
              padding: const EdgeInsets.all(12).rt,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12).rt,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_shopping_cart_rounded,
                color: AppColors.white,
                size: 20.st,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
