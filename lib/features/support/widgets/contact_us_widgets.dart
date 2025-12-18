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
  final Function(String) onFilterSelected;

  const ContactUsFilter({
    super.key,
    required this.contactTypes,
    required this.contactIcons,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedContactUsTypeProvider);

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
          children: contactTypes.entries.map((entry) {
            final isSelected = selectedType == entry.key;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : contactIcons[entry.key] ?? Icons.phone_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 5.wt),
              child: FilterPill(
                label: entry.value,
                icon: icon,
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
  final Map<String, IconData> contactIcons;
  final Future<void> Function(BuildContext, String) onMakePhoneCall;
  final Future<void> Function(BuildContext, String) onSendEmail;
  final ScrollController? scrollController;
  final bool isLoadingMore;

  const ContactUsList({
    super.key,
    required this.onRefresh,
    required this.contactIcons,
    required this.onMakePhoneCall,
    required this.onSendEmail,
    this.scrollController,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactUsListProvider);
    final isLoading = ref.watch(isLoadingContactUsProvider);

    if (isLoading && contacts.isEmpty) {
      return Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (contacts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.contacts_rounded,
        title: 'no_contacts_available'.tr(context),
        subtitle: 'check_back_later'.tr(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(ref.read(selectedContactUsTypeProvider)),
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.all(16.rt),
        itemCount: contacts.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == contacts.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.rt),
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }
          final contact = contacts[index];
          return ContactUsCard(
            contact: contact,
            contactIcons: contactIcons,
            onMakePhoneCall: onMakePhoneCall,
            onSendEmail: onSendEmail,
          );
        },
      ),
    );
  }
}

class ContactUsCard extends StatelessWidget {
  final Contact contact;
  final Map<String, IconData> contactIcons;
  final Future<void> Function(BuildContext, String) onMakePhoneCall;
  final Future<void> Function(BuildContext, String) onSendEmail;

  const ContactUsCard({
    super.key,
    required this.contact,
    required this.contactIcons,
    required this.onMakePhoneCall,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final icon = contactIcons[contact.contactType] ?? Icons.phone_rounded;

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
      child: Padding(
        padding: EdgeInsets.all(10.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.rt),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14).rt,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28.st),
                ),
                16.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        contact.title,
                        style: Get.bodyLarge.px14.w700.copyWith(
                          color: Get.disabledColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.verticalGap,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.wt,
                          vertical: 2.ht,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8).rt,
                        ),
                        child: AppText(
                          contact.contactTypeDisplay,
                          style: Get.bodySmall.px10.w600.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (contact.description.isNotEmpty) ...[
              Divider(),
              AppText(
                contact.description,
                style: Get.bodyMedium.px14.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.8),
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Divider(),
            if (contact.address.isNotEmpty) ...[
              6.verticalGap,
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14.st,
                    color: Get.disabledColor.withValues(alpha: 0.7),
                  ),
                  8.horizontalGap,
                  Expanded(
                    child: AppText(
                      contact.address,
                      style: Get.bodySmall.px10.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            8.verticalGap,
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ContactUsButton(
                        icon: Icons.phone_rounded,
                        label: 'call'.tr(context),
                        color: Colors.green,
                        onTap: () =>
                            onMakePhoneCall(context, contact.phoneNumber),
                      ),
                    ),
                  ],
                ),
                if (contact.email.isNotEmpty) ...[
                  4.verticalGap,
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
          padding: EdgeInsets.symmetric(vertical: 10.rt, horizontal: 8.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.st, color: color),
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
