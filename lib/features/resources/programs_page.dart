import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/resources/providers/programs_providers.dart';
import 'package:krishi/features/resources/widgets/empty_state_widget.dart';
import 'package:krishi/features/resources/widgets/programs_widgets.dart';
import 'package:krishi/features/resources/widgets/search_field.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgramsPage extends ConsumerStatefulWidget {
  const ProgramsPage({super.key});

  @override
  ConsumerState<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends ConsumerState<ProgramsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrograms();
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

    final isLoadingMore = ref.read(isLoadingMoreProgramsProvider);
    final hasMore = ref.read(hasMoreProgramsProvider);
    final isLoading = ref.read(isLoadingProgramsProvider);

    if (isLoadingMore || !hasMore || isLoading) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadPrograms();
    }
  }

  Future<void> _loadPrograms({bool refresh = false}) async {
    if (!mounted) return;

    if (refresh) {
      ref.read(currentProgramsPageProvider.notifier).state = 1;
      ref.read(hasMoreProgramsProvider.notifier).state = true;
      ref.read(isLoadingProgramsProvider.notifier).state = true;
      ref.read(isLoadingMoreProgramsProvider.notifier).state = false;
    } else {
      final currentPage = ref.read(currentProgramsPageProvider);
      if (currentPage == 1) {
        // First load
        ref.read(isLoadingProgramsProvider.notifier).state = true;
      } else {
        // Loading more
        final isLoadingMore = ref.read(isLoadingMoreProgramsProvider);
        if (isLoadingMore) return;
        ref.read(isLoadingMoreProgramsProvider.notifier).state = true;
      }
    }

    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final currentPage = ref.read(currentProgramsPageProvider);
      final searchQuery = ref.read(programsSearchQueryProvider);

      debugPrint('Loading programs page: $currentPage');
      final response = await apiService.getPrograms(
        page: currentPage,
        pageSize: 10,
        search: searchQuery.isEmpty ? null : searchQuery,
        ordering: '-created_at',
      );

      if (!mounted) return;

      final programs = ref.read(programsListProvider);
      if (currentPage == 1) {
        ref.read(programsListProvider.notifier).state = response.results;
      } else {
        ref.read(programsListProvider.notifier).state = [
          ...programs,
          ...response.results,
        ];
      }

      ref.read(hasMoreProgramsProvider.notifier).state = response.next != null;
      ref.read(currentProgramsPageProvider.notifier).state = currentPage + 1;
      ref.read(isLoadingProgramsProvider.notifier).state = false;
      ref.read(isLoadingMoreProgramsProvider.notifier).state = false;
    } catch (e) {
      debugPrint('Error loading programs: $e');
      if (mounted) {
        ref.read(isLoadingProgramsProvider.notifier).state = false;
        ref.read(isLoadingMoreProgramsProvider.notifier).state = false;

        // Only show error if it's the initial load or a refresh
        final currentPage = ref.read(currentProgramsPageProvider);
        if (currentPage == 1 || refresh) {
          if (e is! FormatException) {
            Get.snackbar('failed_to_load_programs'.tr(context));
          }
        }
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final trimmedValue = value.trim();
      ref.read(programsSearchQueryProvider.notifier).state = trimmedValue;
      _loadPrograms(refresh: true);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(programsSearchQueryProvider.notifier).state = '';
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
    final isLoading = ref.watch(isLoadingProgramsProvider);
    final programs = ref.watch(programsListProvider);
    final hasPrograms = programs.isNotEmpty;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          'programs'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        backgroundColor: Get.cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Get.disabledColor),
      ),
      body: Column(
        children: [
          ProgramsHeader(
            searchField: SearchField(
              controller: _searchController,
              hintText: 'search_programs'.tr(context),
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
              showClearButton: ref
                  .watch(programsSearchQueryProvider)
                  .isNotEmpty,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : hasPrograms
                ? _buildProgramsList()
                : EmptyStateWidget(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'no_programs_available'.tr(context),
                    subtitle: 'programs_empty_state_subtitle'.tr(context),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsList() {
    final programs = ref.watch(programsListProvider);
    final isLoadingMore = ref.watch(isLoadingMoreProgramsProvider);

    return RefreshIndicator(
      onRefresh: () => _loadPrograms(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(6).rt,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: programs.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == programs.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.ht),
              child: Center(
                child: SizedBox(
                  height: 24.st,
                  width: 24.st,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Get.primaryColor),
                  ),
                ),
              ),
            );
          }
          final program = programs[index];
          return ProgramCard(
            program: program,
            onApply: () => _openProgramLink(program.googleFormLink),
          );
        },
      ),
    );
  }
}
