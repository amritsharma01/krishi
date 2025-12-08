import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/emergency_contacts_providers.dart';
import 'package:krishi/features/resources/widgets/filter_pill.dart';
import 'package:krishi/models/resources.dart';

class EmergencyContactsFilter extends ConsumerWidget {
  final Map<String, String> contactTypes;
  final Map<String, IconData> contactIcons;
  final Map<String, Color> contactColors;
  final Future<void> Function(String?) onFilterChanged;

  const EmergencyContactsFilter({
    super.key,
    required this.contactTypes,
    required this.contactIcons,
    required this.contactColors,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedContactTypeProvider);

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
          children: contactTypes.entries.map((entry) {
            final isSelected = selectedType == entry.key;
            final color = contactColors[entry.key] ?? Colors.red;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : contactIcons[entry.key] ?? Icons.phone_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedContactTypeProvider.notifier).state =
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

class ContactCard extends StatelessWidget {
  final Contact contact;
  final Color color;
  final IconData icon;
  final VoidCallback onCall;
  final VoidCallback? onEmail;

  const ContactCard({
    super.key,
    required this.contact,
    required this.color,
    required this.icon,
    required this.onCall,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
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
                          contact.title,
                          style: Get.bodyLarge.px18.w700.copyWith(
                            color: Get.disabledColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        6.verticalGap,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.rt,
                            vertical: 4.rt,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8).rt,
                          ),
                          child: AppText(
                            contact.contactTypeDisplay,
                            style: Get.bodySmall.px11.w600.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (contact.description.isNotEmpty) ...[
                16.verticalGap,
                AppText(
                  contact.description,
                  style: Get.bodyMedium.px14.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              20.verticalGap,
              Wrap(
                spacing: 8.rt,
                runSpacing: 8.rt,
                children: [
                  _InfoPill(
                    icon: Icons.phone_rounded,
                    text: contact.phoneNumber,
                  ),
                  if (contact.address.isNotEmpty)
                    _InfoPill(
                      icon: Icons.location_on_rounded,
                      text: contact.address,
                    ),
                ],
              ),
              if (contact.email.isNotEmpty) ...[
                8.verticalGap,
                _InfoPill(icon: Icons.email_rounded, text: contact.email),
              ],
              20.verticalGap,
              Row(
                children: [
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.phone_rounded,
                      label: 'call'.tr(context),
                      color: color,
                      onTap: onCall,
                    ),
                  ),
                  if (onEmail != null) ...[
                    12.horizontalGap,
                    Expanded(
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
              style: Get.bodySmall.px12.w600.copyWith(color: Get.disabledColor),
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
          padding: EdgeInsets.symmetric(vertical: 12.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.st, color: color),
              8.horizontalGap,
              Flexible(
                child: AppText(
                  label,
                  style: Get.bodyMedium.px14.w600.copyWith(color: color),
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
