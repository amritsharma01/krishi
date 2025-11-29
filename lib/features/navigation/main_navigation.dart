import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/core/services/storage_services/hive_keys.dart';
import 'package:krishi/features/account/account_page.dart';
import 'package:krishi/features/home/home_page.dart';
import 'package:krishi/features/marketplace/marketplace_page.dart';
import 'package:krishi/features/support/support_page.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);
  final ValueNotifier<bool> _isInitialized = ValueNotifier(false);

  final List<Widget> _pages = const [
    HomePage(),
    MarketplacePage(),
    SupportPage(),
    AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedTabIndex();
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    _isInitialized.dispose();
    super.dispose();
  }

  Future<void> _loadSavedTabIndex() async {
    final storage = ref.read(storageServiceProvider);
    final savedIndex = await storage.get(StorageKeys.currentTabIndex) ?? 0;
    if (mounted) {
      _currentIndex.value = savedIndex;
      _isInitialized.value = true;
    }
  }

  Future<void> _saveTabIndex(int index) async {
    final storage = ref.read(storageServiceProvider);
    await storage.set(StorageKeys.currentTabIndex, index);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isInitialized,
      builder: (context, isInitialized, _) {
        // Show a minimal loading state while initializing
        if (!isInitialized) {
          return Scaffold(
            backgroundColor: Get.scaffoldBackgroundColor,
            body: SafeArea(
              child: _buildInitialSkeleton(),
            ),
          );
        }

        return ValueListenableBuilder<int>(
          valueListenable: _currentIndex,
          builder: (context, currentIndex, _) {
            return Scaffold(
              body: IndexedStack(index: currentIndex, children: _pages),
              bottomNavigationBar: _buildBottomNavigationBar(currentIndex),
            );
          },
        );
      },
    );
  }

  Widget _buildInitialSkeleton() {
    return Skeletonizer(
      child: ListView(
        padding: const EdgeInsets.all(20).rt,
        children: [
          Container(
            height: 48.rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              borderRadius: BorderRadius.circular(16).rt,
            ),
          ),
          20.verticalGap,
          Container(
            height: 160.rt,
            decoration: BoxDecoration(
              color: Get.cardColor,
              borderRadius: BorderRadius.circular(20).rt,
            ),
          ),
          20.verticalGap,
          Row(
            children: List.generate(
              2,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 1 ? 0 : 10.rt),
                  child: Container(
                    height: 120.rt,
                    decoration: BoxDecoration(
                      color: Get.cardColor,
                      borderRadius: BorderRadius.circular(18).rt,
                    ),
                  ),
                ),
              ),
            ),
          ),
          20.verticalGap,
          Column(
            children: List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 12.rt),
                child: Container(
                  height: 80.rt,
                  decoration: BoxDecoration(
                    color: Get.cardColor,
                    borderRadius: BorderRadius.circular(16).rt,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Get.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.rt, vertical: 4.rt),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, icon: Icons.home_rounded, label: 'home', currentIndex: currentIndex),
              _buildNavItem(
                index: 1,
                icon: Icons.store_rounded,
                label: 'market',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.support_agent_rounded,
                label: 'support',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'account',
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required int currentIndex,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _currentIndex.value = index;
          _saveTabIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.rt, vertical: 6.rt),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16).rt,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20.st,
                color: isActive
                    ? AppColors.white
                    : Get.disabledColor.withValues(alpha: 0.5),
              ),
              2.verticalGap,
              AppText(
                label.tr(context),
                style: Get.bodySmall.px10.w600.copyWith(
                  color: isActive
                      ? AppColors.white
                      : Get.disabledColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
