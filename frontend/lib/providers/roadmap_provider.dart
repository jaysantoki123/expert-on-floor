import 'package:flutter/material.dart';
import '../models/roadmap_model.dart';
import '../services/roadmap_service.dart';

class RoadmapProvider with ChangeNotifier {
  final RoadmapService _roadmapService = RoadmapService();

  RoadmapModel? _myRoadmap;
  PhaseModel? _currentPhase;
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _isCompleting = false;
  String? _error;

  RoadmapModel? get myRoadmap => _myRoadmap;
  RoadmapModel? get roadmap => _myRoadmap; // Alias for compatibility
  PhaseModel? get currentPhase => _currentPhase;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  bool get isCompleting => _isCompleting;
  String? get error => _error;

  Future<void> fetchMyRoadmap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myRoadmap = await _roadmapService.getMyRoadmap();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RoadmapModel> generateRoadmap({
    required String goal,
    required String currentLevel,
    required int timeAvailableWeekly,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final roadmap = await _roadmapService.generateRoadmap(
        goal: goal,
        currentLevel: currentLevel,
        timeAvailableWeekly: timeAvailableWeekly,
      );
      _myRoadmap = roadmap;
      _isGenerating = false;
      notifyListeners();
      return roadmap;
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<PhaseModel> getPhaseDetail(int phaseId) async {
    return await _roadmapService.getPhaseDetail(phaseId);
  }

  // Alias for compatibility with UI screens
  Future<void> fetchPhaseDetail(int phaseId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentPhase = await _roadmapService.getPhaseDetail(phaseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> completePhase(int phaseId) async {
    _isCompleting = true;
    notifyListeners();
    
    try {
      final result = await _roadmapService.completePhase(phaseId);
      final progress = result['progressPercent'] ?? 0;
      
      if (_myRoadmap != null) {
        final phases = List<PhaseModel>.from(_myRoadmap!.phases);
        final index = phases.indexWhere((p) => p.id == phaseId);
        if (index != -1) {
          phases[index] = phases[index].copyWith(isCompleted: true);
          
          // Calculate new progress percent
          final newProgressPercent = (phases.where((p) => p.isCompleted).length / phases.length * 100).round();
          
          _myRoadmap = _myRoadmap!.copyWith(
            phases: phases,
            progressPercent: newProgressPercent,
          );
        }
      }
      _isCompleting = false;
      notifyListeners();
      
      return progress;
    } catch (e) {
      _error = e.toString();
      _isCompleting = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}