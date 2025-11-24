import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/services/cache_service.dart';
import 'package:krishi/models/order.dart';
import 'package:krishi/features/knowledge/articles_page.dart';
import 'package:krishi/features/knowledge/news_page.dart';
import 'package:krishi/features/marketplace/product_detail_page.dart';
import 'package:krishi/features/orders/orders_list_page.dart';
import 'package:krishi/features/resources/crop_calendar_page.dart';
import 'package:krishi/features/resources/emergency_contacts_page.dart';
import 'package:krishi/features/resources/experts_page.dart';
import 'package:krishi/features/resources/notices_page.dart';
import 'package:krishi/features/resources/service_providers_page.dart';
import 'package:krishi/features/resources/videos_page.dart';
import 'package:krishi/features/seller/seller_profile_page.dart';
import 'package:krishi/features/soil_testing/soil_testing_page.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/components/notification_icon.dart';
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
  int receivedOrdersCount = 0;
  int placedOrdersCount = 0;
  bool isLoadingWeather = true;
  bool isLoadingProducts = true;
  bool isLoadingOrders = true;
  String? weatherError;
  String? productsError;
  String? ordersError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadWeather(),
      _loadTrendingProducts(),
      _loadOrdersCounts(),
    ]);
  }

  Future<void> _loadOrdersCounts() async {
    setState(() {
      isLoadingOrders = true;
      ordersError = null;
    });

    try {
      final cacheService = ref.read(cacheServiceProvider);
      final apiService = ref.read(krishiApiServiceProvider);

      // Try to load from cache first
      final cachedSales = await cacheService.getMySalesCache();
      final cachedPurchases = await cacheService.getMyPurchasesCache();

      if (cachedSales != null && cachedPurchases != null) {
        final receivedOrders = cachedSales
            .map((json) => Order.fromJson(json))
            .toList();
        final placedOrders = cachedPurchases
            .map((json) => Order.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            receivedOrdersCount = receivedOrders.length;
            placedOrdersCount = placedOrders.length;
            isLoadingOrders = false;
          });
        }
      }

      // Fetch fresh data from API
      final receivedOrders = await apiService.getMySales();
      final placedOrders = await apiService.getMyPurchases();

      // Save to cache
      await Future.wait([
        cacheService.saveMySalesCache(
          receivedOrders.map((o) => o.toJson()).toList(),
        ),
        cacheService.saveMyPurchasesCache(
          placedOrders.map((o) => o.toJson()).toList(),
        ),
      ]);

      if (mounted) {
        setState(() {
          receivedOrdersCount = receivedOrders.length;
          placedOrdersCount = placedOrders.length;
          isLoadingOrders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          ordersError = e.toString();
          isLoadingOrders = false;
        });
      }
    }
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
      final filtered = response.results
          .where((product) => product.isAvailable)
          .toList();
      if (mounted) {
        setState(() {
          trendingProducts = filtered.take(5).toList();
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

                  // Top Row: Received Order and Placed Order (2-column)
                  _buildOrdersTiles(),

                  20.verticalGap,

                  // Main Services: Soil Test and Notices (2-column)
                  _buildMainServices(),

                  20.verticalGap,

                  // Services: Experts, Providers, Contacts (3-column)
                  _buildServicesGrid(),

                  20.verticalGap,

                  // Knowledge Base: Krishi Gyan, News, Videos, Crop Calendars (2-column grid)
                  _buildKnowledgeBaseGrid(),

                  20.verticalGap,

                  // Market Prices Section
                  _buildMarketPricesSection(),

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
          SizedBox(
            height: 40.rt,
            width: 40.rt,
            child: Image.asset('assets/logo.png', fit: BoxFit.contain),
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
        image: DecorationImage(
          image: const AssetImage('assets/images/image.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primary.withValues(alpha: 0.4),
            BlendMode.srcATop,
          ),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.05, 0.5, 1.0],
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
                                weather?.location ?? 'unknown'.tr(context),
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

  Widget _buildOrdersTiles() {
    return Row(
      children: [
        Expanded(
          child: _buildOrderCard(
            title: 'received_orders',
            subtitle: 'orders_as_seller',
            count: receivedOrdersCount,
            icon: Icons.inventory_2_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
            ),
            onTap: () {
              // Navigate to received orders (my sales)
              Get.to(const OrdersListPage.sales());
            },
            isLoading: isLoadingOrders,
          ),
        ),
        12.horizontalGap,
        Expanded(
          child: _buildOrderCard(
            title: 'placed_orders',
            subtitle: 'orders_as_buyer',
            count: placedOrdersCount,
            icon: Icons.shopping_bag_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
            onTap: () {
              // Navigate to placed orders (my purchases)
              Get.to(const OrdersListPage.purchases());
            },
            isLoading: isLoadingOrders,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    final canInteract = !isLoading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canInteract ? onTap : null,
        borderRadius: BorderRadius.circular(20).rt,
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
        child: Container(
          height: 130.ht,
          padding: const EdgeInsets.all(16).rt,
          decoration: BoxDecoration(
            color: Get.cardColor,
            borderRadius: BorderRadius.circular(20).rt,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12).rt,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14).rt,
                ),
                child: Icon(icon, color: AppColors.white, size: 24.st),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading
                      ? SizedBox(
                          width: 24.st,
                          height: 24.st,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      : AppText(
                          '$count',
                          style: Get.bodyLarge.px28.w800.copyWith(
                            color: Get.disabledColor,
                          ),
                        ),
                  4.verticalGap,
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
      ),
    );
  }

  // ignore: unused_element
  Widget _buildHorizontalTiles() {
    return Column(
      children: [
        _buildHorizontalTile(
          title: 'soil_testing',
          subtitle: 'test_soil_quality',
          icon: Icons.science_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
          ),
          onTap: () {
            Get.to(const SoilTestingPage());
          },
        ),
        12.verticalGap,
        _buildHorizontalTile(
          title: 'kishan_gyaan',
          subtitle: 'farming_knowledge',
          icon: Icons.local_library_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
          ),
          onTap: () {
            Get.to(ArticlesPage());
          },
        ),
        12.verticalGap,
        _buildHorizontalTile(
          title: 'news_information',
          subtitle: 'latest_updates',
          icon: Icons.article_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFE57373)],
          ),
          onTap: () {
            Get.to(const NewsPage());
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(16).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14).rt,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Icon(icon, color: AppColors.white, size: 26.st),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title.tr(context),
                    style: Get.bodyMedium.px15.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalGap,
                  AppText(
                    subtitle.tr(context),
                    style: Get.bodySmall.px12.w500.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18.st,
              color: Get.disabledColor.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  // Main Services Section
  Widget _buildMainServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'main_services'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        12.verticalGap,
        _buildMainServiceCard(
          title: 'soil_testing',
          description: 'test_soil_quality',
          icon: Icons.science_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {
            Get.to(const SoilTestingPage());
          },
        ),
        12.verticalGap,
        _buildMainServiceCard(
          title: 'notices'.tr(context),
          description: 'important_announcements'.tr(context),
          icon: Icons.notifications_active_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {
            Get.to(const NoticesPage());
          },
        ),
        12.verticalGap,
        _buildMainServiceCard(
          title: 'programs'.tr(context),
          description: 'agricultural_development_programs'.tr(context),
          icon: Icons.agriculture_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF388E3C), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {
            Get.snackbar('coming_soon'.tr(context));
          },
        ),
      ],
    );
  }

  // Services and Directory Section
  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'services_directory'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        12.verticalGap,
        Row(
          children: [
            Expanded(
              child: _buildDirectoryCard(
                title: 'agri_experts',
                icon: Icons.people_rounded,
                color: const Color(0xFF00897B),
                onTap: () {
                  Get.to(const ExpertsPage());
                },
              ),
            ),
            12.horizontalGap,
            Expanded(
              child: _buildDirectoryCard(
                title: 'service_providers',
                icon: Icons.business_rounded,
                color: const Color(0xFF1565C0),
                onTap: () {
                  Get.to(const ServiceProvidersPage());
                },
              ),
            ),
            12.horizontalGap,
            Expanded(
              child: _buildDirectoryCard(
                title: 'emergency_contacts',
                icon: Icons.emergency_rounded,
                color: const Color(0xFFC62828),
                onTap: () {
                  Get.to(const EmergencyContactsPage());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Knowledge Base Section (2x2 Grid)
  Widget _buildKnowledgeBaseGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'knowledge_base'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        12.verticalGap,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            _buildKnowledgeCard(
              title: 'krishi_gyaan'.tr(context),
              subtitle: 'farming_knowledge_home'.tr(context),
              icon: Icons.local_library_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Get.to(ArticlesPage());
              },
            ),
            _buildKnowledgeCard(
              title: 'news_information'.tr(context),
              subtitle: 'latest_updates'.tr(context),
              icon: Icons.article_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFE57373)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Get.to(const NewsPage());
              },
            ),
            _buildKnowledgeCard(
              title: 'videos'.tr(context),
              subtitle: 'watch_learn'.tr(context),
              icon: Icons.video_library_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFFF6F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Get.to(const VideosPage());
              },
            ),
            _buildKnowledgeCard(
              title: 'crop_calendar'.tr(context),
              subtitle: 'planting_guide'.tr(context),
              icon: Icons.calendar_month_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF558B2F), Color(0xFF8BC34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Get.to(const CropCalendarPage());
              },
            ),
          ],
        ),
      ],
    );
  }

  // Main Service Card with description
  Widget _buildMainServiceCard({
    required String title,
    required String description,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10).rt,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14).rt,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14).rt,
              ),
              child: Icon(icon, color: Colors.white, size: 32.st),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title.tr(context),
                    style: Get.bodyLarge.px16.w700.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  4.verticalGap,
                  AppText(
                    description.tr(context),
                    style: Get.bodySmall.px12.w500.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18.st,
            ),
          ],
        ),
      ),
    );
  }

  // Directory Card (Compact)
  Widget _buildDirectoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(14).rt,
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10).rt,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Icon(icon, color: color, size: 28.st),
            ),
            10.verticalGap,
            AppText(
              title.tr(context),
              style: Get.bodySmall.px11.w600.copyWith(color: Get.disabledColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Knowledge Base Card with subtitle
  Widget _buildKnowledgeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 100.st,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12).rt,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12).rt,
                    ),
                    child: Icon(icon, color: Colors.white, size: 32.st),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        style: Get.bodyMedium.px14.w700.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.verticalGap,
                      AppText(
                        subtitle,
                        style: Get.bodySmall.px11.w500.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Market Prices Section
  Widget _buildMarketPricesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              'market_prices'.tr(context),
              style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to all market prices
                Get.snackbar('Coming soon!');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ).rt,
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
        ),
        12.verticalGap,
        Container(
          padding: const EdgeInsets.all(16).rt,
          decoration: BoxDecoration(
            color: Get.cardColor,
            borderRadius: BorderRadius.circular(16).rt,
            border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPriceItem(
                context,
                'rice'.tr(context),
                'NPR 45/kg',
                Icons.rice_bowl_rounded,
                Colors.orange,
              ),
              Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
              _buildPriceItem(
                context,
                'wheat'.tr(context),
                'NPR 38/kg',
                Icons.grain_rounded,
                Colors.amber,
              ),
              Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
              _buildPriceItem(
                context,
                'tomato'.tr(context),
                'NPR 60/kg',
                Icons.local_pizza_rounded,
                Colors.red,
              ),
              Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
              _buildPriceItem(
                context,
                'potato'.tr(context),
                'NPR 35/kg',
                Icons.emoji_food_beverage_rounded,
                Colors.brown,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Price Item Widget
  Widget _buildPriceItem(
    BuildContext context,
    String item,
    String price,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8).rt,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8).rt,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10).rt,
            ),
            child: Icon(icon, color: color, size: 24.st),
          ),
          12.horizontalGap,
          Expanded(
            child: AppText(
              item,
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
          ),
          AppText(
            price,
            style: Get.bodyMedium.px14.w700.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
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

  // ignore: unused_element
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
      return ErrorState(
        subtitle: 'error_loading_products_subtitle'.tr(context),
        onRetry: _loadTrendingProducts,
      );
    }

    if (trendingProducts.isEmpty) {
      return EmptyState(
        title: 'no_products_available'.tr(context),
        subtitle: 'no_products_subtitle'.tr(context),
        icon: Icons.shopping_bag_outlined,
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
          // Product Image - Tappable for navigation
          GestureDetector(
            onTap: () {
              Get.to(ProductDetailPage(product: product));
            },
            child: Container(
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
                        Get.imageUrl(product.image),
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
          ),
          16.horizontalGap,
          // Product Details - Tappable for navigation
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.to(ProductDetailPage(product: product));
              },
              behavior: HitTestBehavior.opaque,
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SellerProfilePage(sellerId: product.seller),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          color: Get.disabledColor.withValues(alpha: 0.5),
                          size: 14.st,
                        ),
                        4.horizontalGap,
                        Expanded(
                          child: AppText(
                            product.sellerName ?? product.sellerEmail,
                            style: Get.bodySmall.px11.w500.copyWith(
                              color: Get.disabledColor.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10.st,
                          color: Get.disabledColor.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
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
          ),
          // Add to Cart Button - Separate action
          _CartButton(product: product),
        ],
      ),
    );
  }
}

