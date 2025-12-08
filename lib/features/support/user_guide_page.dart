import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/support/providers/user_guides_providers.dart';
import 'package:krishi/features/support/user_manual_detail_page.dart';
import 'package:krishi/features/support/widgets/user_guide_widgets.dart';
import 'package:krishi/models/resources.dart';

class UserGuidePage extends ConsumerStatefulWidget {
  const UserGuidePage({super.key});

  @override
  ConsumerState<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends ConsumerState<UserGuidePage> {

  Map<String, String> _getCategories(BuildContext context) {
    return {
      'all': 'all_categories'.tr(context),
      'buying': 'buying'.tr(context),
      'selling': 'selling'.tr(context),
      'account': 'account'.tr(context),
      'orders': 'orders'.tr(context),
      'other': 'other'.tr(context),
    };
  }

  final Map<String, IconData> _categoryIcons = {
    'buying': Icons.shopping_cart_rounded,
    'selling': Icons.store_rounded,
    'account': Icons.person_rounded,
    'orders': Icons.receipt_long_rounded,
    'other': Icons.help_outline_rounded,
  };

  final Map<String, Color> _categoryColors = {
    'buying': Colors.blue,
    'selling': Colors.green,
    'account': Colors.purple,
    'orders': Colors.orange,
    'other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadManuals();
    });
  }

  Future<void> _loadManuals({String? category}) async {
    if (!mounted) return;

    final selectedCategory = category ?? ref.read(selectedUserGuideCategoryProvider);
    ref.read(isLoadingUserGuidesProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final manuals = await apiService.getUserManuals(
        category: selectedCategory == 'all' ? null : selectedCategory,
      );

      if (!mounted) return;

      ref.read(userGuidesListProvider.notifier).state = manuals;
      ref.read(isLoadingUserGuidesProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingUserGuidesProvider.notifier).state = false;
      Get.snackbar('error_loading_products'.tr(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingUserGuidesProvider);
    final manuals = ref.watch(userGuidesListProvider);
    final hasManuals = manuals.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'user_guide'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          UserGuideFilter(
            categories: _getCategories(context),
            categoryIcons: _categoryIcons,
            categoryColors: _categoryColors,
            onFilterSelected: (category) {
              ref.read(selectedUserGuideCategoryProvider.notifier).state = category;
              _loadManuals(category: category);
            },
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : hasManuals
                    ? _buildManualsList(context)
                    : EmptyStateWidget(
                        icon: Icons.menu_book_rounded,
                        title: 'no_manuals_available'.tr(context),
                        subtitle: 'check_back_later'.tr(context),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualsList(BuildContext context) {
    final selectedCategory = ref.watch(selectedUserGuideCategoryProvider);

    return UserGuideList(
      onRefresh: (category) => _loadManuals(category: category ?? selectedCategory),
      categoryColors: _categoryColors,
      categoryIcons: _categoryIcons,
      onManualTap: (manual) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserManualDetailPage(manual: manual),
          ),
        );
      },
    );
  }
}
