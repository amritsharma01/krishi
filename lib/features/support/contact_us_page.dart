import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
  List<Contact> _contacts = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<String> _selectedType = ValueNotifier('all');

  Map<String, String> _getContactTypes(BuildContext context) {
    return {
      'all': 'all_contacts'.tr(context),
      'support': 'support'.tr(context),
      'technical': 'technical'.tr(context),
      'sales': 'sales'.tr(context),
      'general': 'general_contact'.tr(context),
    };
  }

  final Map<String, IconData> _contactIcons = {
    'support': Icons.support_agent_rounded,
    'technical': Icons.engineering_rounded,
    'sales': Icons.shopping_cart_rounded,
    'general': Icons.info_rounded,
  };

  final Map<String, Color> _contactColors = {
    'support': Colors.blue,
    'technical': Colors.purple,
    'sales': Colors.green,
    'general': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _selectedType.dispose();
    super.dispose();
  }

  Future<void> _loadContacts({String? contactType}) async {
    _isLoading.value = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final contacts = await apiService.getContacts(
        contactType: contactType == 'all' ? null : contactType,
      );
      if (mounted) {
        _contacts = contacts;
        _isLoading.value = false;
      }
    } catch (e) {
      if (mounted) {
        _isLoading.value = false;
        Get.snackbar('error_loading_products'.tr(context));
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        Get.snackbar('could_not_make_call'.tr(context));
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      Get.snackbar('no_email_available'.tr(context));
      return;
    }
    try {
      final uri = Uri.parse('mailto:$email');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        Get.snackbar('could_not_send_email'.tr(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'contact_us'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          _buildTypeFilter(context),
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
                    : _contacts.isEmpty
                        ? _buildEmptyState(context)
                        : _buildContactsList(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    final contactTypes = _getContactTypes(context);
    return ValueListenableBuilder<String>(
      valueListenable: _selectedType,
      builder: (context, selectedType, _) {
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
            final color = _contactColors[entry.key] ?? AppColors.primary;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : _contactIcons[entry.key] ?? Icons.phone_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 8.wt),
              child: _buildFilterPill(
                label: entry.value,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () {
                  _selectedType.value = entry.key;
                  _loadContacts(contactType: entry.key);
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
            color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
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
            Icons.contacts_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'no_contacts_available'.tr(context),
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

  Widget _buildContactsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadContacts(contactType: _selectedType.value),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return _buildContactCard(context, contact);
        },
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Contact contact) {
    final color = _contactColors[contact.contactType] ?? AppColors.primary;
    final icon = _contactIcons[contact.contactType] ?? Icons.phone_rounded;

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
            // Contact Actions
            Column(
              children: [
                // Call button
                Row(
                  children: [
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.phone_rounded,
                        label: 'call'.tr(context),
                        color: Colors.green,
                        onTap: () => _makePhoneCall(context, contact.phoneNumber),
                      ),
                    ),
                  ],
                ),
                // Email button below if available
                if (contact.email.isNotEmpty) ...[
                  12.verticalGap,
                  SizedBox(
                    width: double.infinity,
                    child: _buildContactButton(
                      icon: Icons.email_rounded,
                      label: 'email'.tr(context),
                      color: Colors.blue,
                      onTap: () => _sendEmail(context, contact.email),
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

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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

