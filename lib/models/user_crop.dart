import 'package:farmlytics/models/crop.dart';

class UserCrop {
  final String id;
  final String userId;
  final String cropId;
  final DateTime? plantingDate;
  final DateTime? expectedHarvestDate;
  final double? areaPlanted;
  final String status;
  final String? notes;
  final double? actualYield;
  final int? qualityRating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional: Include the crop details
  final Crop? crop;

  UserCrop({
    required this.id,
    required this.userId,
    required this.cropId,
    this.plantingDate,
    this.expectedHarvestDate,
    this.areaPlanted,
    required this.status,
    this.notes,
    this.actualYield,
    this.qualityRating,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.crop,
  });

  // Status colors
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'planned':
        return '#9E9E9E'; // Grey
      case 'planted':
        return '#4CAF50'; // Green
      case 'growing':
        return '#2196F3'; // Blue
      case 'harvesting':
        return '#FF9800'; // Orange
      case 'harvested':
        return '#8BC34A'; // Light Green
      default:
        return '#607D8B'; // Blue Grey
    }
  }

  // Status emoji
  String get statusEmoji {
    switch (status.toLowerCase()) {
      case 'planned':
        return '📋';
      case 'planted':
        return '🌱';
      case 'growing':
        return '🌿';
      case 'harvesting':
        return '✂️';
      case 'harvested':
        return '📦';
      default:
        return '❓';
    }
  }

  // Days until harvest (if planted)
  int? get daysUntilHarvest {
    if (expectedHarvestDate == null) return null;
    final now = DateTime.now();
    final difference = expectedHarvestDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  // Days since planting
  int? get daysSincePlanting {
    if (plantingDate == null) return null;
    final now = DateTime.now();
    return now.difference(plantingDate!).inDays;
  }

  // Format area planted
  String get areaPlantedFormatted {
    if (areaPlanted == null) return 'N/A';
    return '${areaPlanted!.toStringAsFixed(1)} m²';
  }

  // Format actual yield
  String get actualYieldFormatted {
    if (actualYield == null) return 'N/A';
    return '${actualYield!.toStringAsFixed(1)} kg';
  }

  // Quality rating stars
  String get qualityStars {
    if (qualityRating == null) return 'Not rated';
    return '★' * qualityRating! + '☆' * (5 - qualityRating!);
  }

  // Create from JSON
  factory UserCrop.fromJson(Map<String, dynamic> json) {
    return UserCrop(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cropId: json['crop_id'] as String,
      plantingDate: json['planting_date'] != null
          ? DateTime.parse(json['planting_date'] as String)
          : null,
      expectedHarvestDate: json['expected_harvest_date'] != null
          ? DateTime.parse(json['expected_harvest_date'] as String)
          : null,
      areaPlanted: json['area_planted'] != null
          ? double.parse(json['area_planted'].toString())
          : null,
      status: json['status'] as String? ?? 'planned',
      notes: json['notes'] as String?,
      actualYield: json['actual_yield'] != null
          ? double.parse(json['actual_yield'].toString())
          : null,
      qualityRating: json['quality_rating'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      crop: json['crops'] != null ? Crop.fromJson(json['crops']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'crop_id': cropId,
      'planting_date': plantingDate?.toIso8601String(),
      'expected_harvest_date': expectedHarvestDate?.toIso8601String(),
      'area_planted': areaPlanted,
      'status': status,
      'notes': notes,
      'actual_yield': actualYield,
      'quality_rating': qualityRating,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserCrop copyWith({
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    double? areaPlanted,
    String? status,
    String? notes,
    double? actualYield,
    int? qualityRating,
    bool? isActive,
    Crop? crop,
  }) {
    return UserCrop(
      id: id,
      userId: userId,
      cropId: cropId,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      areaPlanted: areaPlanted ?? this.areaPlanted,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      actualYield: actualYield ?? this.actualYield,
      qualityRating: qualityRating ?? this.qualityRating,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      crop: crop ?? this.crop,
    );
  }
}
