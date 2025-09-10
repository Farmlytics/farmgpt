import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmlytics/models/info_card.dart';
import 'package:farmlytics/models/crop.dart';
import 'package:farmlytics/models/user_crop.dart';
import 'package:farmlytics/models/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? get currentUser => Supabase.instance.client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Initialize Supabase
  static Future<void> initialize() async {
    // Get Supabase credentials from environment variables
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Supabase credentials not found. Please check your .env file and ensure '
        'SUPABASE_URL and SUPABASE_ANON_KEY are set correctly.',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );
      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      notifyListeners();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Send OTP to phone number
  Future<void> signInWithPhone({required String phone}) async {
    try {
      final normalized = _normalizePhone(phone);
      await Supabase.instance.client.auth.signInWithOtp(phone: normalized);
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  // Verify OTP code for phone sign-in
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
    String? name,
  }) async {
    try {
      final normalized = _normalizePhone(phone);
      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: normalized,
        token: token,
        type: OtpType.sms,
      );

      // If this is a sign up (name provided), save the user's name
      if (name != null && name.isNotEmpty && response.user != null) {
        await _saveUserProfile(response.user!.id, name, normalized);
      }

      notifyListeners();
      return response;
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  // Check if user is new (has no profile data)
  Future<bool> isNewUser() async {
    try {
      if (currentUser == null) return true;

      final profile = await getUserProfile();
      return profile == null;
    } catch (e) {
      return true; // If we can't check, assume new user for safety
    }
  }

  // Save user profile to database
  Future<void> _saveUserProfile(
    String userId,
    String name,
    String phone,
  ) async {
    try {
      await Supabase.instance.client.from('user_profiles').upsert({
        'id': userId,
        'name': name,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save user profile: ${e.toString()}');
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response = await Supabase.instance.client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Get user name
  Future<String?> getUserName() async {
    try {
      final profile = await getUserProfile();
      return profile?['name'];
    } catch (e) {
      return null;
    }
  }

  String _normalizePhone(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('+')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '+91';
    return '+91$digits';
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Listen to auth state changes
  void startAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  // Get info cards for current user (personal + global cards)
  Future<List<InfoCard>> getInfoCards() async {
    try {
      final response = await Supabase.instance.client
          .from('info_cards')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false); // Most recent first

      final cards = (response as List)
          .map((json) => InfoCard.fromJson(json))
          .toList();

      // Custom sort: Red (1) first, then Green (3), Yellow (2), Grey (0)
      cards.sort((a, b) {
        final priorityOrder = {
          1: 0,
          3: 1,
          2: 2,
          0: 3,
        }; // Red first, then green, yellow, grey
        final aPriority = priorityOrder[a.priority] ?? 4;
        final bPriority = priorityOrder[b.priority] ?? 4;

        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }

        // If same priority, sort by created date (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

      return cards;
    } catch (e) {
      throw Exception('Failed to fetch info cards: ${e.toString()}');
    }
  }

  // Create a new info card
  Future<InfoCard> createInfoCard({
    required String title,
    required String description,
    required int priority,
    String? icon,
    String? actionText,
    String? actionUrl,
    String? userId,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('info_cards')
          .insert({
            'title': title,
            'description': description,
            'priority': priority,
            'icon': icon,
            'action_text': actionText,
            'action_url': actionUrl,
            'user_id': userId ?? currentUser?.id,
          })
          .select()
          .single();

      return InfoCard.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create info card: ${e.toString()}');
    }
  }

  // Mark info card as inactive (soft delete)
  Future<void> dismissInfoCard(String cardId) async {
    try {
      await Supabase.instance.client
          .from('info_cards')
          .update({'is_active': false})
          .eq('id', cardId);
    } catch (e) {
      throw Exception('Failed to dismiss info card: ${e.toString()}');
    }
  }

  // Get all crops
  Future<List<Crop>> getCrops({String? category}) async {
    try {
      var query = Supabase.instance.client
          .from('crops')
          .select()
          .eq('is_active', true);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query.order('name', ascending: true);

      return (response as List).map((json) => Crop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch crops: ${e.toString()}');
    }
  }

  // Get crop by ID
  Future<Crop?> getCropById(String cropId) async {
    try {
      final response = await Supabase.instance.client
          .from('crops')
          .select()
          .eq('id', cropId)
          .eq('is_active', true)
          .maybeSingle();

      return response != null ? Crop.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch crop: ${e.toString()}');
    }
  }

  // Search crops by name
  Future<List<Crop>> searchCrops(String searchTerm) async {
    try {
      final response = await Supabase.instance.client
          .from('crops')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$searchTerm%')
          .order('name', ascending: true);

      return (response as List).map((json) => Crop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search crops: ${e.toString()}');
    }
  }

  // Get crops by planting season
  Future<List<Crop>> getCropsByPlantingSeason(String season) async {
    try {
      final response = await Supabase.instance.client
          .from('crops')
          .select()
          .eq('is_active', true)
          .eq('planting_season', season)
          .order('name', ascending: true);

      return (response as List).map((json) => Crop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch crops by season: ${e.toString()}');
    }
  }

  // Get crop categories
  Future<List<String>> getCropCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('crops')
          .select('category')
          .eq('is_active', true);

      final categories = (response as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch crop categories: ${e.toString()}');
    }
  }

  // Add a new crop (for admin functionality)
  Future<Crop> addCrop({
    required String name,
    String? scientificName,
    String? iconUrl,
    required String category,
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
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('crops')
          .insert({
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
          })
          .select()
          .single();

      return Crop.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add crop: ${e.toString()}');
    }
  }

  // USER CROPS METHODS

  // Get user's crops with crop details
  Future<List<UserCrop>> getUserCrops() async {
    try {
      final response = await Supabase.instance.client
          .from('user_crops')
          .select('*, crops(*)')
          .eq('user_id', currentUser!.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => UserCrop.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user crops: ${e.toString()}');
    }
  }

  // Add crop to user's farm
  Future<UserCrop> addCropToUserFarm({
    required String cropId,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    double? areaPlanted,
    String status = 'planned',
    String? notes,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('user_crops')
          .insert({
            'user_id': currentUser!.id,
            'crop_id': cropId,
            'planting_date': plantingDate?.toIso8601String(),
            'expected_harvest_date': expectedHarvestDate?.toIso8601String(),
            'area_planted': areaPlanted,
            'status': status,
            'notes': notes,
          })
          .select('*, crops(*)')
          .single();

      return UserCrop.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add crop to user farm: ${e.toString()}');
    }
  }

  // Update user crop
  Future<UserCrop> updateUserCrop({
    required String userCropId,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    double? areaPlanted,
    String? status,
    String? notes,
    double? actualYield,
    int? qualityRating,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (plantingDate != null)
        updateData['planting_date'] = plantingDate.toIso8601String();
      if (expectedHarvestDate != null)
        updateData['expected_harvest_date'] = expectedHarvestDate
            .toIso8601String();
      if (areaPlanted != null) updateData['area_planted'] = areaPlanted;
      if (status != null) updateData['status'] = status;
      if (notes != null) updateData['notes'] = notes;
      if (actualYield != null) updateData['actual_yield'] = actualYield;
      if (qualityRating != null) updateData['quality_rating'] = qualityRating;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await Supabase.instance.client
          .from('user_crops')
          .update(updateData)
          .eq('id', userCropId)
          .eq('user_id', currentUser!.id)
          .select('*, crops(*)')
          .single();

      return UserCrop.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user crop: ${e.toString()}');
    }
  }

  // Remove crop from user's farm (soft delete)
  Future<void> removeCropFromUserFarm(String userCropId) async {
    try {
      await Supabase.instance.client
          .from('user_crops')
          .update({'is_active': false})
          .eq('id', userCropId)
          .eq('user_id', currentUser!.id);
    } catch (e) {
      throw Exception('Failed to remove crop from user farm: ${e.toString()}');
    }
  }

  // Check if user already has this crop
  Future<bool> userHasCrop(String cropId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_crops')
          .select('id')
          .eq('user_id', currentUser!.id)
          .eq('crop_id', cropId)
          .eq('is_active', true)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Weather API Integration
  Future<Weather> getWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Using OpenWeatherMap API (free tier)
      const apiKey =
          '5b9c5d5b5b5b5b5b5b5b5b5b5b5b5b5b'; // Replace with actual API key
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return Weather(
          location: data['name'] ?? 'Unknown Location',
          temperature: (data['main']['temp'] ?? 0).toDouble(),
          description: data['weather'][0]['description'] ?? 'No description',
          iconUrl:
              'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png',
          humidity: data['main']['humidity'] ?? 0,
          windSpeed: (data['wind']['speed'] ?? 0).toDouble(),
          timestamp: DateTime.now(),
        );
      } else {
        // Return mock data for demo purposes
        return _getMockWeatherData();
      }
    } catch (e) {
      print('Weather API error: $e');
      // Return mock data as fallback
      return _getMockWeatherData();
    }
  }

  Weather _getMockWeatherData() {
    // Mock weather data for demo
    return Weather(
      location: 'Farm Location',
      temperature: 24.0,
      description: 'partly cloudy',
      iconUrl: 'https://openweathermap.org/img/wn/02d@2x.png',
      humidity: 65,
      windSpeed: 3.5,
      timestamp: DateTime.now(),
    );
  }
}
