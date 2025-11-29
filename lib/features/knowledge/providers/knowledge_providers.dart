import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/models/article.dart';

// News Provider
final newsProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final apiService = ref.watch(krishiApiServiceProvider);
  final response = await apiService.getNews(page: 1);
  return response.results;
});

// Articles Provider
final articlesProvider = FutureProvider.autoDispose<List<Article>>((ref) async {
  final apiService = ref.watch(krishiApiServiceProvider);
  final response = await apiService.getArticles(page: 1);
  return response.results;
});

// Article Detail Provider
final articleDetailProvider = FutureProvider.autoDispose.family<Article, int>(
  (ref, articleId) async {
    final apiService = ref.watch(krishiApiServiceProvider);
    return await apiService.getArticle(articleId);
  },
);
