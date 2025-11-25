import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/models/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class SoilTestingPage extends ConsumerStatefulWidget {
  const SoilTestingPage({super.key});

  @override
  ConsumerState<SoilTestingPage> createState() => _SoilTestingPageState();
}

class _SoilTestingPageState extends ConsumerState<SoilTestingPage> {
  final List<SoilTest> _centers = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSoilTests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSoilTests({bool refresh = false}) async {
    if (_isLoadingMore && !refresh) return;
    if (!_hasMore && !refresh && _currentPage > 1) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (_currentPage == 1) {
      setState(() => _isInitialLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await ref.read(krishiApiServiceProvider).getSoilTests(
            page: _currentPage,
            search: _searchQuery.isEmpty ? null : _searchQuery,
            ordering: 'municipality_name',
          );
      if (!mounted) return;
      setState(() {
        if (_currentPage == 1) {
          _centers
            ..clear()
            ..addAll(response.results);
        } else {
          _centers.addAll(response.results);
        }
        _hasMore = response.next != null;
        _currentPage += 1;
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
      Get.snackbar('failed_to_load_soil_tests'.tr(context));
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = value.trim();
      _loadSoilTests(refresh: true);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _loadSoilTests(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppText(
          'soil_testing'.tr(context),
          style: Get.bodyLarge.px20.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadSoilTests(refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              24.verticalGap,
              _buildIntroSection(context),
              32.verticalGap,
              _buildFeatures(context),
              32.verticalGap,
              _buildCentersSection(context),
              20.verticalGap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 200.rt,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20).rt,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.science_rounded,
          size: 100.st,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'soil_testing_title'.tr(context),
          style: Get.bodyLarge.px24.w800.copyWith(color: Get.disabledColor),
        ),
        12.verticalGap,
        AppText(
          'soil_testing_description'.tr(context),
          style: Get.bodyMedium.px15.w400.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'soil_testing_features'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        16.verticalGap,
        _buildFeatureCard(
          icon: Icons.water_drop_rounded,
          title: 'ph_level',
          description: 'ph_level_description',
          color: Colors.blue,
        ),
        12.verticalGap,
        _buildFeatureCard(
          icon: Icons.grass_rounded,
          title: 'nutrients',
          description: 'nutrients_description',
          color: Colors.green,
        ),
        12.verticalGap,
        _buildFeatureCard(
          icon: Icons.opacity_rounded,
          title: 'moisture',
          description: 'moisture_description',
          color: Colors.cyan,
        ),
        12.verticalGap,
        _buildFeatureCard(
          icon: Icons.psychology_rounded,
          title: 'recommendations',
          description: 'recommendations_description',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildCentersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'soil_testing_centers'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        8.verticalGap,
        AppText(
          'soil_testing_centers_subtitle'.tr(context),
          style: Get.bodyMedium.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.7),
          ),
        ),
        16.verticalGap,
        _buildSearchField(context),
        16.verticalGap,
        if (_isInitialLoading)
          const Center(child: CircularProgressIndicator())
        else if (_centers.isEmpty)
          _buildEmptyState(context)
        else
          Column(
            children: [
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    _buildSoilTestCard(context, _centers[index]),
                separatorBuilder: (_, __) => 12.verticalGap,
                itemCount: _centers.length,
              ),
              16.verticalGap,
              if (_hasMore) _buildLoadMoreButton(),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'search_soil_tests'.tr(context),
        prefixIcon: Icon(Icons.search_rounded, color: Get.disabledColor),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _clearSearch,
              )
            : null,
        filled: true,
        fillColor: Get.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16).rt,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildLoadMoreButton() {
    return ElevatedButton(
      onPressed: _isLoadingMore ? null : () => _loadSoilTests(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14).rt,
        ),
      ),
      child: _isLoadingMore
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
    );
  }

  Widget _buildSoilTestCard(BuildContext context, SoilTest center) {
    final titleColor =
        Get.bodyLarge.color ?? (Get.isDark ? Colors.white : Colors.black87);
    return Container(
      padding: EdgeInsets.all(16.rt),
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(20).rt,
        border: Border.all(color: Get.disabledColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12).rt,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16).rt,
                ),
                child: Icon(
                  Icons.science_outlined,
                  color: AppColors.primary,
                ),
              ),
              12.horizontalGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      center.title,
                      style: Get.bodyLarge.px16.w700.copyWith(color: titleColor),
                    ),
                    4.verticalGap,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14.st,
                          color: Get.disabledColor.withValues(alpha: 0.7),
                        ),
                        4.horizontalGap,
                        Expanded(
                          child: AppText(
                            center.municipalityName,
                            style: Get.bodySmall.copyWith(
                              color: Get.disabledColor.withValues(alpha: 0.7),
                            ),
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
            center.description,
            style: Get.bodyMedium.copyWith(
              color: Get.disabledColor.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          16.verticalGap,
          _buildDetailRow(
            icon: Icons.person_rounded,
            label: 'contact_person'.tr(context),
            value: center.contactPerson ?? 'not_available'.tr(context),
          ),
          8.verticalGap,
          _buildDetailRow(
            icon: Icons.phone_rounded,
            label: 'phone_number'.tr(context),
            value: center.phoneNumber,
            trailing: TextButton(
              onPressed: () => _launchPhone(center.phoneNumber),
              child: AppText(
                'call_now'.tr(context),
                style: Get.bodySmall.w600.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          if (center.email != null && center.email!.isNotEmpty) ...[
            8.verticalGap,
            _buildDetailRow(
              icon: Icons.email_rounded,
              label: 'email'.tr(context),
              value: center.email!,
              trailing: IconButton(
                icon: Icon(Icons.open_in_new, color: AppColors.primary, size: 18.st),
                onPressed: () => _launchEmail(center.email!),
              ),
            ),
          ],
          8.verticalGap,
          _buildDetailRow(
            icon: Icons.home_work_rounded,
            label: 'address'.tr(context),
            value: center.address,
          ),
          if (center.cost != null && center.cost!.isNotEmpty) ...[
            8.verticalGap,
            _buildDetailRow(
              icon: Icons.paid_rounded,
              label: 'testing_cost'.tr(context),
              value: center.cost!,
            ),
          ],
          if (center.duration != null && center.duration!.isNotEmpty) ...[
            8.verticalGap,
            _buildDetailRow(
              icon: Icons.schedule_rounded,
              label: 'duration_label'.tr(context),
              value: center.duration!,
            ),
          ],
          if (center.requirements != null && center.requirements!.isNotEmpty) ...[
            16.verticalGap,
            Container(
              padding: const EdgeInsets.all(12).rt,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14).rt,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'requirements_label'.tr(context),
                    style: Get.bodyMedium.w700.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  6.verticalGap,
                  AppText(
                    center.requirements!,
                    style: Get.bodySmall.copyWith(
                      color: Get.disabledColor.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Get.disabledColor.withValues(alpha: 0.7), size: 18.st),
        10.horizontalGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                style: Get.bodySmall.px11.w600.copyWith(
                  color: Get.disabledColor.withValues(alpha: 0.6),
                ),
              ),
              2.verticalGap,
              AppText(
                value,
                style: Get.bodyMedium.copyWith(
                  color: Get.disabledColor,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16).rt,
      decoration: BoxDecoration(
        color: Get.cardColor,
        borderRadius: BorderRadius.circular(16).rt,
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12).rt,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12).rt,
            ),
            child: Icon(
              icon,
              size: 24.st,
              color: color,
            ),
          ),
          16.horizontalGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title.tr(context),
                  style: Get.bodyMedium.px15.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                4.verticalGap,
                AppText(
                  description.tr(context),
                  style: Get.bodySmall.px13.w400.copyWith(
                    color: Get.disabledColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.map_rounded,
          size: 48.st,
          color: Get.disabledColor.withValues(alpha: 0.6),
        ),
        12.verticalGap,
        AppText(
          'no_soil_tests'.tr(context),
          style: Get.bodyLarge.px16.w600.copyWith(
            color: Get.disabledColor,
          ),
          textAlign: TextAlign.center,
        ),
        6.verticalGap,
        AppText(
          'soil_tests_empty_state_subtitle'.tr(context),
          style: Get.bodySmall.copyWith(
            color: Get.disabledColor.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('failed_to_open_form'.tr(context));
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('failed_to_open_form'.tr(context));
    }
  }
}

