import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/knowledge/articles_page.dart';
import 'package:krishi/features/knowledge/news_page.dart';
import 'package:krishi/features/marketplace/product_detail_page.dart';
import 'package:krishi/features/orders/orders_list_page.dart';
import 'package:krishi/features/resources/crop_calendar_page.dart';
import 'package:krishi/features/resources/emergency_contacts_page.dart';
import 'package:krishi/features/resources/experts_page.dart';
import 'package:krishi/features/resources/notices_page.dart';
import 'package:krishi/features/resources/programs_page.dart';
import 'package:krishi/features/resources/service_providers_page.dart';
import 'package:krishi/features/resources/videos_page.dart';
import 'package:krishi/features/resources/market_prices_page.dart';
import 'package:krishi/features/seller/seller_profile_page.dart';
import 'package:krishi/features/soil_testing/soil_testing_page.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/empty_state.dart';
import 'package:krishi/features/components/error_state.dart';
import 'package:krishi/features/components/notification_icon.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/user_profile.dart';
import 'package:krishi/models/resources.dart';
import 'package:krishi/features/notifications/providers/notifications_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // ValueNotifiers for reactive state management
  final ValueNotifier<List<Product>> trendingProducts = ValueNotifier([]);
  final ValueNotifier<int> receivedOrdersCount = ValueNotifier(0);
  final ValueNotifier<int> placedOrdersCount = ValueNotifier(0);
  final ValueNotifier<List<MarketPrice>> marketPrices = ValueNotifier([]);
  final ValueNotifier<User?> currentUser = ValueNotifier(null);
  final ValueNotifier<bool> isLoadingProducts = ValueNotifier(true);
  final ValueNotifier<bool> isLoadingOrders = ValueNotifier(true);
  final ValueNotifier<bool> isLoadingMarketPrices = ValueNotifier(true);
  final ValueNotifier<String?> productsError = ValueNotifier(null);
  final ValueNotifier<String?> ordersError = ValueNotifier(null);
  final ValueNotifier<String?> marketPricesError = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    trendingProducts.dispose();
    receivedOrdersCount.dispose();
    placedOrdersCount.dispose();
    marketPrices.dispose();
    currentUser.dispose();
    isLoadingProducts.dispose();
    isLoadingOrders.dispose();
    isLoadingMarketPrices.dispose();
    productsError.dispose();
    ordersError.dispose();
    marketPricesError.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProfile(),
      _loadTrendingProducts(),
      _loadOrdersCounts(),
      _loadMarketPrices(),
      ref.read(unreadNotificationsProvider.notifier).refresh(),
    ]);
  }

  Future<void> _loadProfile() async {
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final user = await apiService.getCurrentUser();
      if (mounted) {
        currentUser.value = user;
      }
    } catch (_) {
      // ignore profile fetch errors silently
    }
  }

  Future<void> _loadOrdersCounts() async {
    isLoadingOrders.value = true;
    ordersError.value = null;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final counts = await apiService.getOrdersCounts();

      if (mounted) {
        receivedOrdersCount.value = counts.salesCount;
        placedOrdersCount.value = counts.purchasesCount;
        isLoadingOrders.value = false;
      }
    } catch (e) {
      if (mounted) {
        ordersError.value = e.toString();
        isLoadingOrders.value = false;
      }
    }
  }

  Future<void> _loadTrendingProducts() async {
    isLoadingProducts.value = true;
    productsError.value = null;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getProducts(page: 1);
      final filtered = response.results
          .where((product) => product.isAvailable)
          .toList();
      if (mounted) {
        trendingProducts.value = filtered.take(5).toList();
        isLoadingProducts.value = false;
      }
    } catch (e) {
      if (mounted) {
        productsError.value = e.toString();
        isLoadingProducts.value = false;
      }
    }
  }

  Future<void> _loadMarketPrices() async {
    isLoadingMarketPrices.value = true;
    marketPricesError.value = null;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getMarketPrices(
        page: 1,
        ordering: '-updated_at',
      );
      if (mounted) {
        marketPrices.value = response.results.take(4).toList();
        isLoadingMarketPrices.value = false;
      }
    } catch (e) {
      if (mounted) {
        marketPricesError.value = e.toString();
        isLoadingMarketPrices.value = false;
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 17) return 'good_afternoon';
    return 'good_evening';
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
              padding: const EdgeInsets.all(10).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card with Weather
                  _buildWelcomeCard(),

                  10.verticalGap,

                  // Top Row: Received Order and Placed Order (2-column)
                  _buildOrdersTiles(),

                  10.verticalGap,

                  // Main Services: Soil Test and Notices (2-column)
                  _buildMainServices(),

                  10.verticalGap,

                  // Services: Experts, Providers, Contacts (3-column)
                  _buildServicesGrid(),

                  10.verticalGap,

                  // Knowledge Base: Krishi Gyan, News, Videos, Crop Calendars (2-column grid)
                  _buildKnowledgeBaseGrid(),

                  10.verticalGap,

                  // Market Prices Section
                  _buildMarketPricesSection(),

                  10.verticalGap,
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
    return ValueListenableBuilder<User?>(
      valueListenable: currentUser,
      builder: (context, user, child) {
        final userName = (user?.displayName ?? '').trim();
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/image.png'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              colorFilter: ColorFilter.mode(
                AppColors.primary.withValues(alpha: 0.25),
                BlendMode.srcATop,
              ),
            ),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.5),
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.05, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20).rt,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
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
                    AppText(
                      _getGreeting().tr(context),
                      style: Get.bodyMedium.px14.w500.copyWith(
                        color: AppColors.white.withValues(alpha: 0.95),
                        letterSpacing: 0.5,
                      ),
                    ),
                    6.verticalGap,
                    AppText(
                      userName.isNotEmpty
                          ? userName
                          : 'welcome_user'.tr(context),
                      style: Get.bodyLarge.px28.w800.copyWith(
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    12.verticalGap,
                    AppText(
                      'app_tagline'.tr(context),
                      style: Get.bodyMedium.px14.w500.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTiles() {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingOrders,
      builder: (context, loading, child) {
        return Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: receivedOrdersCount,
                builder: (context, count, child) {
                  return _buildOrderCard(
                    title: 'received_orders',
                    subtitle: 'orders_as_seller',
                    count: count,
                    icon: Icons.inventory_2_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                    ),
                    onTap: () {
                      Get.to(const OrdersListPage.sales());
                    },
                    isLoading: loading,
                  );
                },
              ),
            ),
            12.horizontalGap,
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: placedOrdersCount,
                builder: (context, count, child) {
                  return _buildOrderCard(
                    title: 'placed_orders',
                    subtitle: 'orders_as_buyer',
                    count: count,
                    icon: Icons.shopping_bag_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    ),
                    onTap: () {
                      // Navigate to placed orders (my purchases)
                      Get.to(const OrdersListPage.purchases());
                    },
                    isLoading: loading,
                  );
                },
              ),
            ),
          ],
        );
      },
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
          height: 100.ht,
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
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10).rt,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(14).rt,
                    ),
                    child: Icon(icon, color: AppColors.white, size: 24.st),
                  ),
                  15.horizontalGap,
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
                          overflow: TextOverflow.ellipsis,
                          '$count',
                          style: Get.bodyLarge.px26.w800.copyWith(
                            color: Get.disabledColor,
                          ),
                        ),
                ],
              ),
              10.verticalGap,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    overflow: TextOverflow.ellipsis,
                    title.tr(context),
                    style: Get.bodyMedium.px13.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),
                  2.verticalGap,
                  AppText(
                    overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.all(10).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(30).rt,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20).rt,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Icon(icon, color: AppColors.white, size: 24.st),
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
          overflow: TextOverflow.ellipsis,
          'main_services'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        7.verticalGap,
        _buildMainServiceCard(
          titleKey: 'soil_testing',
          descriptionKey: 'test_soil_quality',
          icon: Icons.science_rounded,
          accentColor: const Color(0xFF5E35B1),
          onTap: () {
            Get.to(const SoilTestingPage());
          },
        ),
        7.verticalGap,
        _buildMainServiceCard(
          titleKey: 'notices',
          descriptionKey: 'important_announcements',
          icon: Icons.notifications_active_rounded,
          accentColor: const Color(0xFFFF8F00),
          onTap: () {
            Get.to(const NoticesPage());
          },
        ),
        7.verticalGap,
        _buildMainServiceCard(
          titleKey: 'programs',
          descriptionKey: 'agricultural_development_programs',
          icon: Icons.agriculture_rounded,
          accentColor: const Color(0xFF2E7D32),
          onTap: () {
            Get.to(const ProgramsPage());
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
            7.horizontalGap,
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
            7.horizontalGap,
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
        10.verticalGap,
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildKnowledgeCard(
                    title: 'krishi_gyaan'.tr(context),
                    icon: Icons.local_library_rounded,
                    accentColor: const Color(0xFF6A1B9A),
                    onTap: () {
                      Get.to(ArticlesPage());
                    },
                  ),
                ),
                12.horizontalGap,
                Expanded(
                  child: _buildKnowledgeCard(
                    title: 'news_information'.tr(context),
                    icon: Icons.article_rounded,
                    accentColor: const Color(0xFFD32F2F),
                    onTap: () {
                      Get.to(const NewsPage());
                    },
                  ),
                ),
              ],
            ),
            12.verticalGap,
            Row(
              children: [
                Expanded(
                  child: _buildKnowledgeCard(
                    title: 'videos'.tr(context),
                    icon: Icons.video_library_rounded,
                    accentColor: const Color(0xFFE65100),
                    onTap: () {
                      Get.to(const VideosPage());
                    },
                  ),
                ),
                12.horizontalGap,
                Expanded(
                  child: _buildKnowledgeCard(
                    title: 'crop_calendar'.tr(context),
                    icon: Icons.calendar_month_rounded,
                    accentColor: const Color(0xFF558B2F),
                    onTap: () {
                      Get.to(const CropCalendarPage());
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Main Service Card with description
  Widget _buildMainServiceCard({
    required String titleKey,
    required String descriptionKey,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8).rt,
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.circular(50).rt,
          border: Border.all(color: accentColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10).rt,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: accentColor, size: 24.st),
            ),
            16.horizontalGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    titleKey.tr(context),
                    style: Get.bodyLarge.px14.w700.copyWith(
                      color: Get.disabledColor,
                    ),
                  ),

                  AppText(
                    descriptionKey.tr(context),
                    style: Get.bodySmall.px11.w500.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: accentColor,
              size: 16.st,
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5).rt,
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
              width: double.infinity,
              padding: const EdgeInsets.all(10).rt,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12).rt,
              ),
              child: Icon(icon, color: color, size: 28.st),
            ),
            6.verticalGap,
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

  // Knowledge Base Card with icon-only highlight
  Widget _buildKnowledgeCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.ht,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3).rt,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4).rt,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12).rt,
                ),
                child: Icon(icon, color: accentColor, size: 24.st),
              ),
              16.horizontalGap,
              Expanded(
                child: AppText(
                  title,
                  style: Get.bodyLarge.px12.w600.copyWith(
                    color: Get.disabledColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              8.horizontalGap,
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accentColor.withValues(alpha: 0.6),
                size: 14.st,
              ),
            ],
          ),
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
              onTap: () => Get.to(const MarketPricesPage()),
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
        ValueListenableBuilder<bool>(
          valueListenable: isLoadingMarketPrices,
          builder: (context, loading, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: marketPricesError,
              builder: (context, error, child) {
                return ValueListenableBuilder<List<MarketPrice>>(
                  valueListenable: marketPrices,
                  builder: (context, prices, child) {
                    return Container(
                      padding: const EdgeInsets.all(16).rt,
                      decoration: BoxDecoration(
                        color: Get.cardColor,
                        borderRadius: BorderRadius.circular(16).rt,
                        border: Border.all(
                          color: Get.disabledColor.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : error != null
                          ? _buildMarketPricesError()
                          : prices.isEmpty
                          ? _buildMarketPricesEmpty()
                          : Column(
                              children: [
                                for (int i = 0; i < prices.length; i++) ...[
                                  _buildMarketPriceRow(prices[i]),
                                  if (i != prices.length - 1)
                                    Divider(
                                      color: Get.disabledColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      height: 20,
                                    ),
                                ],
                              ],
                            ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMarketPriceRow(MarketPrice price) {
    final formattedPrice = _formatMarketPrice(price.price);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10).rt,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12).rt,
          ),
          child: Icon(
            Icons.shopping_cart_rounded,
            color: AppColors.primary,
            size: 20.st,
          ),
        ),
        12.horizontalGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                price.name,
                style: Get.bodyMedium.px15.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              4.verticalGap,
              Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    size: 12.st,
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                  4.horizontalGap,
                  AppText(
                    price.categoryDisplay.isNotEmpty
                        ? price.categoryDisplay
                        : 'market_category_other'.tr(context),
                    style: Get.bodySmall.px11.w500.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppText(
              formattedPrice,
              style: Get.bodyMedium.px15.w800.copyWith(
                color: AppColors.primary,
              ),
            ),
            2.verticalGap,
            AppText(
              '/${price.unit}',
              style: Get.bodySmall.px11.w500.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketPricesError() {
    return Column(
      children: [
        AppText(
          'market_prices_error'.tr(context),
          style: Get.bodyMedium.copyWith(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        12.verticalGap,
        ElevatedButton(
          onPressed: _loadMarketPrices,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12).rt,
            ),
          ),
          child: AppText(
            'retry'.tr(context),
            style: Get.bodyMedium.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketPricesEmpty() {
    return Column(
      children: [
        Icon(
          Icons.bar_chart_rounded,
          color: Get.disabledColor.withValues(alpha: 0.6),
          size: 40.st,
        ),
        8.verticalGap,
        AppText(
          'no_market_prices'.tr(context),
          style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
          textAlign: TextAlign.center,
        ),
        4.verticalGap,
        AppText(
          'market_prices_empty_state_subtitle'.tr(context),
          style: Get.bodySmall.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatMarketPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toStringAsFixed(0);
    }
    return price.toStringAsFixed(2);
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
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingProducts,
      builder: (context, loading, child) {
        if (loading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32).rt,
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return ValueListenableBuilder<String?>(
          valueListenable: productsError,
          builder: (context, error, child) {
            if (error != null) {
              return ErrorState(
                subtitle: 'error_loading_products_subtitle'.tr(context),
                onRetry: _loadTrendingProducts,
              );
            }

            return ValueListenableBuilder<List<Product>>(
              valueListenable: trendingProducts,
              builder: (context, products, child) {
                if (products.isEmpty) {
                  return EmptyState(
                    title: 'no_products_available'.tr(context),
                    subtitle: 'no_products_subtitle'.tr(context),
                    icon: Icons.shopping_bag_outlined,
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                );
              },
            );
          },
        );
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
