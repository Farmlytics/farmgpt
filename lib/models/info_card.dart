import 'package:flutter/material.dart';

class InfoCard {
  final String id;
  final String title;
  final String description;
  final int priority;
  final String? icon;
  final String? actionText;
  final String? actionUrl;
  final bool isActive;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  InfoCard({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.icon,
    this.actionText,
    this.actionUrl,
    required this.isActive,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get color based on priority
  Color get priorityColor {
    switch (priority) {
      case 1:
        return const Color(0xFFE53E3E); // Red - Urgent
      case 2:
        return const Color(0xFFDD6B20); // Orange/Yellow - Moderate
      case 3:
        return const Color(0xFF38A169); // Green - Positive
      default:
        return const Color(0xFF718096); // Grey - Normal
    }
  }

  // Get priority label
  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'Urgent';
      case 2:
        return 'Moderate';
      case 3:
        return 'Good News';
      default:
        return 'Info';
    }
  }

  // Get icon data
  IconData get iconData {
    switch (icon) {
      case 'water_drop':
        return Icons.water_drop;
      case 'bug_report':
        return Icons.bug_report;
      case 'eco':
        return Icons.eco;
      case 'cloud_sync':
        return Icons.cloud;
      case 'agriculture':
        return Icons.agriculture;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'trending_up':
        return Icons.trending_up;
      case 'lightbulb':
        return Icons.lightbulb_outline;
      default:
        return Icons.info_outline;
    }
  }

  // Create from JSON
  factory InfoCard.fromJson(Map<String, dynamic> json) {
    return InfoCard(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as int,
      icon: json['icon'] as String?,
      actionText: json['action_text'] as String?,
      actionUrl: json['action_url'] as String?,
      isActive: json['is_active'] as bool,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'icon': icon,
      'action_text': actionText,
      'action_url': actionUrl,
      'is_active': isActive,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
