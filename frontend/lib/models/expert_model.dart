import 'package:flutter/material.dart';

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
  // New fields for ExpertProfileScreen
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
      'avatarColor': avatarColor..r,
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
      avatarColor: json['avatarColor'] != null
          ? Color(int.parse(json['avatarColor'].toString()))
          : const Color(0xFF0F9D58),
      isOnline: json['isOnline'] ?? true,
      title: json['title'] ?? 'Expert',
      company: json['company'] ?? 'Company',
      reviews: json['reviews'] ?? 120,
      pricePerHour: json['pricePerHour'] ?? json['price'] ?? 0,
      location: json['location'] ?? 'San Francisco, CA',
      services: List<String>.from(json['services'] ??
          ['1:1 Session', 'Code Review', 'Project Consultation']),
    );
  }
}
