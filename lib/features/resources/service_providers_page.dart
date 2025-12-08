import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/service_providers_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/service_providers_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceProvidersPage extends ConsumerStatefulWidget {
  const ServiceProvidersPage({super.key});

  @override
  ConsumerState<ServiceProvidersPage> createState() =>
      _ServiceProvidersPageState();
}

class _ServiceProvidersPageState extends ConsumerState<ServiceProvidersPage> {
  Map<String, String> _getServiceTypes(BuildContext context) {
    return {
      'all': 'all_services'.tr(context),
      'seeds': 'seeds'.tr(context),
      'fertilizer': 'fertilizer'.tr(context),
      'pesticide': 'pesticide'.tr(context),
      'equipment': 'equipment'.tr(context),
      'veterinary': 'veterinary'.tr(context),
      'transport': 'transport'.tr(context),
      'other': 'other'.tr(context),
    };
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviders();
    });
  }

  Future<void> _loadProviders({String? serviceType}) async {
    if (!mounted) return;

    final selectedType = serviceType ?? ref.read(selectedServiceTypeProvider);
    ref.read(isLoadingServiceProvidersProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final providers = await apiService.getServiceProviders(
        serviceType: selectedType == 'all' ? null : selectedType,
      );

      if (!mounted) return;

      ref.read(serviceProvidersListProvider.notifier).state = providers;
      ref.read(isLoadingServiceProvidersProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingServiceProvidersProvider.notifier).state = false;
      Get.snackbar('error_loading_products'.tr(context));
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
    final isLoading = ref.watch(isLoadingServiceProvidersProvider);
    final providers = ref.watch(serviceProvidersListProvider);
    final hasProviders = providers.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'service_providers'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          ServiceProvidersFilter(
            serviceTypes: _getServiceTypes(context),
            serviceIcons: _serviceIcons,
            serviceColors: _serviceColors,
            onFilterChanged: (serviceType) =>
                _loadProviders(serviceType: serviceType),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : hasProviders
                ? _buildProvidersList(context)
                : EmptyStateWidget(
                    icon: Icons.store_rounded,
                    title: 'no_service_providers_available'.tr(context),
                    subtitle: 'check_back_later'.tr(context),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersList(BuildContext context) {
    final providers = ref.watch(serviceProvidersListProvider);
    final selectedType = ref.watch(selectedServiceTypeProvider);

    return RefreshIndicator(
      onRefresh: () => _loadProviders(serviceType: selectedType),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final provider = providers[index];
          final color =
              _serviceColors[provider.serviceType] ?? AppColors.primary;
          final icon =
              _serviceIcons[provider.serviceType] ?? Icons.business_rounded;
          return ServiceProviderCard(
            provider: provider,
            color: color,
            icon: icon,
            onCall: () => _makePhoneCall(context, provider.phoneNumber),
            onAltCall: provider.alternatePhone.isNotEmpty
                ? () => _makePhoneCall(context, provider.alternatePhone)
                : null,
            onEmail: provider.email.isNotEmpty
                ? () => _sendEmail(context, provider.email)
                : null,
          );
        },
      ),
    );
  }
}
