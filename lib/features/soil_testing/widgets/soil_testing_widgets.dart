import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/soil_testing/providers/soil_testing_providers.dart';
import 'package:krishi/models/resources.dart';

class SoilTestingHeader extends ConsumerWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const SoilTestingHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.wt, vertical: 8.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(20),
        ).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.wt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'soil_testing_centers'.tr(context),
                  style: Get.bodyLarge.px14.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                4.verticalGap,
                AppText(
                  'soil_testing_centers_subtitle'.tr(context),
                  maxLines: 4,
                  style: Get.bodyMedium.px12.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          6.verticalGap,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.wt),
            child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'search_soil_tests'.tr(context),
              prefixIcon: Icon(Icons.search_rounded, color: Get.disabledColor),
              suffixIcon: ref.watch(soilTestsSearchQueryProvider).isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Get.scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16).rt,
                borderSide: BorderSide(
                  color: Get.disabledColor.withValues(alpha: 0.08),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.search,
            ),
          ),
        ],
      ),
    );
  }
}

class SoilTestingList extends ConsumerWidget {
  final ScrollController scrollController;
  final Future<void> Function({bool refresh}) onRefresh;
  final Future<void> Function(String) onMakePhoneCall;
  final Future<void> Function(String) onSendEmail;

  const SoilTestingList({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.onMakePhoneCall,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingSoilTestsProvider);
    final centers = ref.watch(soilTestsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreSoilTestsProvider);
    final hasCenters = centers.isNotEmpty;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (!hasCenters) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: EmptyStateWidget(
          icon: Icons.map_rounded,
          title: 'no_soil_tests'.tr(context),
          subtitle: 'soil_tests_empty_state_subtitle'.tr(context),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: centers.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == centers.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.ht),
            child: Center(
              child: SizedBox(
                height: 24.st,
                width: 24.st,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 12.ht),
          child: SoilTestCard(
            center: centers[index],
            onMakePhoneCall: onMakePhoneCall,
            onSendEmail: onSendEmail,
          ),
        );
      },
    );
  }
}

class SoilTestCard extends StatelessWidget {
  final SoilTest center;
  final Future<void> Function(String) onMakePhoneCall;
  final Future<void> Function(String) onSendEmail;

  const SoilTestCard({
    super.key,
    required this.center,
    required this.onMakePhoneCall,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor =
        Get.bodyLarge.color ?? (Get.isDark ? Colors.white : Colors.black87);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16).rt,
                ),
                child: Icon(Icons.science_outlined, color: AppColors.primary),
              ),
              12.horizontalGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      center.title,
                      style: Get.bodyLarge.px16.w700.copyWith(
                        color: titleColor,
                      ),
                    ),
                    4.verticalGap,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14.st,
                          color: Get.disabledColor.withValues(alpha: 0.7),
                        ),
                        4.horizontalGap,
                        Expanded(
                          child: AppText(
                            center.municipalityName,
                            style: Get.bodySmall.copyWith(
                              color: Get.disabledColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.verticalGap,
          AppText(
            center.description,
            style: Get.bodyMedium.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          16.verticalGap,
          SoilTestDetailRow(
            icon: Icons.person_rounded,
            label: 'contact_person'.tr(context),
            value: center.contactPerson ?? 'not_available'.tr(context),
          ),
          8.verticalGap,
          SoilTestDetailRow(
            icon: Icons.phone_rounded,
            label: 'phone_number'.tr(context),
            value: center.phoneNumber,
            trailing: TextButton(
              onPressed: () => onMakePhoneCall(center.phoneNumber),
              child: AppText(
                'call_now'.tr(context),
                style: Get.bodySmall.w600.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          if (center.email != null && center.email!.isNotEmpty) ...[
            8.verticalGap,
            SoilTestDetailRow(
              icon: Icons.email_rounded,
              label: 'email'.tr(context),
              value: center.email!,
              trailing: IconButton(
                icon: Icon(
                  Icons.open_in_new,
                  color: AppColors.primary,
                  size: 18.st,
                ),
                onPressed: () => onSendEmail(center.email!),
              ),
            ),
          ],
          8.verticalGap,
          SoilTestDetailRow(
            icon: Icons.home_work_rounded,
            label: 'address'.tr(context),
            value: center.address,
          ),
          if (center.cost != null && center.cost!.isNotEmpty) ...[
            8.verticalGap,
            SoilTestDetailRow(
              icon: Icons.paid_rounded,
              label: 'testing_cost'.tr(context),
              value: center.cost!,
            ),
          ],
          if (center.duration != null && center.duration!.isNotEmpty) ...[
            8.verticalGap,
            SoilTestDetailRow(
              icon: Icons.schedule_rounded,
              label: 'duration_label'.tr(context),
              value: center.duration!,
            ),
          ],
          if (center.requirements != null &&
              center.requirements!.isNotEmpty) ...[
            16.verticalGap,
            Container(
              padding: EdgeInsets.all(12.rt),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14).rt,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'requirements_label'.tr(context),
                    style: Get.bodyMedium.w700.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  6.verticalGap,
                  AppText(
                    center.requirements!,
                    style: Get.bodySmall.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SoilTestDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const SoilTestDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Get.disabledColor.withValues(alpha: 0.7),
          size: 18.st,
        ),
        10.horizontalGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                style: Get.bodySmall.px11.w600.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.6),
                ),
              ),
              2.verticalGap,
              AppText(
                value,
                style: Get.bodyMedium.copyWith(color: Get.disabledColor),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
