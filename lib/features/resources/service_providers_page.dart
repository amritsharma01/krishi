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
          children: _serviceTypes.entries.map((entry) {
            final isSelected = _selectedType == entry.key;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = entry.key;
                  });
                  _loadProviders(serviceType: entry.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal.shade700 : Colors.white,
                    borderRadius: BorderRadius.circular(20).rt,
                    border: Border.all(
                      color: isSelected ? Colors.teal.shade700 : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.teal.shade700.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: AppText(
                    entry.value,
                    style: Get.bodySmall.copyWith(
                      color: isSelected ? Colors.white : Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildProviderCard(ServiceProvider provider) {
    final color = _serviceColors[provider.serviceType] ?? Colors.teal;
    final icon = _serviceIcons[provider.serviceType] ?? Icons.business_rounded;

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    borderRadius: BorderRadius.circular(12).rt,
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
                          provider.serviceTypeDisplay,
                          style: Get.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.deliveryAvailable)
                  Container(
                    padding: EdgeInsets.all(8.rt),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8).rt,
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 20.st,
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
                // Contact Person
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  label: 'Contact Person',
                  value: provider.contactPerson,
                  color: Colors.blue,
                ),
                12.verticalGap,

                // Address
                _buildInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Address',
                  value: provider.address,
                  color: Colors.red,
                ),
                12.verticalGap,

                // Description
                AppText(
                  provider.description,
                  style: Get.bodyMedium.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                12.verticalGap,

                // Price Range
                Container(
                  padding: EdgeInsets.all(12.rt),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8).rt,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.currency_rupee_rounded,
                        size: 18.st,
                        color: color,
                      ),
                      8.horizontalGap,
                      Expanded(
                        child: AppText(
                          provider.priceRange,
                          style: Get.bodyMedium.w600.copyWith(color: color),
                        ),
                      ),
                    ],
                  ),
                ),

                if (provider.deliveryAvailable) ...[
                  12.verticalGap,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8).rt,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16.st,
                          color: Colors.green.shade700,
                        ),
                        8.horizontalGap,
                        AppText(
                          'Delivery Available',
                          style: Get.bodySmall.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                20.verticalGap,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone_rounded,
                        label: 'Call',
                        color: Colors.green,
                        onTap: () => _makePhoneCall(provider.phoneNumber),
                      ),
                    ),
                    if (provider.alternatePhone.isNotEmpty) ...[
                      12.horizontalGap,
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.phone_forwarded_rounded,
                          label: 'Alt. Call',
                          color: Colors.blue,
                          onTap: () => _makePhoneCall(provider.alternatePhone),
                        ),
                      ),
                    ],
                    if (provider.email.isNotEmpty) ...[
                      12.horizontalGap,
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          color: Colors.orange,
                          onTap: () => _sendEmail(provider.email),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6).rt,
          ),
          child: Icon(icon, size: 16.st, color: color),
        ),
        10.horizontalGap,
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
              2.verticalGap,
              AppText(
                value,
                style: Get.bodyMedium.w500,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(10).rt,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10).rt,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18.st),
                6.horizontalGap,
                AppText(
                  label,
                  style: Get.bodySmall.w600.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
