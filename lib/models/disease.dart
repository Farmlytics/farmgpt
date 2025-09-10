import 'package:flutter/material.dart';

class Disease {
  final String id;
  final String name;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final String imageUrl;
  final String severity; // 'mild', 'moderate', 'severe'
  final List<String> affectedCrops;
  final bool isCommon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Disease({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.imageUrl,
    required this.severity,
    required this.affectedCrops,
    required this.isCommon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      symptoms: json['symptoms'] ?? '',
      treatment: json['treatment'] ?? '',
      prevention: json['prevention'] ?? '',
      imageUrl: json['image_url'] ?? '',
      severity: json['severity'] ?? 'mild',
      affectedCrops: List<String>.from(json['affected_crops'] ?? []),
      isCommon: json['is_common'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
      'image_url': imageUrl,
      'severity': severity,
      'affected_crops': affectedCrops,
      'is_common': isCommon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'severe':
        return const Color(0xFFE53E3E); // Red
      case 'moderate':
        return const Color(0xFFED8936); // Orange
      case 'mild':
        return const Color(0xFFECC94B); // Yellow
      default:
        return const Color(0xFF9CA3AF); // Gray
    }
  }

  String get severityLabel {
    switch (severity.toLowerCase()) {
      case 'severe':
        return 'High Risk';
      case 'moderate':
        return 'Medium Risk';
      case 'mild':
        return 'Low Risk';
      default:
        return 'Unknown';
    }
  }

  IconData get severityIcon {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Icons.warning;
      case 'moderate':
        return Icons.error_outline;
      case 'mild':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  bool get hasImage {
    return imageUrl.isNotEmpty;
  }

  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  String get affectedCropsText {
    if (affectedCrops.isEmpty) return 'All crops';
    if (affectedCrops.length == 1) return affectedCrops.first;
    if (affectedCrops.length <= 3) return affectedCrops.join(', ');
    return '${affectedCrops.take(2).join(', ')} +${affectedCrops.length - 2} more';
  }
}
