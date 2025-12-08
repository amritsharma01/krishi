import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/experts_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/experts_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertsPage extends ConsumerStatefulWidget {
  const ExpertsPage({super.key});

  @override
  ConsumerState<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends ConsumerState<ExpertsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExperts();
    });
  }

  Future<void> _loadExperts() async {
    if (!mounted) return;

    ref.read(isLoadingExpertsProvider.notifier).state = true;

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final experts = await apiService.getExperts();

      if (!mounted) return;

      ref.read(expertsListProvider.notifier).state = experts;
      ref.read(isLoadingExpertsProvider.notifier).state = false;
    } catch (e) {
      if (!mounted) return;
      ref.read(isLoadingExpertsProvider.notifier).state = false;
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

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    try {
      // Remove any spaces or special characters
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Add country code if not present (Nepal country code is +977)
      if (!cleanNumber.startsWith('+') && !cleanNumber.startsWith('977')) {
        cleanNumber = '977$cleanNumber';
      }
      
      // Ensure it starts with + for WhatsApp
      if (!cleanNumber.startsWith('+')) {
        cleanNumber = '+$cleanNumber';
      }
      
      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
      
      // Try multiple launch modes
      try {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        try {
          await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          try {
            await launchUrl(whatsappUri, mode: LaunchMode.inAppWebView);
          } catch (e3) {
            if (mounted) {
              Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('whatsapp_failed'.tr(context), color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingExpertsProvider);
    final experts = ref.watch(expertsListProvider);
    final hasExperts = experts.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'agri_experts'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : hasExperts
              ? _buildExpertsList(context)
              : EmptyStateWidget(
                  icon: Icons.person_search_rounded,
                  title: 'no_experts_available'.tr(context),
                  subtitle: 'check_back_later'.tr(context),
                ),
    );
  }

  Widget _buildExpertsList(BuildContext context) {
    final experts = ref.watch(expertsListProvider);

    return RefreshIndicator(
      onRefresh: _loadExperts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: experts.length,
        itemBuilder: (context, index) {
          final expert = experts[index];
          return ExpertCard(
            expert: expert,
            onCall: () => _makePhoneCall(context, expert.phoneNumber),
            onWhatsApp: () => _openWhatsApp(context, expert.phoneNumber),
            onEmail: expert.email.isNotEmpty
                ? () => _sendEmail(context, expert.email)
                : null,
          );
        },
      ),
    );
  }

}
