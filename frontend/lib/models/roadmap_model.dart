class ResourceModel {
  final String type;
  final String title;
  final String url;

  ResourceModel({
    required this.type,
    required this.title,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'url': url,
    };
  }

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class PhaseModel {
  final int id;
  final String title;
  final int durationWeeks;
  final String difficulty;
  final String description;
  final List<String> topics;
  final List<String> skills;
  final List<dynamic> projects;
  final List<ResourceModel> resources;
  final List<String> tips;
  final bool isCompleted;
  final DateTime? completedAt;

  PhaseModel({
    required this.id,
    required this.title,
    required this.durationWeeks,
    required this.difficulty,
    required this.description,
    required this.topics,
    required this.skills,
    required this.projects,
    required this.resources,
    required this.tips,
    required this.isCompleted,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationWeeks': durationWeeks,
      'difficulty': difficulty,
      'description': description,
      'topics': topics,
      'skills': skills,
      'projects': projects,
      'resources': resources.map((e) => e.toJson()).toList(),
      'tips': tips,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory PhaseModel.fromJson(Map<String, dynamic> json) {
    return PhaseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      durationWeeks: json['durationWeeks'] ?? 0,
      difficulty: json['difficulty'] ?? '',
      description: json['description'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      projects: json['projects'] ?? [],
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => ResourceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tips: List<String>.from(json['tips'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }

  PhaseModel copyWith({
    int? id,
    String? title,
    int? durationWeeks,
    String? difficulty,
    String? description,
    List<String>? topics,
    List<String>? skills,
    List<dynamic>? projects,
    List<ResourceModel>? resources,
    List<String>? tips,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return PhaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      topics: topics ?? this.topics,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      resources: resources ?? this.resources,
      tips: tips ?? this.tips,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class RoadmapModel {
  final int? id;
  final int? userId;
  final String? goal;
  final String title;
  final String description;
  final String? currentLevel;
  final int? timeAvailableWeekly;
  final int totalWeeks;
  final int progressPercent;
  final List<PhaseModel> phases;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoadmapModel({
    this.id,
    this.userId,
    this.goal,
    required this.title,
    required this.description,
    this.currentLevel,
    this.timeAvailableWeekly,
    required this.totalWeeks,
    required this.progressPercent,
    required this.phases,
    this.createdAt,
    this.updatedAt,
  });

  int get completedSteps => phases.where((p) => p.isCompleted).length;
  int get totalSteps => phases.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'goal': goal,
      'title': title,
      'description': description,
      'currentLevel': currentLevel,
      'timeAvailableWeekly': timeAvailableWeekly,
      'totalWeeks': totalWeeks,
      'progressPercent': progressPercent,
      'phases': phases.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      id: json['id'],
      userId: json['userId'],
      goal: json['goal'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      currentLevel: json['currentLevel'],
      timeAvailableWeekly: json['timeAvailableWeekly'],
      totalWeeks: json['totalWeeks'] ?? 0,
      progressPercent: json['progressPercent'] ?? 0,
      phases: (json['phases'] as List<dynamic>?)
              ?.map((e) => PhaseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  RoadmapModel copyWith({
    int? id,
    int? userId,
    String? goal,
    String? title,
    String? description,
    String? currentLevel,
    int? timeAvailableWeekly,
    int? totalWeeks,
    int? progressPercent,
    List<PhaseModel>? phases,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoadmapModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goal: goal ?? this.goal,
      title: title ?? this.title,
      description: description ?? this.description,
      currentLevel: currentLevel ?? this.currentLevel,
      timeAvailableWeekly: timeAvailableWeekly ?? this.timeAvailableWeekly,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      progressPercent: progressPercent ?? this.progressPercent,
      phases: phases ?? this.phases,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
