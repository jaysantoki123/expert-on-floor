import 'dart:convert';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../utils/api_constants.dart';

class CommunityService {
  final _apiClient = ApiClient();

  Future<List<dynamic>> getPosts({String? tag, String? search, String? sort}) async {
    final queryParams = <String, String>{};
    if (tag != null && tag != 'All') queryParams['tag'] = tag;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (sort != null) queryParams['sort'] = sort;

    final baseUri = Uri.parse(ApiConstants.communityPostsUrl);
    final uri = queryParams.isNotEmpty
        ? baseUri.replace(queryParameters: queryParams)
        : baseUri;

    final fullUrl = uri.toString();
    final relativePath = fullUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativePath);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? [];
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load posts',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<String>> getTags() async {
    try {
      final relativeUrl = ApiConstants.communityTagsUrl.replaceFirst(ApiConstants.baseUrl, '');
      final response = await _apiClient.get(relativeUrl);

      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        final List<dynamic> tags = responseBody['data'] ?? [];
        return tags.map((t) => t.toString()).toList();
      } else {
        return ['Flutter', 'Node.js', 'React', 'Career', 'DevOps', 'MySQL', 'AI/ML'];
      }
    } catch (e) {
      return ['Flutter', 'Node.js', 'React', 'Career', 'DevOps', 'MySQL', 'AI/ML'];
    }
  }

  Future<Map<String, dynamic>> getPostById(int id) async {
    final relativeUrl = ApiConstants.getPostDetailUrl(id).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? {};
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load post details',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> createPost({required String question, required String tag}) async {
    final relativeUrl = ApiConstants.communityPostsUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(
      relativeUrl,
      body: {'question': question, 'tag': tag},
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? {};
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to post question',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> createAnswer({required int postId, required String answer}) async {
    final relativeUrl = ApiConstants.getPostAnswersUrl(postId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(
      relativeUrl,
      body: {'answer': answer},
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? {};
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to submit answer',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final relativeUrl = ApiConstants.getLikePostUrl(postId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return {
        'likes': responseBody['likes'] ?? 0,
        'isLiked': responseBody['isLiked'] ?? false,
      };
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to like post',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> toggleLikeAnswer(int answerId) async {
    final relativeUrl = ApiConstants.getLikeAnswerUrl(answerId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return {
        'likes': responseBody['likes'] ?? 0,
        'isLiked': responseBody['isLiked'] ?? false,
      };
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to like answer',
        statusCode: response.statusCode,
      );
    }
  }
}