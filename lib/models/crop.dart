import 'package:flutter/material.dart';

class Crop {
  final String id;
  final String name;
  final String? scientificName;
  final String? iconUrl;
  final String category;
  final String? plantingSeason;
  final int? harvestTimeDays;
  final String? waterRequirement;
  final String? sunlightRequirement;
  final String? soilType;
  final String? fertilizerType;
  final List<String> pestCommon;
  final List<String> diseasesCommon;
  final List<String> companionPlants;
  final String? description;
  final String? growingTips;
  final String? harvestTips;
  final String? storageTips;
  final String? nutritionalBenefits;
  final double? marketPricePerKg;
  final double? yieldPerSqm;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Crop({
    required this.id,
    required this.name,
    this.scientificName,
    this.iconUrl,
    required this.category,
    this.plantingSeason,
    this.harvestTimeDays,
    this.waterRequirement,
    this.sunlightRequirement,
    this.soilType,
    this.fertilizerType,
    required this.pestCommon,
    required this.diseasesCommon,
    required this.companionPlants,
    this.description,
    this.growingTips,
    this.harvestTips,
    this.storageTips,
    this.nutritionalBenefits,
    this.marketPricePerKg,
    this.yieldPerSqm,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if crop has icon URL
  bool get hasIcon => iconUrl != null && iconUrl!.isNotEmpty;

  // Get category color
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return const Color(0xFF4CAF50); // Green
      case 'fruits':
        return const Color(0xFFFF9800); // Orange
      case 'grains':
        return const Color(0xFFFFEB3B); // Yellow
      case 'herbs':
        return const Color(0xFF8BC34A); // Light Green
      case 'roots':
        return const Color(0xFF795548); // Brown
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  // Get water requirement color
  Color get waterRequirementColor {
    switch (waterRequirement?.toLowerCase()) {
      case 'low':
        return const Color(0xFFFFEB3B); // Yellow
      case 'moderate':
        return const Color(0xFF2196F3); // Blue
      case 'high':
        return const Color(0xFF3F51B5); // Indigo
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Get sunlight requirement icon
  IconData get sunlightIcon {
    switch (sunlightRequirement?.toLowerCase()) {
      case 'full_sun':
        return Icons.wb_sunny;
      case 'partial_sun':
        return Icons.wb_cloudy;
      case 'shade':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }

  // Get planting season icon
  IconData get seasonIcon {
    switch (plantingSeason?.toLowerCase()) {
      case 'spring':
        return Icons.local_florist;
      case 'summer':
        return Icons.wb_sunny;
      case 'fall':
        return Icons.eco;
      case 'winter':
        return Icons.ac_unit;
      case 'year-round':
        return Icons.all_inclusive;
      default:
        return Icons.calendar_today;
    }
  }

  // Format harvest time
  String get harvestTimeFormatted {
    if (harvestTimeDays == null) return 'Unknown';
    if (harvestTimeDays! < 30) return '$harvestTimeDays days';
    if (harvestTimeDays! < 365) {
      final weeks = (harvestTimeDays! / 7).round();
      return '$weeks weeks';
    }
    final months = (harvestTimeDays! / 30).round();
    return '$months months';
  }

  // Format market price
  String get marketPriceFormatted {
    if (marketPricePerKg == null) return 'N/A';
    return '₹${marketPricePerKg!.toStringAsFixed(2)}/kg';
  }

  // Format yield
  String get yieldFormatted {
    if (yieldPerSqm == null) return 'N/A';
    return '${yieldPerSqm!.toStringAsFixed(1)} kg/m²';
  }

  // Create from JSON
  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String?,
      iconUrl: json['icon_url'] as String?,
      category: json['category'] as String,
      plantingSeason: json['planting_season'] as String?,
      harvestTimeDays: json['harvest_time_days'] as int?,
      waterRequirement: json['water_requirement'] as String?,
      sunlightRequirement: json['sunlight_requirement'] as String?,
      soilType: json['soil_type'] as String?,
      fertilizerType: json['fertilizer_type'] as String?,
      pestCommon: List<String>.from(json['pest_common'] ?? []),
      diseasesCommon: List<String>.from(json['diseases_common'] ?? []),
      companionPlants: List<String>.from(json['companion_plants'] ?? []),
      description: json['description'] as String?,
      growingTips: json['growing_tips'] as String?,
      harvestTips: json['harvest_tips'] as String?,
      storageTips: json['storage_tips'] as String?,
      nutritionalBenefits: json['nutritional_benefits'] as String?,
      marketPricePerKg: json['market_price_per_kg'] != null
          ? double.parse(json['market_price_per_kg'].toString())
          : null,
      yieldPerSqm: json['yield_per_sqm'] != null
          ? double.parse(json['yield_per_sqm'].toString())
          : null,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'icon_url': iconUrl,
      'category': category,
      'planting_season': plantingSeason,
      'harvest_time_days': harvestTimeDays,
      'water_requirement': waterRequirement,
      'sunlight_requirement': sunlightRequirement,
      'soil_type': soilType,
      'fertilizer_type': fertilizerType,
      'pest_common': pestCommon,
      'diseases_common': diseasesCommon,
      'companion_plants': companionPlants,
      'description': description,
      'growing_tips': growingTips,
      'harvest_tips': harvestTips,
      'storage_tips': storageTips,
      'nutritional_benefits': nutritionalBenefits,
      'market_price_per_kg': marketPricePerKg,
      'yield_per_sqm': yieldPerSqm,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Crop copyWith({
    String? name,
    String? scientificName,
    String? iconUrl,
    String? category,
    String? plantingSeason,
    int? harvestTimeDays,
    String? waterRequirement,
    String? sunlightRequirement,
    String? soilType,
    String? fertilizerType,
    List<String>? pestCommon,
    List<String>? diseasesCommon,
    List<String>? companionPlants,
    String? description,
    String? growingTips,
    String? harvestTips,
    String? storageTips,
    String? nutritionalBenefits,
    double? marketPricePerKg,
    double? yieldPerSqm,
    bool? isActive,
  }) {
    return Crop(
      id: id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      iconUrl: iconUrl ?? this.iconUrl,
      category: category ?? this.category,
      plantingSeason: plantingSeason ?? this.plantingSeason,
      harvestTimeDays: harvestTimeDays ?? this.harvestTimeDays,
      waterRequirement: waterRequirement ?? this.waterRequirement,
      sunlightRequirement: sunlightRequirement ?? this.sunlightRequirement,
      soilType: soilType ?? this.soilType,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      pestCommon: pestCommon ?? this.pestCommon,
      diseasesCommon: diseasesCommon ?? this.diseasesCommon,
      companionPlants: companionPlants ?? this.companionPlants,
      description: description ?? this.description,
      growingTips: growingTips ?? this.growingTips,
      harvestTips: harvestTips ?? this.harvestTips,
      storageTips: storageTips ?? this.storageTips,
      nutritionalBenefits: nutritionalBenefits ?? this.nutritionalBenefits,
      marketPricePerKg: marketPricePerKg ?? this.marketPricePerKg,
      yieldPerSqm: yieldPerSqm ?? this.yieldPerSqm,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
