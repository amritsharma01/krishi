import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  Map<String, String> _getContactTypes(BuildContext context) {
    return {
      'all': 'all_contacts'.tr(context),
      'emergency': 'emergency'.tr(context),
      'support': 'support'.tr(context),
      'technical': 'technical'.tr(context),
      'sales': 'sales'.tr(context),
      'general': 'general_contact'.tr(context),
    };
  }

  final Map<String, IconData> _contactIcons = {
    'emergency': Icons.emergency_rounded,
    'support': Icons.support_agent_rounded,
    'technical': Icons.engineering_rounded,
    'sales': Icons.shopping_cart_rounded,
    'general': Icons.info_rounded,
  };

  final Map<String, Color> _contactColors = {
    'emergency': Colors.red,
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

  Future<void> _loadContacts({String? contactType}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final contacts = await apiService.getContacts(
        contactType: contactType == 'all' ? null : contactType,
      );
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar('error_loading_products'.tr(context));
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('could_not_make_call'.tr(context));
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    if (email.isEmpty) {
      Get.snackbar('no_email_available'.tr(context));
      return;
    }
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('could_not_send_email'.tr(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'emergency_contacts'.tr(context),
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
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _contacts.isEmpty
                ? _buildEmptyState(context)
                : _buildContactsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    final contactTypes = _getContactTypes(context);
    return Container(
      padding: EdgeInsets.only(
        left: 16.wt,
        right: 16.wt,
        top: 20.ht,
        bottom: 14.ht,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_input_component_rounded,
                color: Colors.red.shade600,
                size: 20.st,
              ),
              8.horizontalGap,
              AppText(
                'quick_filters'.tr(context),
                style: Get.bodyMedium.w600.copyWith(color: Colors.red.shade700),
              ),
            ],
          ),
          12.verticalGap,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: contactTypes.entries.map((entry) {
                final isSelected = _selectedType == entry.key;
                final color = _contactColors[entry.key] ?? Colors.red;
                final icon = entry.key == 'all'
                    ? Icons.all_inclusive
                    : _contactIcons[entry.key] ?? Icons.phone_rounded;
                return Padding(
                  padding: EdgeInsets.only(right: 10.wt),
                  child: _buildFilterPill(
                    label: entry.value,
                    icon: icon,
                    color: color,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedType = entry.key;
                      });
                      _loadContacts(contactType: entry.key);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
      onRefresh: () => _loadContacts(contactType: _selectedType),
      child: ListView.builder(
        padding: const EdgeInsets.all(16).rt,
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return _buildContactCard(context, contact);
        },
      ),
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
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 16.wt, vertical: 9.ht),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.85)])
              : null,
          color: isSelected ? null : Get.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24).rt,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.st, color: isSelected ? Colors.white : color),
            8.horizontalGap,
            AppText(
              label,
              style: Get.bodySmall.w600.copyWith(
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill({required IconData icon, required String text}) {
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20).rt,
        child: Padding(
          padding: const EdgeInsets.all(20).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12).rt,
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
              // Key Information Pills
              Wrap(
                spacing: 8.rt,
                runSpacing: 8.rt,
                children: [
                  _buildInfoPill(
                    icon: Icons.phone_rounded,
                    text: contact.phoneNumber,
                  ),
                  if (contact.address.isNotEmpty)
                    _buildInfoPill(
                      icon: Icons.location_on_rounded,
                      text: contact.address,
                    ),
                ],
              ),
              if (contact.email.isNotEmpty) ...[
                8.verticalGap,
                _buildInfoPill(icon: Icons.email_rounded, text: contact.email),
              ],
              20.verticalGap,
              // Contact Actions
              Row(
                children: [
                  Expanded(
                    child: _buildContactButton(
                      icon: Icons.phone_rounded,
                      label: 'call'.tr(context),
                      color: color,
                      onTap: () => _makePhoneCall(context, contact.phoneNumber),
                    ),
                  ),
                  if (contact.email.isNotEmpty) ...[
                    12.horizontalGap,
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.email_rounded,
                        label: 'email'.tr(context),
                        color: Colors.orange,
                        onTap: () => _sendEmail(context, contact.email),
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
