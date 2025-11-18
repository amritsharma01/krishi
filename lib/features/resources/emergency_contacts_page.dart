import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
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
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _contactTypes.entries.map((entry) {
            final isSelected = _selectedType == entry.key;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: FilterChip(
                label: AppText(
                  entry.value,
                  style: Get.bodySmall.copyWith(
                    color: isSelected ? Colors.white : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = entry.key;
                  });
                  _loadContacts(contactType: entry.key);
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20).rt,
                  side: BorderSide(
                    color: isSelected ? Colors.red.shade700 : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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

  Widget _buildContactCard(Contact contact) {
    final color = _contactColors[contact.contactType] ?? Colors.grey;
    final icon = _contactIcons[contact.contactType] ?? Icons.phone_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.rt),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.rt),
                topRight: Radius.circular(16.rt),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.rt),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28.st),
                ),
                16.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        contact.title,
                        style: Get.bodyLarge.w700.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      6.verticalGap,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6).rt,
                        ),
                        child: AppText(
                          contact.contactTypeDisplay.toUpperCase(),
                          style: Get.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                AppText(
                  contact.description,
                  style: Get.bodyMedium.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                16.verticalGap,

                // Phone Number
                Container(
                  padding: EdgeInsets.all(12.rt),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10).rt,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        color: color,
                        size: 20.st,
                      ),
                      12.horizontalGap,
                      Expanded(
                        child: AppText(
                          contact.phoneNumber,
                          style: Get.bodyLarge.w700.copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                ),
                12.verticalGap,

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.rt),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6).rt,
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 16.st,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    10.horizontalGap,
                    Expanded(
                      child: AppText(
                        contact.address,
                        style: Get.bodyMedium.copyWith(
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (contact.email.isNotEmpty) ...[
                  12.verticalGap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.rt),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6).rt,
                        ),
                        child: Icon(
                          Icons.email_rounded,
                          size: 16.st,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      10.horizontalGap,
                      Expanded(
                        child: AppText(
                          contact.email,
                          style: Get.bodyMedium.copyWith(
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                20.verticalGap,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade600, Colors.green.shade700],
                          ),
                          borderRadius: BorderRadius.circular(10).rt,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _makePhoneCall(contact.phoneNumber),
                            borderRadius: BorderRadius.circular(10).rt,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    color: Colors.white,
                                    size: 22.st,
                                  ),
                                  10.horizontalGap,
                                  AppText(
                                    'Call Now',
                                    style: Get.bodyLarge.w600.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (contact.email.isNotEmpty) ...[
                      16.horizontalGap,
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade700],
                            ),
                            borderRadius: BorderRadius.circular(10).rt,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _sendEmail(contact.email),
                              borderRadius: BorderRadius.circular(10).rt,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      color: Colors.white,
                                      size: 22.st,
                                    ),
                                    10.horizontalGap,
                                    AppText(
                                      'Email',
                                      style: Get.bodyLarge.w600.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
