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

class ServiceProvidersPage extends ConsumerStatefulWidget {
  const ServiceProvidersPage({super.key});

  @override
  ConsumerState<ServiceProvidersPage> createState() => _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends ConsumerState<ServiceProvidersPage> {
  List<ServiceProvider> _providers = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  final Map<String, String> _serviceTypes = {
    'all': 'All Services',
    'seeds': 'Seeds',
    'fertilizer': 'Fertilizer',
    'pesticide': 'Pesticide',
    'equipment': 'Equipment',
    'veterinary': 'Veterinary',
    'transport': 'Transport',
    'other': 'Other',
  };

  final Map<String, IconData> _serviceIcons = {
    'seeds': Icons.spa_rounded,
    'fertilizer': Icons.science_rounded,
    'pesticide': Icons.pest_control_rounded,
    'equipment': Icons.build_rounded,
    'veterinary': Icons.pets_rounded,
    'transport': Icons.local_shipping_rounded,
    'other': Icons.business_rounded,
  };

  final Map<String, Color> _serviceColors = {
    'seeds': Colors.green,
    'fertilizer': Colors.brown,
    'pesticide': Colors.orange,
    'equipment': Colors.blue,
    'veterinary': Colors.purple,
    'transport': Colors.indigo,
    'other': Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders({String? serviceType}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final providers = await apiService.getServiceProviders(
        serviceType: serviceType == 'all' ? null : serviceType,
      );
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar('Failed to load service providers: $e');
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
          'Service Providers',
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTypeFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _providers.isEmpty
                    ? _buildEmptyState()
                    : _buildProvidersList(),
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
              Icon(Icons.tune_rounded, color: Colors.teal.shade600, size: 20.st),
              8.horizontalGap,
              AppText(
                'Filter services',
                style: Get.bodyMedium.w600.copyWith(
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          12.verticalGap,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _serviceTypes.entries.map((entry) {
                final isSelected = _selectedType == entry.key;
                final color = _serviceColors[entry.key] ?? Colors.teal;
                final icon = entry.key == 'all'
                    ? Icons.all_inclusive
                    : _serviceIcons[entry.key] ?? Icons.business_rounded;
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
                      _loadProviders(serviceType: entry.key);
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
            Icons.store_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'No service providers available',
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

  Widget _buildProvidersList() {
    return RefreshIndicator(
      onRefresh: () => _loadProviders(serviceType: _selectedType),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _providers.length,
        itemBuilder: (context, index) {
          final provider = _providers[index];
          return _buildProviderCard(provider);
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
                  colors: [color, color.withValues(alpha: 0.8)],
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

  Widget _buildProviderCard(ServiceProvider provider) {
    final color = _serviceColors[provider.serviceType] ?? Colors.teal;
    final icon = _serviceIcons[provider.serviceType] ?? Icons.business_rounded;

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(22).rt,
        border: Border.all(color: color.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(14.rt),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18).rt,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28.st),
                ),
                16.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        provider.businessName,
                        style: Get.bodyLarge.px20.w700.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.verticalGap,
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          _buildBadge(
                            text: provider.serviceTypeDisplay,
                            icon: icon,
                          ),
                          if (provider.deliveryAvailable)
                            _buildBadge(
                              text: 'Delivery Available',
                              icon: Icons.local_shipping_rounded,
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
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  label: 'Contact Person',
                  value: provider.contactPerson,
                  color: Colors.blue,
                ),
                12.verticalGap,
                _buildInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Address',
                  value: provider.address,
                  color: Colors.red,
                ),
                12.verticalGap,
                Container(
                  padding: EdgeInsets.all(14.rt),
                  decoration: BoxDecoration(
                    color: Get.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16).rt,
                    border: Border.all(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: AppText(
                    provider.description,
                    style: Get.bodyMedium.copyWith(
                      color: Get.disabledColor,
                      height: 1.5,
                    ),
                  ),
                ),
                16.verticalGap,
                Container(
                  padding: EdgeInsets.all(12.rt),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14).rt,
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.currency_rupee_rounded,
                        size: 18.st,
                        color: color,
                      ),
                      10.horizontalGap,
                      Expanded(
                        child: AppText(
                          provider.priceRange,
                          style: Get.bodyMedium.w700.copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                ),
                18.verticalGap,
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    _buildActionButton(
                      icon: Icons.phone_in_talk_rounded,
                      label: 'Call',
                      color: Colors.green,
                      onTap: () => _makePhoneCall(provider.phoneNumber),
                    ),
                    if (provider.alternatePhone.isNotEmpty)
                      _buildActionButton(
                        icon: Icons.phone_forwarded_rounded,
                        label: 'Alt. Call',
                        color: Colors.blue,
                        onTap: () => _makePhoneCall(provider.alternatePhone),
                      ),
                    if (provider.email.isNotEmpty)
                      _buildActionButton(
                        icon: Icons.email_rounded,
                        label: 'Email',
                        color: Colors.orange,
                        onTap: () => _sendEmail(provider.email),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.rt),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.rt),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 16.st, color: color),
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
                    fontSize: 11.sp,
                  ),
                ),
                4.verticalGap,
                AppText(
                  value,
                  style: Get.bodyMedium.w600.copyWith(
                    color: Get.disabledColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14).rt,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18.st),
            6.horizontalGap,
            AppText(
              label,
              style: Get.bodySmall.w600.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required String text, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30).rt,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.st, color: Colors.white),
          6.horizontalGap,
          AppText(
            text,
            style: Get.bodySmall.w600.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
