import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  final Map<String, String> _contactTypes = {
    'all': 'All Contacts',
    'emergency': 'Emergency',
    'support': 'Support',
    'technical': 'Technical',
    'sales': 'Sales',
    'general': 'General',
  };

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
        Get.snackbar('Failed to load contacts: $e');
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Could not make phone call');
    }
  }

  Future<void> _sendEmail(String email) async {
    if (email.isEmpty) {
      Get.snackbar('No email available');
      return;
    }
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Could not send email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'Emergency Contacts',
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTypeFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? _buildEmptyState()
                    : _buildContactsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: 14.h,
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
              Icon(Icons.settings_input_component_rounded,
                  color: Colors.red.shade600, size: 20.st),
              8.horizontalGap,
              AppText(
                'Quick filters',
                style: Get.bodyMedium.w600.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          12.verticalGap,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _contactTypes.entries.map((entry) {
                final isSelected = _selectedType == entry.key;
                final color = _contactColors[entry.key] ?? Colors.red;
                final icon = entry.key == 'all'
                    ? Icons.all_inclusive
                    : _contactIcons[entry.key] ?? Icons.phone_rounded;
                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
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

  Widget _buildEmptyState() {
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
            'No contacts available',
            style: Get.bodyLarge.px18.w600.copyWith(color: Colors.grey.shade600),
          ),
          8.verticalGap,
          AppText(
            'Check back later',
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return RefreshIndicator(
      onRefresh: () => _loadContacts(contactType: _selectedType),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return _buildContactCard(contact);
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.85)],
                )
              : null,
          color: isSelected ? null : Get.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24).rt,
          border: Border.all(
            color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
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
            Icon(
              icon,
              size: 16.st,
              color: isSelected ? Colors.white : color,
            ),
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

  Widget _buildBadge({required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30).rt,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.st, color: Colors.white),
          6.horizontalGap,
          AppText(
            label.toUpperCase(),
            style: Get.bodySmall.w700.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12).rt,
          ),
          child: Icon(icon, size: 18.st, color: color),
        ),
        12.horizontalGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                style: Get.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
              4.verticalGap,
              AppText(
                value,
                style: Get.bodyMedium.w600.copyWith(
                  color: Get.disabledColor,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.rt),
        decoration: BoxDecoration(
          color: Get.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(18).rt,
          border: Border.all(color: Get.disabledColor.withValues(alpha: 0.1)),
        ),
        child: content,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.st, color: color),
            8.horizontalGap,
            AppText(
              label,
              style: Get.bodyMedium.w600.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    final color = _contactColors[contact.contactType] ?? Colors.grey;
    final icon = _contactIcons[contact.contactType] ?? Icons.phone_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(22).rt,
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(18.rt),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
              ),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(22),
              ).rt,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14.rt),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28.st),
                ),
                18.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        contact.title,
                        style: Get.bodyLarge.px20.w700.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      10.verticalGap,
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          _buildBadge(
                            label: contact.contactTypeDisplay,
                            icon: icon,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  contact.description,
                  style: Get.bodyMedium.copyWith(
                    color: Get.disabledColor,
                    height: 1.5,
                  ),
                ),
                16.verticalGap,
                _buildInfoTile(
                  icon: Icons.phone_in_talk_rounded,
                  color: color,
                  label: 'Helpline',
                  value: contact.phoneNumber,
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20).rt,
                    ),
                    child: AppText(
                      'Tap to call',
                      style: Get.bodySmall.w600.copyWith(color: color),
                    ),
                  ),
                  onTap: () => _makePhoneCall(contact.phoneNumber),
                ),
                12.verticalGap,
                _buildInfoTile(
                  icon: Icons.location_on_rounded,
                  color: Colors.red.shade400,
                  label: 'Address',
                  value: contact.address,
                ),
                if (contact.email.isNotEmpty) ...[
                  12.verticalGap,
                  _buildInfoTile(
                    icon: Icons.email_rounded,
                    color: Colors.orange.shade400,
                    label: 'Email',
                    value: contact.email,
                    onTap: () => _sendEmail(contact.email),
                  ),
                ],
                18.verticalGap,
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    _buildActionButton(
                      label: 'Call',
                      icon: Icons.phone_rounded,
                      color: color,
                      onTap: () => _makePhoneCall(contact.phoneNumber),
                    ),
                    if (contact.email.isNotEmpty)
                      _buildActionButton(
                        label: 'Email',
                        icon: Icons.email_rounded,
                        color: Colors.orange,
                        onTap: () => _sendEmail(contact.email),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
