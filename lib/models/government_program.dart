import 'package:flutter/material.dart';

class GovernmentProgram {
  final String id;
  final String name;
  final String description;
  final String eligibility;
  final String benefits;
  final String applicationProcess;
  final String imageUrl;
  final String
  category; // 'subsidy', 'loan', 'training', 'insurance', 'equipment'
  final String status; // 'active', 'upcoming', 'closed'
  final double? maxAmount;
  final String? deadline;
  final List<String> targetCrops;
  final String department;
  final String contactInfo;
  final String website;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  GovernmentProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.eligibility,
    required this.benefits,
    required this.applicationProcess,
    required this.imageUrl,
    required this.category,
    required this.status,
    this.maxAmount,
    this.deadline,
    required this.targetCrops,
    required this.department,
    required this.contactInfo,
    required this.website,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GovernmentProgram.fromJson(Map<String, dynamic> json) {
    return GovernmentProgram(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      eligibility: json['eligibility'] ?? '',
      benefits: json['benefits'] ?? '',
      applicationProcess: json['application_process'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'subsidy',
      status: json['status'] ?? 'active',
      maxAmount: json['max_amount']?.toDouble(),
      deadline: json['deadline'],
      targetCrops: List<String>.from(json['target_crops'] ?? []),
      department: json['department'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      website: json['website'] ?? '',
      isActive: json['is_active'] ?? true,
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
      'eligibility': eligibility,
      'benefits': benefits,
      'application_process': applicationProcess,
      'image_url': imageUrl,
      'category': category,
      'status': status,
      'max_amount': maxAmount,
      'deadline': deadline,
      'target_crops': targetCrops,
      'department': department,
      'contact_info': contactInfo,
      'website': website,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'subsidy':
        return const Color(0xFF10B981); // Green
      case 'loan':
        return const Color(0xFF3B82F6); // Blue
      case 'training':
        return const Color(0xFF8B5CF6); // Purple
      case 'insurance':
        return const Color(0xFFF59E0B); // Orange
      case 'equipment':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'subsidy':
        return 'Subsidy';
      case 'loan':
        return 'Loan';
      case 'training':
        return 'Training';
      case 'insurance':
        return 'Insurance';
      case 'equipment':
        return 'Equipment';
      default:
        return 'Program';
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'subsidy':
        return Icons.account_balance_wallet;
      case 'loan':
        return Icons.credit_card;
      case 'training':
        return Icons.school;
      case 'insurance':
        return Icons.security;
      case 'equipment':
        return Icons.agriculture;
      default:
        return Icons.help_outline;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981); // Green
      case 'upcoming':
        return const Color(0xFF3B82F6); // Blue
      case 'closed':
        return const Color(0xFF6B7280); // Gray
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'upcoming':
        return 'Upcoming';
      case 'closed':
        return 'Closed';
      default:
        return 'Unknown';
    }
  }

  bool get hasImage {
    return imageUrl.isNotEmpty;
  }

  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }

  String get targetCropsText {
    if (targetCrops.isEmpty) return 'All crops';
    if (targetCrops.length == 1) return targetCrops.first;
    if (targetCrops.length <= 3) return targetCrops.join(', ');
    return '${targetCrops.take(2).join(', ')} +${targetCrops.length - 2} more';
  }

  String get formattedAmount {
    if (maxAmount == null) return 'Varies';
    return '₹${maxAmount!.toStringAsFixed(0)}';
  }

  bool get isUrgent {
    if (deadline == null) return false;
    try {
      final deadlineDate = DateTime.parse(deadline!);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now).inDays;
      return difference <= 30 &&
          difference >= 0; // Urgent if deadline is within 30 days
    } catch (e) {
      return false;
    }
  }
}
