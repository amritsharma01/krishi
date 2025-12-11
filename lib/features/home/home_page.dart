import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/notification_icon.dart';
import 'package:krishi/features/notifications/providers/notifications_providers.dart';
import 'package:krishi/features/home/home_notifier.dart';
import 'package:krishi/features/home/widgets/welcome_card.dart';
import 'package:krishi/features/home/widgets/orders_tiles.dart';
import 'package:krishi/features/home/widgets/main_services_section.dart';
import 'package:krishi/features/home/widgets/services_grid.dart';
import 'package:krishi/features/home/widgets/knowledge_base_grid.dart';
import 'package:krishi/features/home/widgets/market_prices_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(homeProvider.notifier).loadAll(),
      ref.read(unreadNotificationsProvider.notifier).refresh(),
    ]);
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
              padding: const EdgeInsets.all(6).rt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeCard(),
                  10.verticalGap,
                  const OrdersTiles(),
                  10.verticalGap,
                  const MainServicesSection(),
                  10.verticalGap,
                  const ServicesGrid(),
                  10.verticalGap,
                  const KnowledgeBaseGrid(),
                  10.verticalGap,
                  const MarketPricesSection(),
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
          AppText(
            'krishi'.tr(context),
            style: Get.bodyLarge.px20.w700.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      actions: [
        Center(child: const NotificationIcon()),
        16.horizontalGap,
      ],
    );
  }
}
