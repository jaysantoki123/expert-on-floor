class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? token;
  final String? refreshToken;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.token,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'learner',
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}
