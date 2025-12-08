import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';

class ExpertCard extends StatelessWidget {
  final Expert expert;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback? onEmail;

  const ExpertCard({
    super.key,
    required this.expert,
    required this.onCall,
    required this.onWhatsApp,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 70.rt,
                  height: 70.rt,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: expert.photo != null && expert.photo!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: Get.imageUrl(expert.photo!),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person_rounded,
                                size: 35.st,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person_rounded,
                              size: 35.st,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
                16.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        expert.name,
                        style: Get.bodyLarge.px18.w700.copyWith(
                          color: Get.disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      6.verticalGap,
                      AppText(
                        expert.specialization,
                        style: Get.bodyMedium.px14.w500.copyWith(
                          color: Get.disabledColor.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            20.verticalGap,
            Wrap(
              spacing: 8.rt,
              runSpacing: 8.rt,
              children: [
                _InfoPill(
                  icon: Icons.access_time_rounded,
                  text: expert.availableHours,
                ),
                _InfoPill(
                  icon: Icons.calendar_today_rounded,
                  text: expert.availableDays,
                ),
                _InfoPill(
                  icon: Icons.payments_rounded,
                  text: expert.consultationFee,
                ),
              ],
            ),
            20.verticalGap,
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ContactButton(
                        icon: Icons.phone_rounded,
                        label: 'call'.tr(context),
                        color: Colors.green,
                        onTap: onCall,
                      ),
                    ),
                    12.horizontalGap,
                    Expanded(
                      child: _ContactButton(
                        icon: Icons.chat_rounded,
                        label: 'whatsapp'.tr(context),
                        color: const Color(0xFF25D366),
                        onTap: onWhatsApp,
                      ),
                    ),
                  ],
                ),
                if (onEmail != null) ...[
                  12.verticalGap,
                  _ContactButton(
                    icon: Icons.email_rounded,
                    label: 'email'.tr(context),
                    color: Colors.blue,
                    onTap: onEmail!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.rt, vertical: 8.rt),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12).rt,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.st, color: AppColors.primary),
          6.horizontalGap,
          Flexible(
            child: AppText(
              text,
              style: Get.bodySmall.px12.w600.copyWith(color: Get.disabledColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12).rt,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.rt, horizontal: 8.rt),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12).rt,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.st, color: color),
              6.horizontalGap,
              Flexible(
                child: AppText(
                  label,
                  style: Get.bodyMedium.px14.w600.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
