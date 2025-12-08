import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/soil_testing/providers/soil_testing_providers.dart';
import 'package:krishi/features/soil_testing/widgets/soil_testing_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SoilTestingPage extends ConsumerStatefulWidget {
  const SoilTestingPage({super.key});

  @override
  ConsumerState<SoilTestingPage> createState() => _SoilTestingPageState();
}

class _SoilTestingPageState extends ConsumerState<SoilTestingPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSoilTests();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted) return;

    final isLoadingMore = ref.read(isLoadingMoreSoilTestsProvider);
    final hasMore = ref.read(hasMoreSoilTestsProvider);
    final isLoading = ref.read(isLoadingSoilTestsProvider);

    if (isLoadingMore || !hasMore || isLoading) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadSoilTests();
    }
  }

  Future<void> _loadSoilTests({bool refresh = false}) async {
    if (!mounted) return;

    if (refresh) {
      ref.read(currentSoilTestsPageProvider.notifier).state = 1;
      ref.read(hasMoreSoilTestsProvider.notifier).state = true;
      ref.read(isLoadingSoilTestsProvider.notifier).state = true;
      ref.read(isLoadingMoreSoilTestsProvider.notifier).state = false;
    } else {
      final currentPage = ref.read(currentSoilTestsPageProvider);
      if (currentPage == 1) {
        // First load
        ref.read(isLoadingSoilTestsProvider.notifier).state = true;
      } else {
        // Loading more
        final isLoadingMore = ref.read(isLoadingMoreSoilTestsProvider);
        if (isLoadingMore) return;
        ref.read(isLoadingMoreSoilTestsProvider.notifier).state = true;
      }
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(currentSoilTestsPageProvider);
      final searchQuery = ref.read(soilTestsSearchQueryProvider);

      debugPrint('Loading soil tests page: $currentPage');
      final response = await apiService.getSoilTests(
        page: currentPage,
        pageSize: 10,
        search: searchQuery.isEmpty ? null : searchQuery,
        ordering: 'municipality_name',
      );

      if (!mounted) return;

      final centers = ref.read(soilTestsListProvider);
      if (currentPage == 1) {
        ref.read(soilTestsListProvider.notifier).state = response.results;
      } else {
        ref.read(soilTestsListProvider.notifier).state = [
          ...centers,
          ...response.results,
        ];
      }

      ref.read(hasMoreSoilTestsProvider.notifier).state = response.next != null;
      ref.read(currentSoilTestsPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingSoilTestsProvider.notifier).state = false;
      ref.read(isLoadingMoreSoilTestsProvider.notifier).state = false;
    } catch (e) {
      debugPrint('Error loading soil tests: $e');
      if (mounted) {
        ref.read(isLoadingSoilTestsProvider.notifier).state = false;
        ref.read(isLoadingMoreSoilTestsProvider.notifier).state = false;

        // Only show error if it's the initial load or a refresh
        final currentPage = ref.read(currentSoilTestsPageProvider);
        if (currentPage == 1 || refresh) {
          if (e is! FormatException) {
            Get.snackbar('failed_to_load_soil_tests'.tr(context));
          }
        }
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final trimmedValue = value.trim();
      ref.read(soilTestsSearchQueryProvider.notifier).state = trimmedValue;
      _loadSoilTests(refresh: true);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(soilTestsSearchQueryProvider.notifier).state = '';
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
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
      ),
      body: Column(
        children: [
          SoilTestingHeader(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _clearSearch,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadSoilTests(refresh: true),
              child: SoilTestingList(
                scrollController: _scrollController,
                onRefresh: _loadSoilTests,
                onMakePhoneCall: _launchPhone,
                onSendEmail: _launchEmail,
              ),
            ),
          ),
        ],
      ),
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
