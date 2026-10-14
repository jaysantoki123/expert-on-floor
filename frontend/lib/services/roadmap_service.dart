import 'dart:convert';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/roadmap_model.dart';
import '../utils/api_constants.dart';

class RoadmapService {
  final _apiClient = ApiClient();

  Future<RoadmapModel> generateRoadmap({
    required String goal,
    required String currentLevel,
    required int timeAvailableWeekly,
  }) async {
    final relativeUrl = ApiConstants.generateRoadmapUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(
      relativeUrl,
      body: {
        'goal': goal,
        'currentLevel': currentLevel,
        'timeAvailableWeekly': timeAvailableWeekly,
      },
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return RoadmapModel.fromJson(responseBody['data'] ?? {});
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to generate roadmap',
      );
    }
  }

  Future<RoadmapModel> getMyRoadmap() async {
    final relativeUrl = ApiConstants.myRoadmapUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return RoadmapModel.fromJson(responseBody['data'] ?? {});
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load roadmap',
      );
    }
  }

  Future<PhaseModel> getPhaseDetail(int phaseId) async {
    final relativeUrl = ApiConstants.getPhaseDetailUrl(phaseId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return PhaseModel.fromJson(responseBody['data'] ?? {});
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to load phase details',
      );
    }
  }

  Future<Map<String, dynamic>> completePhase(int phaseId) async {
    final relativeUrl = ApiConstants.getCompletePhaseUrl(phaseId).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.patch(relativeUrl);

    final responseBody = jsonDecode(response.body);
    if (responseBody['success'] == true) {
      return responseBody['data'] ?? {};
    } else {
      throw UnknownException(
        responseBody['message'] ?? 'Failed to complete phase',
      );
    }
  }
}