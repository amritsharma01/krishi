import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgramsPage extends ConsumerStatefulWidget {
  const ProgramsPage({super.key});

  @override
  ConsumerState<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends ConsumerState<ProgramsPage> {
  final List<Program> _programs = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  final ValueNotifier<bool> _isInitialLoading = ValueNotifier(true);
  final ValueNotifier<bool> _isLoadingMore = ValueNotifier(false);
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _isInitialLoading.dispose();
    _isLoadingMore.dispose();
    super.dispose();
  }

  Future<void> _loadPrograms({bool refresh = false}) async {
    if (_isLoadingMore.value && !refresh) return;
    if (!_hasMore && !refresh && _currentPage > 1) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (_currentPage == 1) {
      _isInitialLoading.value = true;
    } else {
      _isLoadingMore.value = true;
    }

    try {
      final response = await ref
          .read(krishiApiServiceProvider)
          .getPrograms(
            page: _currentPage,
            search: _searchQuery.isEmpty ? null : _searchQuery,
            ordering: '-created_at',
          );
      if (!mounted) return;
      if (_currentPage == 1) {
        _programs
          ..clear()
          ..addAll(response.results);
      } else {
        _programs.addAll(response.results);
      }
      _hasMore = response.next != null;
      _currentPage += 1;
      _isInitialLoading.value = false;
      _isLoadingMore.value = false;
    } catch (e) {
      if (!mounted) return;
      _isInitialLoading.value = false;
      _isLoadingMore.value = false;
      if (e is! FormatException) {
        Get.snackbar('failed_to_load_programs'.tr(context));
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = value.trim();
      _loadPrograms(refresh: true);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _loadPrograms(refresh: true);
  }

  Future<void> _openProgramLink(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      Get.snackbar('failed_to_open_form'.tr(context));
      return;
    }

    final normalized = trimmed.startsWith('http')
        ? trimmed
        : trimmed.startsWith('www.')
        ? 'https://$trimmed'
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      Get.snackbar('failed_to_open_form'.tr(context));
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        if (mounted) {
          Get.snackbar('failed_to_open_form'.tr(context));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'programs'.tr(context),
          style: Get.bodyLarge.px18.w600.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Get.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isInitialLoading,
              builder: (context, isInitialLoading, _) {
                return isInitialLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : _programs.isEmpty
                    ? _buildEmptyState(context)
                    : _buildProgramsList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.wt, 20.ht, 16.wt, 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.vertical(
          bottom: const Radius.circular(28),
        ).rt,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'agricultural_development_programs'.tr(context),
            style: Get.bodyLarge.px14.w700.copyWith(color: Get.disabledColor),
          ),
          8.verticalGap,
          AppText(
            maxLines: 4,
            'programs_intro'.tr(context),
            style: Get.bodyMedium.px12.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          16.verticalGap,
          _buildSearchField(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'search_programs'.tr(context),
        prefixIcon: Icon(Icons.search_rounded, color: Get.disabledColor),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _clearSearch,
              )
            : null,
        filled: true,
        fillColor: Get.scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16).rt,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildProgramsList() {
    return RefreshIndicator(
      onRefresh: () => _loadPrograms(refresh: true),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.wt, 16.ht, 16.wt, 24.ht),
        itemCount: _programs.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _programs.length) {
            return _buildLoadMoreButton();
          }
          final program = _programs[index];
          return _buildProgramCard(program);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!_hasMore) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingMore,
      builder: (context, isLoadingMore, _) {
        return Padding(
          padding: EdgeInsets.only(top: 8.ht),
          child: ElevatedButton(
            onPressed: isLoadingMore ? null : () => _loadPrograms(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.primaryColor,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16).rt,
              ),
            ),
            child: isLoadingMore
                ? SizedBox(
                    height: 18.st,
                    width: 18.st,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : AppText(
                    'load_more'.tr(context),
                    style: Get.bodyMedium.copyWith(color: Colors.white),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildProgramCard(Program program) {
    final titleColor =
        Get.bodyLarge.color ?? (Get.isDark ? Colors.white : Colors.black87);
    final bodyColor =
        Get.bodyMedium.color ?? (Get.isDark ? Colors.white70 : Colors.black87);
    final dateText = DateFormat('MMM dd, yyyy').format(program.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: 16.ht),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.rt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.rt),
                  decoration: BoxDecoration(
                    color: Get.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14).rt,
                  ),
                  child: Icon(
                    Icons.agriculture_rounded,
                    color: Get.primaryColor,
                  ),
                ),
                12.horizontalGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        program.title,
                        style: Get.bodyLarge.px16.w700.copyWith(
                          color: titleColor,
                        ),
                      ),
                      4.verticalGap,
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12.st,
                            color: Get.disabledColor.withValues(alpha: 0.7),
                          ),
                          4.horizontalGap,
                          AppText(
                            dateText,
                            style: Get.bodySmall.copyWith(
                              color: Get.disabledColor.withValues(alpha: 0.7),
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
              program.description,
              style: Get.bodyMedium.copyWith(
                color: bodyColor.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            16.verticalGap,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openProgramLink(program.googleFormLink),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Get.primaryColor,
                  side: BorderSide(color: Get.primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 12.ht),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14).rt,
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: AppText(
                  'apply_now'.tr(context),
                  style: Get.bodyMedium.w600.copyWith(color: Get.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.wt),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.rt),
              decoration: BoxDecoration(
                color: Get.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                size: 48.st,
                color: Get.primaryColor,
              ),
            ),
            20.verticalGap,
            AppText(
              'no_programs_available'.tr(context),
              style: Get.bodyLarge.px18.w700,
              textAlign: TextAlign.center,
            ),
            8.verticalGap,
            AppText(
              'programs_empty_state_subtitle'.tr(context),
              style: Get.bodyMedium.copyWith(
                color: Get.disabledColor.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
