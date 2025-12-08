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
import 'package:krishi/features/resources/widgets/filter_pill.dart';
import 'package:krishi/features/support/providers/contact_us_providers.dart';
import 'package:krishi/models/resources.dart';

class ContactUsFilter extends ConsumerWidget {
  final Map<String, String> contactTypes;
  final Map<String, IconData> contactIcons;
  final Map<String, Color> contactColors;
  final Function(String) onFilterSelected;

  const ContactUsFilter({
    super.key,
    required this.contactTypes,
    required this.contactIcons,
    required this.contactColors,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedContactUsTypeProvider);

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
            final color = contactColors[entry.key] ?? AppColors.primary;
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
                onTap: () => onFilterSelected(entry.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ContactUsList extends ConsumerWidget {
  final Future<void> Function(String?) onRefresh;
  final Map<String, Color> contactColors;
  final Map<String, IconData> contactIcons;
  final Future<void> Function(BuildContext, String) onMakePhoneCall;
  final Future<void> Function(BuildContext, String) onSendEmail;

  const ContactUsList({
    super.key,
    required this.onRefresh,
    required this.contactColors,
    required this.contactIcons,
    required this.onMakePhoneCall,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedContactUsTypeProvider);
    final contactsAsync = ref.watch(contactUsListProvider(selectedType == 'all' ? null : selectedType));

    return contactsAsync.when(
      data: (contactsList) {
        if (contactsList.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.contacts_rounded,
            title: 'no_contacts_available'.tr(context),
            subtitle: 'check_back_later'.tr(context),
          );
        }
        return RefreshIndicator(
          onRefresh: () => onRefresh(selectedType),
          child: ListView.builder(
            padding: EdgeInsets.all(16.rt),
            itemCount: contactsList.length,
            itemBuilder: (context, index) {
              final contact = contactsList[index];
              return ContactUsCard(
                contact: contact,
                contactColors: contactColors,
                contactIcons: contactIcons,
                onMakePhoneCall: onMakePhoneCall,
                onSendEmail: onSendEmail,
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      error: (error, stack) => EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'error_loading_contacts'.tr(context),
        subtitle: error.toString(),
      ),
    );
  }
}

class ContactUsCard extends StatelessWidget {
  final Contact contact;
  final Map<String, Color> contactColors;
  final Map<String, IconData> contactIcons;
  final Future<void> Function(BuildContext, String) onMakePhoneCall;
  final Future<void> Function(BuildContext, String) onSendEmail;

  const ContactUsCard({
    super.key,
    required this.contact,
    required this.contactColors,
    required this.contactIcons,
    required this.onMakePhoneCall,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final color = contactColors[contact.contactType] ?? AppColors.primary;
    final icon = contactIcons[contact.contactType] ?? Icons.phone_rounded;

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
                          horizontal: 10.wt,
                          vertical: 4.ht,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8).rt,
                        ),
                        child: AppText(
                          contact.contactTypeDisplay,
                          style: Get.bodySmall.px12.w600.copyWith(color: color),
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
            if (contact.address.isNotEmpty) ...[
              12.verticalGap,
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.st,
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                  8.horizontalGap,
                  Expanded(
                    child: AppText(
                      contact.address,
                      style: Get.bodySmall.px13.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            20.verticalGap,
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ContactUsButton(
                        icon: Icons.phone_rounded,
                        label: 'call'.tr(context),
                        color: Colors.green,
                        onTap: () => onMakePhoneCall(context, contact.phoneNumber),
                      ),
                    ),
                  ],
                ),
                if (contact.email.isNotEmpty) ...[
                  12.verticalGap,
                  SizedBox(
                    width: double.infinity,
                    child: ContactUsButton(
                      icon: Icons.email_rounded,
                      label: 'email'.tr(context),
                      color: Colors.blue,
                      onTap: () => onSendEmail(context, contact.email),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ContactUsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ContactUsButton({
    super.key,
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
          padding: EdgeInsets.symmetric(vertical: 12.rt, horizontal: 8.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.st, color: color),
              6.horizontalGap,
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

