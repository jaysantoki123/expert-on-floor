import 'dart:convert';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/expert_model.dart';
import '../utils/api_constants.dart';

class ExpertService {
  final _apiClient = ApiClient();

  Future<ExpertModel> getExpertById(String id) async {
    final relativePath = '/experts/$id';
    final response = await _apiClient.get(relativePath);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return ExpertModel.fromJson(responseBody['data']);
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load expert',
      );
    }
  }

  Future<List<ExpertModel>> getExperts({
    String? category,
    String? skill,
    double? minRating,
    double? maxPrice,
    String? sort,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'All') {
      queryParams['category'] = category;
    }
    if (skill != null && skill != 'All') {
      queryParams['skill'] = skill;
    }
    if (minRating != null && minRating > 0.0) {
      queryParams['minRating'] = minRating.toString();
    }
    if (maxPrice != null && maxPrice < 2000.0) {
      queryParams['maxPrice'] = maxPrice.round().toString();
    }
    if (sort != null) {
      queryParams['sort'] = sort;
    }

    final baseUri = Uri.parse(ApiConstants.expertsUrl);
    final uri = queryParams.isNotEmpty
        ? baseUri.replace(queryParameters: queryParams)
        : baseUri;

    final fullUrl = uri.toString();
    final relativePath = fullUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativePath);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      final List<dynamic> data = responseBody['data'] ?? [];
      return data.map((json) => ExpertModel.fromJson(json)).toList();
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load experts',
      );
    }
  }

  Future<int> toggleLikeReview(int reviewId) async {
    final relativeUrl = ApiConstants.getLikeReviewUrl(reviewId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody['likes'] ?? 0;
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to like review',
      );
    }
  }

  Future<Map<String, dynamic>> submitReview({
    required int expertId,
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    final relativeUrl = ApiConstants.submitReviewUrl(expertId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(
      relativeUrl,
      body: {
        'bookingId': bookingId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 201 && responseBody['success'] == true) {
      return responseBody;
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to submit review',
      );
    }
  }

  Future<List<dynamic>> getMyReviews() async {
    final relativeUrl = ApiConstants.myReviewsUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody['data'] ?? [];
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load reviews',
      );
    }
  }
}