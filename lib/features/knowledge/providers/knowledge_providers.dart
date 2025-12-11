import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/article.dart';

// News Providers
final newsListProvider = StateProvider<List<Article>>((ref) => []);
final newsCurrentPageProvider = StateProvider<int>((ref) => 1);
final newsHasMoreProvider = StateProvider<bool>((ref) => true);
final isLoadingNewsProvider = StateProvider<bool>((ref) => false);
final isLoadingMoreNewsProvider = StateProvider<bool>((ref) => false);

// Articles Providers
final articlesListProvider = StateProvider<List<Article>>((ref) => []);
final articlesCurrentPageProvider = StateProvider<int>((ref) => 1);
final articlesHasMoreProvider = StateProvider<bool>((ref) => true);
final isLoadingArticlesProvider = StateProvider<bool>((ref) => false);
final isLoadingMoreArticlesProvider = StateProvider<bool>((ref) => false);

// Article Detail Provider
final articleDetailProvider = FutureProvider.autoDispose.family<Article, int>(
  (ref, articleId) async {
    final apiService = ref.watch(krishiApiServiceProvider);
    return await apiService.getArticle(articleId);
  },
);

// News Detail Provider
final newsDetailProvider = FutureProvider.autoDispose.family<Article, int>(
  (ref, newsId) async {
    final apiService = ref.watch(krishiApiServiceProvider);
    return await apiService.getNewsDetail(newsId);
  },
);
