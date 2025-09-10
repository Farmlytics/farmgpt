import 'package:flutter/material.dart';

class Weather {
  final String location;
  final double temperature;
  final String description;
  final String iconUrl;
  final int humidity;
  final double windSpeed;
  final DateTime timestamp;

  Weather({
    required this.location,
    required this.temperature,
    required this.description,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    required this.timestamp,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: json['location'] ?? 'Unknown',
      temperature: (json['temperature'] ?? 0).toDouble(),
      description: json['description'] ?? 'No description',
      iconUrl: json['iconUrl'] ?? '',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'description': description,
      'iconUrl': iconUrl,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get formattedTemp {
    return '${temperature.round()}°C';
  }

  String get capitalizedDescription {
    return description
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  Color get backgroundColor {
    // Return different colors based on weather conditions
    final desc = description.toLowerCase();

    if (desc.contains('sunny') || desc.contains('clear')) {
      return const Color(0xFFFF9800); // Orange for sunny
    } else if (desc.contains('cloud')) {
      return const Color(0xFF607D8B); // Blue grey for cloudy
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return const Color(0xFF2196F3); // Blue for rainy
    } else if (desc.contains('storm') || desc.contains('thunder')) {
      return const Color(0xFF673AB7); // Purple for stormy
    } else if (desc.contains('snow')) {
      return const Color(0xFF9E9E9E); // Grey for snowy
    } else if (desc.contains('mist') || desc.contains('fog')) {
      return const Color(0xFF795548); // Brown for misty
    } else {
      return const Color(0xFF4CAF50); // Default green
    }
  }

  String get weatherMessage {
    final desc = description.toLowerCase();
    final temp = temperature.round();

    if (desc.contains('sunny') || desc.contains('clear')) {
      if (temp > 30) {
        return 'Perfect weather for irrigation! Stay hydrated.';
      } else if (temp > 20) {
        return 'Great day for outdoor farm work!';
      } else {
        return 'Cool and clear - ideal for planting.';
      }
    } else if (desc.contains('cloud')) {
      return 'Overcast conditions - good for transplanting.';
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return 'Natural watering day! Check drainage systems.';
    } else if (desc.contains('storm') || desc.contains('thunder')) {
      return 'Secure equipment and check for crop damage.';
    } else if (desc.contains('snow')) {
      return 'Protect sensitive crops from frost.';
    } else if (desc.contains('mist') || desc.contains('fog')) {
      return 'High humidity - monitor for plant diseases.';
    } else {
      return 'Monitor weather conditions for farm planning.';
    }
  }
}
