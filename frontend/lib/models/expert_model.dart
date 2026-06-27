import 'package:flutter/material.dart';

class ExpertModel {
  final String id;
  final String? userId;
  final String name;
  final String role;
  final String? profileImage;
  final String experience;
  final double rating;
  final int price;
  final List<String> skills;
  final String bio;
  final Color avatarColor;
  final bool isOnline;
  final String title;
  final String company;
  final int reviews;
  final int pricePerHour;
  final String location;
  final List<String> services;

  ExpertModel({
    required this.id,
    this.userId,
    required this.name,
    required this.role,
    this.profileImage,
    required this.experience,
    required this.rating,
    required this.price,
    required this.skills,
    required this.bio,
    // Default values for new fields
    this.avatarColor = const Color(0xFF0F9D58),
    this.isOnline = true,
    required this.title,
    this.company = 'Company',
    this.reviews = 120,
    required this.pricePerHour,
    this.location = 'San Francisco, CA',
    this.services = const ['1:1 Session', 'Code Review', 'Project Consultation'],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'experience': experience,
      'rating': rating,
      'price': price,
      'skills': skills,
      'bio': bio,
      'avatarColor': avatarColor.value,
      'isOnline': isOnline,
      'title': title,
      'company': company,
      'reviews': reviews,
      'pricePerHour': pricePerHour,
      'location': location,
      'services': services,
    };
  }

  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;
    final uId = json['userId']?.toString() ?? userMap?['id']?.toString();
    final name = json['name'] ?? userMap?['name'] ?? 'Unknown';
    final profileImage = json['profileImage'] ?? userMap?['profileImage'];
    
    final ratingVal = json['rating'] ?? json['avgRating'] ?? 0.0;
    final rating = (ratingVal is num) ? ratingVal.toDouble() : double.tryParse(ratingVal.toString()) ?? 0.0;
    
    final priceVal = json['price'] ?? json['pricePerHour'] ?? 0;
    final price = (priceVal is num) ? priceVal.toInt() : int.tryParse(priceVal.toString()) ?? 0;

    final expYears = json['experienceYears'] ?? 0;
    final experience = json['experience'] ?? '${expYears}+ years';

    // Parse avatarColor
    Color color = const Color(0xFF0F9D58);
    if (json['avatarColor'] != null) {
      if (json['avatarColor'] is int) {
        color = Color(json['avatarColor']);
      } else if (json['avatarColor'] is String) {
        final hexStr = (json['avatarColor'] as String).replaceAll('#', '');
        final val = int.tryParse(hexStr, radix: 16);
        if (val != null) {
          color = Color(val);
        }
      }
    }

    return ExpertModel(
      id: json['id']?.toString() ?? '',
      userId: uId,
      name: name,
      role: json['role'] ?? json['title'] ?? 'Software Engineer',
      profileImage: profileImage,
      experience: experience,
      rating: rating,
      price: price,
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'] ?? '',
      avatarColor: color,
      isOnline: json['isOnline'] ?? true,
      title: json['title'] ?? 'Expert',
      company: json['company'] ?? 'Company',
      reviews: json['reviews'] ?? 120,
      pricePerHour: json['pricePerHour'] ?? price,
      location: json['location'] ?? 'San Francisco, CA',
      services: List<String>.from(json['services'] ??
          ['1:1 Session', 'Code Review', 'Project Consultation']),
    );
  }
}
