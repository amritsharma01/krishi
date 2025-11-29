import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:krishi/features/support/user_manual_detail_page.dart';

class UserGuidePage extends ConsumerStatefulWidget {
  const UserGuidePage({super.key});

  @override
  ConsumerState<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends ConsumerState<UserGuidePage> {
  List<UserManual> _manuals = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<String> _selectedCategory = ValueNotifier('all');

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
    _loadManuals();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  Future<void> _loadManuals({String? category}) async {
    _isLoading.value = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final manuals = await apiService.getUserManuals(
        category: category == 'all' ? null : category,
      );
      if (mounted) {
        _manuals = manuals;
        _isLoading.value = false;
      }
    } catch (e) {
      if (mounted) {
        _isLoading.value = false;
        Get.snackbar('error_loading_products'.tr(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _buildCategoryFilter(context),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isLoading,
              builder: (context, isLoading, _) {
                return isLoading
                    ? Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : _manuals.isEmpty
                    ? _buildEmptyState(context)
                    : _buildManualsList(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = _getCategories(context);
    return ValueListenableBuilder<String>(
      valueListenable: _selectedCategory,
      builder: (context, selectedCategory, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 12.ht),
          decoration: BoxDecoration(
            color: Get.cardColor,
            borderRadius: BorderRadius.vertical(
              bottom: const Radius.circular(28),
            ).rt,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.entries.map((entry) {
                final isSelected = selectedCategory == entry.key;
                final color = _categoryColors[entry.key] ?? AppColors.primary;
                final icon = entry.key == 'all'
                    ? Icons.all_inclusive
                    : _categoryIcons[entry.key] ?? Icons.help_outline_rounded;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _buildFilterPill(
                    label: entry.value,
                    icon: icon,
                    color: color,
                    isSelected: isSelected,
                    onTap: () {
                      _selectedCategory.value = entry.key;
                      _loadManuals(category: entry.key);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.wt, vertical: 6.ht),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.st, color: isSelected ? Colors.white : color),
            6.horizontalGap,
            AppText(
              label,
              style: Get.bodySmall.px12.w600.copyWith(
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'no_manuals_available'.tr(context),
            style: Get.bodyLarge.px18.w600.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          8.verticalGap,
          AppText(
            'check_back_later'.tr(context),
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildManualsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadManuals(category: _selectedCategory.value),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _manuals.length,
        itemBuilder: (context, index) {
          final manual = _manuals[index];
          return _buildManualCard(context, manual);
        },
      ),
    );
  }

  Widget _buildManualCard(BuildContext context, UserManual manual) {
    final color = _categoryColors[manual.category] ?? AppColors.primary;
    final icon = _categoryIcons[manual.category] ?? Icons.help_outline_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20).rt,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserManualDetailPage(manual: manual),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20).rt,
          child: Padding(
            padding: EdgeInsets.all(20.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.rt),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14).rt,
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Icon(icon, color: color, size: 28.st),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            manual.title,
                            style: Get.bodyLarge.px18.w700.copyWith(
                              color: Get.disabledColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          6.verticalGap,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.wt,
                              vertical: 4.ht,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8).rt,
                            ),
                            child: AppText(
                              manual.categoryDisplay,
                              style: Get.bodySmall.px12.w600.copyWith(
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (manual.image != null && manual.image!.isNotEmpty) ...[
                  16.verticalGap,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12).rt,
                    child: CachedNetworkImage(
                      imageUrl: Get.imageUrl(manual.image!),
                      width: double.infinity,
                      height: 160.ht,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 160.ht,
                        color: Get.cardColor.withValues(alpha: 0.3),
                        child: const Center(child: CircularProgressIndicator.adaptive()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 160.ht,
                        color: Get.cardColor.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Get.disabledColor,
                          size: 32.st,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
