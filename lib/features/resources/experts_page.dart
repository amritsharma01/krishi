import 'package:cached_network_image/cached_network_image.dart';
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
import 'expert_detail_page.dart';

class ExpertsPage extends ConsumerStatefulWidget {
  const ExpertsPage({super.key});

  @override
  ConsumerState<ExpertsPage> createState() => _ExpertsPageState();
}

class _ExpertsPageState extends ConsumerState<ExpertsPage> {
  List<Expert> _experts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExperts();
  }

  Future<void> _loadExperts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final experts = await apiService.getExperts();
      setState(() {
        _experts = experts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar('Failed to load experts: $e');
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
          'Talk to Experts',
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _experts.isEmpty
          ? _buildEmptyState()
          : _buildExpertsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'No experts available',
            style: Get.bodyLarge.px18.w600.copyWith(
              color: Colors.grey.shade600,
            ),
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

  Widget _buildExpertsList() {
    return RefreshIndicator(
      onRefresh: _loadExperts,
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _experts.length,
        itemBuilder: (context, index) {
          final expert = _experts[index];
          return _buildExpertCard(context, expert);
        },
      ),
    );
  }

  Widget _buildExpertCard(BuildContext context, Expert expert) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(22).rt,
        border: Border.all(color: Colors.indigo.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade100.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22).rt,
        child: InkWell(
          borderRadius: BorderRadius.circular(22).rt,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ExpertDetailPage(expert: expert)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(20.rt),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade700, Colors.indigo.shade400],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(22),
                  ).rt,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 82.w,
                      height: 82.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: expert.photo != null && expert.photo!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: expert.photo!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person_rounded,
                                  size: 40.st,
                                  color: Colors.indigo.shade50,
                                ),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 40.st,
                                color: Colors.indigo.shade50,
                              ),
                      ),
                    ),
                    18.horizontalGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            expert.name,
                            style: Get.bodyLarge.px20.w700.copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          6.verticalGap,
                          AppText(
                            expert.specialization,
                            style: Get.bodyMedium.w500.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          12.verticalGap,
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 6.h,
                            children: [
                              _buildMetaBadge(
                                icon: Icons.calendar_today_rounded,
                                text: expert.availableDays,
                              ),
                              _buildMetaBadge(
                                icon: Icons.access_time_rounded,
                                text: expert.availableHours,
                              ),
                              _buildMetaBadge(
                                icon: Icons.payments_rounded,
                                text: expert.consultationFee,
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
                      icon: Icons.school_rounded,
                      label: 'Qualifications',
                      value: expert.qualifications,
                      color: Colors.blue,
                    ),
                    12.verticalGap,
                    _buildInfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Office',
                      value: expert.officeAddress,
                      color: Colors.red,
                    ),
                    12.verticalGap,
                    _buildInfoRow(
                      icon: Icons.support_agent_rounded,
                      label: 'Contact',
                      value: expert.phoneNumber,
                      color: Colors.deepPurple,
                    ),
                    20.verticalGap,
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: 'Call',
                            icon: Icons.phone_rounded,
                            color: Colors.green,
                            onTap: () => _makePhoneCall(expert.phoneNumber),
                          ),
                        ),
                        if (expert.email.isNotEmpty) ...[
                          16.horizontalGap,
                          Expanded(
                            child: _buildActionButton(
                              label: 'Email',
                              icon: Icons.email_rounded,
                              color: Colors.blue,
                              onTap: () => _sendEmail(expert.email),
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
        ),
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
        borderRadius: BorderRadius.circular(14).rt,
        border: Border.all(color: color.withValues(alpha: 0.18)),
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

  Widget _buildMetaBadge({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30).rt,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
        ),
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14).rt,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.st, color: color),
            8.horizontalGap,
            AppText(
              label,
              style: Get.bodyMedium.w600.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
