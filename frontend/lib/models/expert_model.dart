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
  // New fields for ExpertProfileScreen
  final Color avatarColor;
  final bool isOnline;
  final String title;
  final String company;
  final int reviews;
  final int pricePerHour;
  final String location;
  final List<String> services;
  final Map<String, List<String>> availability;

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
    this.availability = const {},
  });

  // Compatibility getters
  String get category => title; // Use title as category fallback
  double get avgRating => rating;
  int get expertId => int.tryParse(id) ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'experience': experience,
      'rating': rating,
      'price': price,
      'skills': skills,
      'bio': bio,
      'avatarColor': avatarColor.toARGB32(),
      'isOnline': isOnline,
      'title': title,
      'company': company,
      'reviews': reviews,
      'pricePerHour': pricePerHour,
      'location': location,
      'services': services,
      'availability': availability,
    };
  }

  static Map<String, List<String>> _parseAvailability(dynamic jsonVal) {
    if (jsonVal == null) return const {};
    try {
      final Map<String, dynamic> map = Map<String, dynamic>.from(jsonVal);
      return map.map((key, value) {
        final list = List<String>.from(value ?? []);
        return MapEntry(key, list);
      });
    } catch (e) {
      return const {};
    }
  }

  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    return ExpertModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      name: json['name'] ?? 'Unknown',
      role: json['role'] ?? 'Software Engineer',
      profileImage: json['profileImage'],
      experience: json['experience'] ?? 'New Expert',
      rating: json['avgRating'] != null
          ? double.tryParse(json['avgRating'].toString()) ?? 0.0
          : (json['rating'] ?? 0.0).toDouble(),
      price: json['pricePerHour'] ?? json['price'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'] ?? '',
      avatarColor: json['avatarColor'] != null
          ? Color(int.parse(json['avatarColor'].toString()))
          : const Color(0xFF0F9D58),
      isOnline: json['isOnline'] ?? true,
      title: json['title'] ?? 'Expert',
      company: json['company'] ?? 'Company',
      reviews: json['totalReviews'] ?? json['reviews'] ?? 0,
      pricePerHour: json['pricePerHour'] ?? json['price'] ?? 0,
      location: json['location'] ?? 'San Francisco, CA',
      services: List<String>.from(json['services'] ??
          ['1:1 Session', 'Code Review', 'Project Consultation']),
      availability: _parseAvailability(json['availability']),
    );
  }
}
