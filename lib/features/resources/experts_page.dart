import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Widget _buildExpertsList() {
    return RefreshIndicator(
      onRefresh: _loadExperts,
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _experts.length,
        itemBuilder: (context, index) {
          final expert = _experts[index];
          return _buildExpertCard(expert);
        },
      ),
    );
  }

  Widget _buildExpertCard(Expert expert) {
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
        children: [
          // Header with photo and basic info
          Container(
            padding: EdgeInsets.all(16.rt),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade700,
                  Colors.indigo.shade500,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.rt),
                topRight: Radius.circular(16.rt),
              ),
            ),
            child: Row(
              children: [
                // Photo
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: expert.photo != null && expert.photo!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: expert.photo!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.white,
                              child: Icon(
                                Icons.person_rounded,
                                size: 40.st,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white,
                            child: Icon(
                              Icons.person_rounded,
                              size: 40.st,
                              color: Colors.indigo.shade700,
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
                          expert.specialization,
                          style: Get.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(16.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Qualifications
                _buildInfoRow(
                  icon: Icons.school_rounded,
                  label: 'Qualifications',
                  value: expert.qualifications,
                  color: Colors.blue,
                ),
                12.verticalGap,

                // Office Address
                _buildInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Office',
                  value: expert.officeAddress,
                  color: Colors.red,
                ),
                12.verticalGap,

                // Availability
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Days',
                        value: expert.availableDays,
                        color: Colors.green,
                      ),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Hours',
                        value: expert.availableHours,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                12.verticalGap,

                // Consultation Fee
                _buildInfoRow(
                  icon: Icons.payments_rounded,
                  label: 'Consultation Fee',
                  value: expert.consultationFee,
                  color: Colors.purple,
                ),
                20.verticalGap,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade600, Colors.green.shade700],
                          ),
                          borderRadius: BorderRadius.circular(10).rt,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _makePhoneCall(expert.phoneNumber),
                            borderRadius: BorderRadius.circular(10).rt,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    color: Colors.white,
                                    size: 20.st,
                                  ),
                                  8.horizontalGap,
                                  AppText(
                                    'Call',
                                    style: Get.bodyMedium.w600.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (expert.email.isNotEmpty) ...[
                      16.horizontalGap,
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade700],
                            ),
                            borderRadius: BorderRadius.circular(10).rt,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _sendEmail(expert.email),
                              borderRadius: BorderRadius.circular(10).rt,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      color: Colors.white,
                                      size: 20.st,
                                    ),
                                    8.horizontalGap,
                                    AppText(
                                      'Email',
                                      style: Get.bodyMedium.w600.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