class _CartButton extends ConsumerStatefulWidget {
  final Product product;

  const _CartButton({required this.product});

  @override
  ConsumerState<_CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends ConsumerState<_CartButton> {
  bool isLoading = false;
  bool isAdded = false;

  Future<void> _addToCart() async {
    if (isLoading || isAdded) return;

    setState(() => isLoading = true);

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      await apiService.addToCart(productId: widget.product.id, quantity: 1);

      if (mounted) {
        setState(() {
          isLoading = false;
          isAdded = true;
        });
        Get.snackbar('added_to_cart'.tr(Get.context), color: Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        Get.snackbar('error_adding_to_cart'.tr(Get.context), color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _addToCart,
      child: Container(
        padding: const EdgeInsets.all(12).rt,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAdded
                ? [Colors.green.shade500, Colors.green.shade600]
                : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12).rt,
          boxShadow: [
            BoxShadow(
              color: (isAdded ? Colors.green : AppColors.primary).withValues(
                alpha: 0.3,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 20.st,
                  height: 20.st,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  isAdded
                      ? Icons.check_circle
                      : Icons.add_shopping_cart_rounded,
                  key: ValueKey(isAdded ? 'added' : 'add'),
                  color: AppColors.white,
                  size: 20.st,
                ),
        ),
      ),
    );
  }
}
