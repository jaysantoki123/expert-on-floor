import 'user_role.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? profileImage;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: UserRole.fromString(json['role'] ?? 'learner'),
      profileImage: json['profileImage'] ?? json['profile_image'] ?? json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.apiValue,
      'profileImage': profileImage,
    };
  }

  bool get isExpert => role.isExpert;
  bool get isAdmin => role.isAdmin;
  bool get isLearner => role.isLearner;
}
