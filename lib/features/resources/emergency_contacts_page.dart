import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/emergency_contacts_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/emergency_contacts_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContacts();
    });
  }

  Future<void> _loadContacts({String? contactType}) async {
    if (!mounted) return;

    final selectedType = contactType ?? ref.read(selectedContactTypeProvider);
    ref.read(isLoadingEmergencyContactsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final contacts = await apiService.getContacts(
        contactType: selectedType == 'all' ? null : selectedType,
      );

      if (!mounted) return;

      ref.read(emergencyContactsListProvider.notifier).state = contacts;
      ref.read(isLoadingEmergencyContactsProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingEmergencyContactsProvider.notifier).state = false;
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
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('could_not_send_email'.tr(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingEmergencyContactsProvider);
    final contacts = ref.watch(emergencyContactsListProvider);
    final hasContacts = contacts.isNotEmpty;

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
          EmergencyContactsFilter(
            contactTypes: _getContactTypes(context),
            contactIcons: _contactIcons,
            contactColors: _contactColors,
            onFilterChanged: (contactType) =>
                _loadContacts(contactType: contactType),
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
                : hasContacts
                ? _buildContactsList(context)
                : EmptyStateWidget(
                    icon: Icons.contacts_rounded,
                    title: 'no_contacts_available'.tr(context),
                    subtitle: 'check_back_later'.tr(context),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(BuildContext context) {
    final contacts = ref.watch(emergencyContactsListProvider);
    final selectedType = ref.watch(selectedContactTypeProvider);

    return RefreshIndicator(
      onRefresh: () => _loadContacts(contactType: selectedType),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final color =
              _contactColors[contact.contactType] ?? AppColors.primary;
          final icon =
              _contactIcons[contact.contactType] ?? Icons.phone_rounded;
          return ContactCard(
            contact: contact,
            color: color,
            icon: icon,
            onCall: () => _makePhoneCall(context, contact.phoneNumber),
            onEmail: contact.email.isNotEmpty
                ? () => _sendEmail(context, contact.email)
                : null,
          );
        },
      ),
    );
  }
}
