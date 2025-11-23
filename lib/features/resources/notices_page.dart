import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/notice_detail_page.dart';
import 'package:krishi/models/resources.dart';

class NoticesPage extends ConsumerStatefulWidget {
  const NoticesPage({super.key});

  @override
  ConsumerState<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends ConsumerState<NoticesPage> {
  List<Notice> _notices = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  Map<String, String> _getFilterOptions(BuildContext context) {
    return {
      'all': 'all_notices'.tr(context),
      'general': 'general'.tr(context),
      'important': 'important'.tr(context),
      'urgent': 'urgent'.tr(context),
      'event': 'events'.tr(context),
      'training': 'training'.tr(context),
    };
  }

  final Map<String, IconData> _filterIcons = {
    'general': Icons.article_rounded,
    'important': Icons.info_rounded,
    'urgent': Icons.warning_amber_rounded,
    'event': Icons.event_rounded,
    'training': Icons.school_rounded,
  };

  final Map<String, Color> _filterColors = {
    'general': Colors.grey,
    'important': Colors.orange,
    'urgent': Colors.red,
    'event': Colors.blue,
    'training': Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices({String? noticeType}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final notices = await apiService.getNotices(
        noticeType: noticeType == 'all' ? null : noticeType,
      );
      setState(() {
        _notices = notices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Get.snackbar('Failed to load notices: $e');
      }
    }
  }

  Color _getNoticeTypeColor(String type) {
    switch (type) {
      case 'urgent':
        return Colors.red;
      case 'important':
        return Colors.orange;
      case 'event':
        return Colors.blue;
      case 'training':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getNoticeTypeIcon(String type) {
    switch (type) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'important':
        return Icons.info_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'training':
        return Icons.school_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'notices_announcements'.tr(context),
          style: Get.bodyLarge.px24.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Get.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterChips(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notices.isEmpty
                    ? _buildEmptyState(context)
                    : _buildNoticesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filterOptions = _getFilterOptions(context);
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: 14.h,
      ),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(28),
        ).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: Get.primaryColor,
                size: 20.st,
              ),
              8.horizontalGap,
              AppText(
                'filter_notices'.tr(context),
                style: Get.bodyMedium.w600.copyWith(
                  color: Get.primaryColor,
                ),
              ),
            ],
          ),
          12.verticalGap,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.entries.map((entry) {
                final isSelected = _selectedFilter == entry.key;
                final color = _filterColors[entry.key] ?? Get.primaryColor;
                final icon = entry.key == 'all'
                    ? Icons.all_inclusive
                    : _filterIcons[entry.key] ?? Icons.article_rounded;
                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: _buildFilterPill(
                    label: entry.value,
                    icon: icon,
                    color: color,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedFilter = entry.key;
                      });
                      _loadNotices(noticeType: entry.key);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                )
              : null,
          color: isSelected ? null : Get.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24).rt,
          border: Border.all(
            color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.st,
              color: isSelected ? Colors.white : color,
            ),
            8.horizontalGap,
            AppText(
              label,
              style: Get.bodySmall.w600.copyWith(
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80.st,
            color: Colors.grey.shade400,
          ),
          16.verticalGap,
          AppText(
            'no_notices_available'.tr(context),
            style: Get.bodyLarge.px18.w600.copyWith(color: Colors.grey.shade600),
          ),
          8.verticalGap,
          AppText(
            'check_back_later_updates'.tr(context),
            style: Get.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticesList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadNotices(noticeType: _selectedFilter),
      child: ListView.builder(
        padding: EdgeInsets.all(16.rt),
        itemCount: _notices.length,
        itemBuilder: (context, index) {
          final notice = _notices[index];
          return _buildNoticeCard(context, notice);
        },
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, Notice notice) {
    final typeColor = _getNoticeTypeColor(notice.noticeType);
    final typeIcon = _getNoticeTypeIcon(notice.noticeType);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoticeDetailPage(notice: notice),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16).rt,
          child: Padding(
            padding: EdgeInsets.all(16.rt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.rt),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8).rt,
                      ),
                      child: Icon(
                        typeIcon,
                        color: typeColor,
                        size: 20.st,
                      ),
                    ),
                    12.horizontalGap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            notice.title,
                            style: Get.bodyLarge.w600,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.verticalGap,
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4).rt,
                                ),
                                child: AppText(
                                  notice.noticeTypeDisplay,
                                  style: Get.bodySmall.copyWith(
                                    color: typeColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                              8.horizontalGap,
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12.st,
                                color: Colors.grey.shade600,
                              ),
                              4.horizontalGap,
                              AppText(
                                DateFormat('MMM dd, yyyy')
                                    .format(notice.publishedDate),
                                style: Get.bodySmall.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                12.verticalGap,
                AppText(
                  notice.description,
                  style: Get.bodyMedium.copyWith(color: Colors.grey.shade700),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notice.pdfFile != null || notice.image != null) ...[
                  12.verticalGap,
                  Row(
                    children: [
                      if (notice.pdfFile != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6).rt,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 16.st,
                                color: Colors.red.shade700,
                              ),
                              6.horizontalGap,
                              AppText(
                                'pdf_attached'.tr(context),
                                style: Get.bodySmall.copyWith(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (notice.image != null) ...[
                        if (notice.pdfFile != null) 8.horizontalGap,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6).rt,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_rounded,
                                size: 16.st,
                                color: Colors.blue.shade700,
                              ),
                              6.horizontalGap,
                              AppText(
                                'image_attached'.tr(context),
                                style: Get.bodySmall.copyWith(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
