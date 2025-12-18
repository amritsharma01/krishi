import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/service_providers_providers.dart';
import 'package:krishi/features/resources/widgets/filter_pill.dart';
import 'package:krishi/models/resources.dart';

class ServiceProvidersFilter extends ConsumerWidget {
  final Map<String, String> serviceTypes;
  final Map<String, IconData> serviceIcons;
  final Map<String, Color> serviceColors;
  final Future<void> Function(String?) onFilterChanged;

  const ServiceProvidersFilter({
    super.key,
    required this.serviceTypes,
    required this.serviceIcons,
    required this.serviceColors,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedServiceTypeProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wt, vertical: 5.ht),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: serviceTypes.entries.map((entry) {
            final isSelected = selectedType == entry.key;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : serviceIcons[entry.key] ?? Icons.business_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 5.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedServiceTypeProvider.notifier).state =
                      entry.key;
                  onFilterChanged(entry.key);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ServiceProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final IconData icon;
  final VoidCallback onCall;
  final VoidCallback? onAltCall;
  final VoidCallback? onEmail;

  const ServiceProviderCard({
    super.key,
    required this.provider,
    required this.icon,
    required this.onCall,
    this.onAltCall,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.rt),
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
        child: Padding(
          padding: EdgeInsets.all(10.rt),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.rt),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14).rt,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 18.st),
                  ),
                  16.horizontalGap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          provider.businessName,
                          style: Get.bodyLarge.px14.w700.copyWith(
                            color: Get.disabledColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        2.verticalGap,
                        AppText(
                          provider.serviceTypeDisplay,
                          style: Get.bodyMedium.px12.w500.copyWith(
                            color: Get.disabledColor.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              Wrap(
                spacing: 8.rt,
                runSpacing: 8.rt,
                children: [
                  _InfoPill(
                    icon: Icons.person_rounded,
                    text: provider.contactPerson,
                  ),
                  if (provider.deliveryAvailable)
                    _InfoPill(
                      icon: Icons.local_shipping_rounded,
                      text: 'delivery_available'.tr(context),
                    ),
                  _InfoPill(
                    icon: Icons.currency_rupee_rounded,
                    text: provider.priceRange,
                  ),
                ],
              ),
              if (provider.description.isNotEmpty) ...[
                Divider(),
                AppText(
                  provider.description,
                  style: Get.bodyMedium.px10.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Divider(),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ContactButton(
                          icon: Icons.phone_rounded,
                          label: 'call'.tr(context),
                          color: Colors.green,
                          onTap: onCall,
                        ),
                      ),
                      if (onAltCall != null) ...[
                        6.horizontalGap,
                        Expanded(
                          child: _ContactButton(
                            icon: Icons.phone_forwarded_rounded,
                            label: 'alt_call'.tr(context),
                            color: Colors.blue,
                            onTap: onAltCall!,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (onEmail != null) ...[
                    6.verticalGap,
                    SizedBox(
                      width: double.infinity,
                      child: _ContactButton(
                        icon: Icons.email_rounded,
                        label: 'email'.tr(context),
                        color: Colors.orange,
                        onTap: onEmail!,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.rt, vertical: 8.rt),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.st, color: AppColors.primary),
          6.horizontalGap,
          Flexible(
            child: AppText(
              text,
              style: Get.bodySmall.px10.w600.copyWith(color: Get.disabledColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12).rt,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.rt, horizontal: 8.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14.st, color: color),
              6.horizontalGap,
              Flexible(
                child: AppText(
                  label,
                  style: Get.bodyMedium.px12.w600.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
