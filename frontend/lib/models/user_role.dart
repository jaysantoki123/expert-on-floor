import 'package:flutter/foundation.dart';

enum UserRole {
  learner,
  expert,
  admin;

  String get apiValue => name;

  bool get isLearner => this == UserRole.learner;
  bool get isExpert => this == UserRole.expert;
  bool get isAdmin => this == UserRole.admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'expert':
        return UserRole.expert;
      case 'admin':
        return UserRole.admin;
      case 'learner':
        return UserRole.learner;
      default:
        // ponytail: log unexpected role fallback to prevent silent privilege misassignments
        debugPrint('⚠️ Warning: Unknown role "$role" encountered. Falling back to learner.');
        return UserRole.learner;
    }
  }
}