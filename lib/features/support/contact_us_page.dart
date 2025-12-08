import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/support/providers/contact_us_providers.dart';
import 'package:krishi/features/support/widgets/contact_us_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
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

  final Map<String, Color> _contactColors = {
    'support': Colors.blue,
    'technical': Colors.purple,
    'sales': Colors.green,
    'general': Colors.orange,
  };

  void _onFilterSelected(String contactType) {
    ref.read(selectedContactUsTypeProvider.notifier).state = contactType;
    ref.invalidate(contactUsListProvider(contactType == 'all' ? null : contactType));
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
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'contact_us'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          ContactUsFilter(
            contactTypes: _getContactTypes(context),
            contactIcons: _contactIcons,
            contactColors: _contactColors,
            onFilterSelected: _onFilterSelected,
          ),
          Expanded(
            child: ContactUsList(
              onRefresh: (contactType) async {
                ref.invalidate(contactUsListProvider(contactType == 'all' ? null : contactType));
              },
              contactColors: _contactColors,
              contactIcons: _contactIcons,
              onMakePhoneCall: _makePhoneCall,
              onSendEmail: _sendEmail,
            ),
          ),
        ],
      ),
    );
  }

}

