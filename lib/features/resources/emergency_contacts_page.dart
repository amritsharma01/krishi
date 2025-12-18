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
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

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
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContacts();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts({String? contactType, bool force = false}) async {
    if (!mounted) return;

    final selectedType = contactType ?? ref.read(selectedContactTypeProvider);

    // Reset if contact type changed or force refresh
    if (contactType != null || force) {
      _hasLoaded = false;
    }

    if (!force &&
        _hasLoaded &&
        ref.read(emergencyContactsListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingEmergencyContactsProvider.notifier).state = true;
    ref.read(emergencyContactsCurrentPageProvider.notifier).state = 1;
    ref.read(emergencyContactsHasMoreProvider.notifier).state = true;
    ref.read(emergencyContactsListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getContacts(
        contactType: selectedType == 'all' ? null : selectedType,
        page: 1,
        pageSize: 10,
      );

      if (!mounted) return;

      ref.read(emergencyContactsListProvider.notifier).state = response.results;
      ref.read(isLoadingEmergencyContactsProvider.notifier).state = false;
      ref.read(emergencyContactsHasMoreProvider.notifier).state =
          response.next != null;
      ref.read(emergencyContactsCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingEmergencyContactsProvider.notifier).state = false;
      Get.snackbar('error_loading_products'.tr(context));
    }
  }

  Future<void> _loadMoreContacts() async {
    final isLoading = ref.read(isLoadingMoreEmergencyContactsProvider);
    final hasMore = ref.read(emergencyContactsHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreEmergencyContactsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(emergencyContactsCurrentPageProvider);
      final selectedType = ref.read(selectedContactTypeProvider);

      final response = await apiService.getContacts(
        contactType: selectedType == 'all' ? null : selectedType,
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentContacts = ref.read(emergencyContactsListProvider);
      ref.read(emergencyContactsListProvider.notifier).state = [
        ...currentContacts,
        ...response.results,
      ];
      ref.read(emergencyContactsHasMoreProvider.notifier).state =
          response.next != null;
      ref.read(emergencyContactsCurrentPageProvider.notifier).state =
          currentPage + 1;
      ref.read(isLoadingMoreEmergencyContactsProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreEmergencyContactsProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreEmergencyContactsProvider);
    final hasMore = ref.read(emergencyContactsHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreContacts();
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
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      Get.snackbar('no_email_available'.tr(context));
      return;
    }
    try {
      final uri = Uri.parse('mailto:$trimmedEmail');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        Get.snackbar('could_not_send_email'.tr(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingEmergencyContactsProvider);
    final contacts = ref.watch(emergencyContactsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreEmergencyContactsProvider);
    final hasContacts = contacts.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'emergency_contacts'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.cardColor,
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
                _loadContacts(contactType: contactType, force: true),
          ),
          Expanded(
            child: isLoading && contacts.isEmpty
                ? Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : !hasContacts
                ? EmptyStateWidget(
                    icon: Icons.contacts_rounded,
                    title: 'no_contacts_available'.tr(context),
                    subtitle: 'check_back_later'.tr(context),
                  )
                : _buildContactsList(context, isLoadingMore),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(BuildContext context, bool isLoadingMore) {
    final contacts = ref.watch(emergencyContactsListProvider);
    final selectedType = ref.watch(selectedContactTypeProvider);

    return RefreshIndicator(
      onRefresh: () => _loadContacts(contactType: selectedType, force: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(6),
        itemCount: contacts.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == contacts.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }
          final contact = contacts[index];
          final icon =
              _contactIcons[contact.contactType] ?? Icons.phone_rounded;
          return ContactCard(
            contact: contact,
            icon: icon,
            onCall: () => _makePhoneCall(context, contact.phoneNumber),
            onEmail: contact.email.trim().isNotEmpty
                ? () => _sendEmail(context, contact.email)
                : null,
          );
        },
      ),
    );
  }
}
