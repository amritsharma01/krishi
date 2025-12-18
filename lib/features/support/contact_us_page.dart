import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/support/providers/contact_us_providers.dart';
import 'package:krishi/features/support/widgets/contact_us_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasLoaded = false;

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

    final selectedType = contactType ?? ref.read(selectedContactUsTypeProvider);

    // Reset if contact type changed or force refresh
    if (contactType != null || force) {
      _hasLoaded = false;
    }

    if (!force && _hasLoaded && ref.read(contactUsListProvider).isNotEmpty) {
      return;
    }

    ref.read(isLoadingContactUsProvider.notifier).state = true;
    ref.read(contactUsCurrentPageProvider.notifier).state = 1;
    ref.read(contactUsHasMoreProvider.notifier).state = true;
    ref.read(contactUsListProvider.notifier).state = [];

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final response = await apiService.getContacts(
        contactType: selectedType == 'all' ? null : selectedType,
        page: 1,
        pageSize: 10,
      );

      if (!mounted) return;

      ref.read(contactUsListProvider.notifier).state = response.results;
      ref.read(isLoadingContactUsProvider.notifier).state = false;
      ref.read(contactUsHasMoreProvider.notifier).state = response.next != null;
      ref.read(contactUsCurrentPageProvider.notifier).state = 2;
      _hasLoaded = true;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingContactUsProvider.notifier).state = false;
    }
  }

  Future<void> _loadMoreContacts() async {
    final isLoading = ref.read(isLoadingMoreContactUsProvider);
    final hasMore = ref.read(contactUsHasMoreProvider);

    if (isLoading || !hasMore) return;

    ref.read(isLoadingMoreContactUsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(contactUsCurrentPageProvider);
      final selectedType = ref.read(selectedContactUsTypeProvider);

      final response = await apiService.getContacts(
        contactType: selectedType == 'all' ? null : selectedType,
        page: currentPage,
        pageSize: 10,
      );

      if (!mounted) return;

      final currentContacts = ref.read(contactUsListProvider);
      ref.read(contactUsListProvider.notifier).state = [
        ...currentContacts,
        ...response.results,
      ];
      ref.read(contactUsHasMoreProvider.notifier).state = response.next != null;
      ref.read(contactUsCurrentPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingMoreContactUsProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingMoreContactUsProvider.notifier).state = false;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isLoading = ref.read(isLoadingMoreContactUsProvider);
    final hasMore = ref.read(contactUsHasMoreProvider);

    if (isLoading || !hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreContacts();
    }
  }

  void _onFilterSelected(String contactType) {
    ref.read(selectedContactUsTypeProvider.notifier).state = contactType;
    _loadContacts(contactType: contactType, force: true);
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
    final isLoading = ref.watch(isLoadingContactUsProvider);
    final contacts = ref.watch(contactUsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreContactUsProvider);
    final hasContacts = contacts.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'contact_us'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          ContactUsFilter(
            contactTypes: _getContactTypes(context),
            contactIcons: _contactIcons,
            onFilterSelected: _onFilterSelected,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadContacts(force: true),
              child: isLoading && contacts.isEmpty
                  ? Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Get.primaryColor,
                        ),
                      ),
                    )
                  : !hasContacts
                  ? EmptyStateWidget(
                      icon: Icons.contacts_rounded,
                      title: 'no_contacts_available'.tr(context),
                      subtitle: 'check_back_later'.tr(context),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: contacts.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == contacts.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Get.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }
                        final contact = contacts[index];
                        return ContactUsCard(
                          contact: contact,
                          contactIcons: _contactIcons,
                          onMakePhoneCall: _makePhoneCall,
                          onSendEmail: _sendEmail,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
