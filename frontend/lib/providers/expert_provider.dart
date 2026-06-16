import 'package:flutter/material.dart';
import '../models/expert_model.dart';
import '../services/expert_service.dart';

class ExpertProvider with ChangeNotifier {
  final ExpertService _expertService = ExpertService();
  
  List<ExpertModel> _experts = [];
  bool _isLoading = false;
  String? _error;

  List<ExpertModel> get experts => _experts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cache flag to prevent unnecessary calls during the session
  bool _isFetched = false;

  Future<void> fetchExperts({bool forceRefresh = false}) async {
    if (_isFetched && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _experts = await _expertService.getExperts();
      _isFetched = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cache (useful for logout)
  void clearCache() {
    _experts = [];
    _isFetched = false;
    notifyListeners();
  }
}
