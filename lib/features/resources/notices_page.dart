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
      if (!mounted || e is FormatException) {
        return;
      }
      Get.snackbar('Failed to load notices: $e');
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
          style: Get.bodyLarge.px18.w600.copyWith(color: Colors.white),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterOptions.entries.map((entry) {
            final isSelected = _selectedFilter == entry.key;
            final color = _filterColors[entry.key] ?? Get.primaryColor;
            final icon = entry.key == 'all'
                ? Icons.all_inclusive
                : _filterIcons[entry.key] ?? Icons.article_rounded;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
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
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.st,
              color: isSelected ? Colors.white : color,
            ),
            6.horizontalGap,
            AppText(
              label,
              style: Get.bodySmall.px12.w600.copyWith(
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
            color: Get.disabledColor.withValues(alpha: 0.6),
          ),
          16.verticalGap,
          AppText(
            'no_notices_available'.tr(context),
            style: Get.bodyLarge.px18.w600.copyWith(
              color: Get.bodyLarge.color ??
                  (Get.isDark ? Colors.white : Colors.black87),
            ),
          ),
          8.verticalGap,
          AppText(
            'check_back_later_updates'.tr(context),
            style: Get.bodyMedium.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.9),
            ),
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
    final titleColor = Get.bodyLarge.color ??
        (Get.isDark ? Colors.white : Colors.black87);
    final bodyColor = Get.bodyMedium.color ??
        (Get.isDark ? Colors.white70 : Colors.black87);
    final mutedColor = Get.disabledColor.withValues(alpha: 0.9);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(18).rt,
        border: Border.all(
          color: Get.disabledColor.withValues(alpha: 0.2),
        ),
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: Get.isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(24).rt,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 14.st, color: typeColor),
                          6.horizontalGap,
                          AppText(
                            notice.noticeTypeDisplay,
                            style: Get.bodySmall.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined, size: 14.st, color: mutedColor),
                    6.horizontalGap,
                    AppText(
                      DateFormat('MMM dd, yyyy').format(notice.publishedDate),
                      style: Get.bodySmall.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                12.verticalGap,
                AppText(
                  notice.title,
                  style: Get.bodyLarge.px16.w600.copyWith(color: titleColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.verticalGap,
                AppText(
                  notice.description,
                  style: Get.bodyMedium.copyWith(
                    color: bodyColor.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (notice.pdfFile != null || notice.image != null) ...[
                  12.verticalGap,
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      if (notice.pdfFile != null)
                        _buildAttachmentChip(
                          label: 'pdf_attached'.tr(context),
                          icon: Icons.picture_as_pdf_rounded,
                          color: Colors.red.shade600,
                        ),
                      if (notice.image != null)
                        _buildAttachmentChip(
                          label: 'image_attached'.tr(context),
                          icon: Icons.image_rounded,
                          color: Colors.blue.shade600,
                        ),
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

  Widget _buildAttachmentChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Get.isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(10).rt,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.st, color: color),
          6.horizontalGap,
          AppText(
            label,
            style: Get.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
