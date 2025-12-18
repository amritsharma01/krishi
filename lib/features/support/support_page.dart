import 'package:flutter/material.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/faqs_page.dart';
import 'package:krishi/features/support/contact_us_page.dart';
import 'package:krishi/features/support/user_guide_page.dart';
import 'package:krishi/features/support/widgets/support_widgets.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        title: AppText(
          'help_center'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: Get.scrollPhysics,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SupportHeader(),
                6.verticalGap,
                SupportOption(
                  title: 'faq',
                  subtitle: 'common_questions',
                  icon: Icons.quiz_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FAQsPage()),
                    );
                  },
                ),
                6.verticalGap,
                SupportOption(
                  title: 'contact_us',
                  subtitle: 'get_in_touch',
                  icon: Icons.phone_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUsPage(),
                      ),
                    );
                  },
                ),
                6.verticalGap,
                SupportOption(
                  title: 'user_guide',
                  subtitle: 'learn_how_to_use',
                  icon: Icons.menu_book_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserGuidePage(),
                      ),
                    );
                  },
                ),
                6.verticalGap,
                const QuickContactInfo(),
                8.verticalGap,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
