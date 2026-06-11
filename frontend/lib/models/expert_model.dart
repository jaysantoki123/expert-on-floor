class ExpertModel {
  final String id;
  final String name;
  final String role;
  final String? profileImage;
  final String experience;
  final double rating;
  final int price;
  final List<String> skills;
  final String bio;

  ExpertModel({
    required this.id,
    required this.name,
    required this.role,
    this.profileImage,
    required this.experience,
    required this.rating,
    required this.price,
    required this.skills,
    required this.bio,
  });

  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    return ExpertModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      role: json['role'] ?? 'Software Engineer',
      profileImage: json['profileImage'],
      experience: json['experience'] ?? 'New Expert',
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: json['price'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'] ?? '',
    );
  }
}
