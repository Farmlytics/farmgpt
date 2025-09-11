import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmlytics/models/info_card.dart';
import 'package:farmlytics/models/crop.dart';
import 'package:farmlytics/models/user_crop.dart';
import 'package:farmlytics/models/weather.dart';
import 'package:farmlytics/models/disease.dart';
import 'package:farmlytics/models/government_program.dart';
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

  // Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      final profile = await getUserProfile();
      return profile?['onboarding_completed'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    try {
      if (currentUser == null) return;

      await Supabase.instance.client.from('user_profiles').upsert({
        'id': currentUser!.id,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception(
        'Failed to mark onboarding as completed: ${e.toString()}',
      );
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
      if (plantingDate != null) {
        updateData['planting_date'] = plantingDate.toIso8601String();
      }
      if (expectedHarvestDate != null) {
        updateData['expected_harvest_date'] = expectedHarvestDate
            .toIso8601String();
      }
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

  // Weather API Integration using WeatherAPI.com
  Future<Weather> getWeatherData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Using WeatherAPI.com (free tier)
      const apiKey =
          '59b1947117dd4e3e8c3225457251009'; // Replace with your actual API key
      final url =
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$latitude,$longitude&aqi=no';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract location with proper formatting
        String locationName = data['location']['name'] ?? 'Unknown Location';
        String region = data['location']['region'] ?? '';
        String country = data['location']['country'] ?? '';
        String fullLocation = region.isNotEmpty && country.isNotEmpty
            ? '$locationName, $region, $country'
            : country.isNotEmpty
            ? '$locationName, $country'
            : locationName;

        // Get current weather data
        final current = data['current'];
        final condition = current['condition'];

        // Map WeatherAPI condition codes to OpenWeatherMap icons
        String openWeatherIcon = _mapWeatherAPIToOpenWeatherIcon(
          condition['code'] ?? 1000,
        );

        return Weather(
          location: fullLocation,
          temperature: (current['temp_c'] ?? 0).toDouble(),
          description: condition['text'] ?? 'No description',
          iconUrl: 'https://openweathermap.org/img/wn/$openWeatherIcon@2x.png',
          humidity: current['humidity'] ?? 0,
          windSpeed:
              (current['wind_kph'] ?? 0).toDouble() /
              3.6, // Convert km/h to m/s
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

  // Map WeatherAPI condition codes to OpenWeatherMap icon codes
  String _mapWeatherAPIToOpenWeatherIcon(int weatherAPICode) {
    // WeatherAPI condition codes to OpenWeatherMap icon mapping
    switch (weatherAPICode) {
      // Clear sky
      case 1000:
        return '01d'; // clear sky day

      // Partly cloudy
      case 1003:
        return '02d'; // few clouds day

      // Cloudy
      case 1006:
        return '04d'; // broken clouds
      case 1009:
        return '04d'; // overcast

      // Mist/Fog
      case 1030:
      case 1135:
      case 1147:
        return '50d'; // mist

      // Patchy rain
      case 1063:
      case 1180:
      case 1183:
      case 1186:
      case 1189:
      case 1192:
      case 1195:
      case 1201:
      case 1240:
      case 1243:
      case 1246:
        return '10d'; // rain

      // Patchy snow
      case 1066:
      case 1210:
      case 1213:
      case 1216:
      case 1219:
      case 1222:
      case 1225:
      case 1255:
      case 1258:
        return '13d'; // snow

      // Patchy sleet
      case 1069:
      case 1204:
      case 1207:
      case 1249:
      case 1252:
        return '13d'; // snow (closest match)

      // Patchy freezing drizzle
      case 1072:
      case 1150:
      case 1153:
      case 1168:
      case 1171:
        return '13d'; // snow (closest match)

      // Thundery outbreaks
      case 1087:
      case 1273:
      case 1276:
      case 1279:
      case 1282:
        return '11d'; // thunderstorm

      // Blowing snow
      case 1114:
      case 1117:
        return '13d'; // snow

      // Blizzard
      case 1219:
      case 1222:
      case 1225:
        return '13d'; // snow

      // Fog
      case 1135:
      case 1147:
        return '50d'; // mist

      // Freezing fog
      case 1147:
        return '50d'; // mist

      // Patchy light drizzle
      case 1150:
      case 1153:
        return '09d'; // shower rain

      // Freezing drizzle
      case 1168:
      case 1171:
        return '13d'; // snow

      // Heavy freezing drizzle
      case 1171:
        return '13d'; // snow

      // Patchy light rain
      case 1180:
      case 1183:
        return '10d'; // rain

      // Light rain
      case 1186:
      case 1189:
        return '10d'; // rain

      // Moderate rain
      case 1192:
      case 1195:
        return '10d'; // rain

      // Heavy rain
      case 1198:
      case 1201:
        return '09d'; // shower rain

      // Light freezing rain
      case 1198:
        return '13d'; // snow

      // Moderate or heavy freezing rain
      case 1201:
        return '13d'; // snow

      // Light sleet
      case 1204:
      case 1207:
        return '13d'; // snow

      // Moderate or heavy sleet
      case 1207:
        return '13d'; // snow

      // Patchy light snow
      case 1210:
      case 1213:
        return '13d'; // snow

      // Light snow
      case 1216:
      case 1219:
        return '13d'; // snow

      // Patchy moderate snow
      case 1213:
        return '13d'; // snow

      // Moderate snow
      case 1219:
        return '13d'; // snow

      // Patchy heavy snow
      case 1216:
        return '13d'; // snow

      // Heavy snow
      case 1222:
      case 1225:
        return '13d'; // snow

      // Ice pellets
      case 1237:
        return '13d'; // snow

      // Light rain shower
      case 1240:
      case 1243:
        return '09d'; // shower rain

      // Moderate or heavy rain shower
      case 1246:
        return '09d'; // shower rain

      // Torrential rain shower
      case 1249:
        return '09d'; // shower rain

      // Light sleet showers
      case 1252:
        return '13d'; // snow

      // Moderate or heavy sleet showers
      case 1255:
        return '13d'; // snow

      // Light snow showers
      case 1258:
        return '13d'; // snow

      // Moderate or heavy snow showers
      case 1261:
        return '13d'; // snow

      // Light showers of ice pellets
      case 1264:
        return '13d'; // snow

      // Moderate or heavy showers of ice pellets
      case 1267:
        return '13d'; // snow

      // Patchy light rain with thunder
      case 1273:
        return '11d'; // thunderstorm

      // Moderate or heavy rain with thunder
      case 1276:
        return '11d'; // thunderstorm

      // Patchy light snow with thunder
      case 1279:
        return '11d'; // thunderstorm

      // Moderate or heavy snow with thunder
      case 1282:
        return '11d'; // thunderstorm

      default:
        return '01d'; // default to clear sky
    }
  }

  Weather _getMockWeatherData() {
    // Mock weather data for demo with realistic Indian location
    return Weather(
      location: 'Mumbai, Maharashtra, India',
      temperature: 28.0,
      description: 'partly cloudy',
      iconUrl: 'https://openweathermap.org/img/wn/02d@2x.png',
      humidity: 75,
      windSpeed: 2.8,
      timestamp: DateTime.now(),
    );
  }

  // Disease Management Methods
  Future<List<Disease>> getCommonDiseases() async {
    try {
      final response = await Supabase.instance.client
          .from('diseases')
          .select()
          .eq('is_common', true)
          .order('name', ascending: true);

      return (response as List).map((json) => Disease.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching common diseases: $e');
      // Return mock data for demo
      return _getMockDiseasesData();
    }
  }

  Future<List<Disease>> getDiseasesBySeverity(String severity) async {
    try {
      final response = await Supabase.instance.client
          .from('diseases')
          .select()
          .eq('severity', severity)
          .eq('is_common', true)
          .order('name', ascending: true);

      return (response as List).map((json) => Disease.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch diseases by severity: ${e.toString()}');
    }
  }

  Future<Disease?> getDiseaseById(String diseaseId) async {
    try {
      final response = await Supabase.instance.client
          .from('diseases')
          .select()
          .eq('id', diseaseId)
          .maybeSingle();

      if (response != null) {
        return Disease.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch disease: ${e.toString()}');
    }
  }

  Future<List<Disease>> searchDiseases(String query) async {
    try {
      final response = await Supabase.instance.client
          .from('diseases')
          .select()
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,symptoms.ilike.%$query%',
          )
          .eq('is_common', true)
          .order('name', ascending: true);

      return (response as List).map((json) => Disease.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search diseases: ${e.toString()}');
    }
  }

  List<Disease> _getMockDiseasesData() {
    // Mock disease data for demo
    return [
      Disease(
        id: '1',
        name: 'Leaf Spot',
        description:
            'A common fungal disease affecting many crops, causing dark spots on leaves.',
        symptoms:
            'Dark brown or black spots on leaves, yellowing around spots, premature leaf drop.',
        treatment:
            'Apply fungicide spray, remove infected leaves, improve air circulation.',
        prevention:
            'Avoid overhead watering, ensure proper spacing, use disease-resistant varieties.',
        imageUrl:
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=300&fit=crop',
        severity: 'moderate',
        affectedCrops: ['Tomato', 'Pepper', 'Bean'],
        isCommon: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Disease(
        id: '2',
        name: 'Powdery Mildew',
        description:
            'White powdery coating on leaves and stems, common in humid conditions.',
        symptoms:
            'White powdery substance on leaves, stunted growth, leaf distortion.',
        treatment: 'Spray with baking soda solution or sulfur-based fungicide.',
        prevention: 'Ensure good air circulation, avoid overcrowding plants.',
        imageUrl:
            'https://images.unsplash.com/photo-1585503418537-88331351ad99?w=400&h=300&fit=crop',
        severity: 'mild',
        affectedCrops: ['Cucumber', 'Squash', 'Rose'],
        isCommon: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Disease(
        id: '3',
        name: 'Root Rot',
        description:
            'Serious disease affecting plant roots, often fatal if not treated quickly.',
        symptoms:
            'Wilting plants, yellowing leaves, black or brown mushy roots.',
        treatment:
            'Remove affected plants, improve drainage, apply fungicide to soil.',
        prevention:
            'Ensure proper drainage, avoid overwatering, use well-draining soil.',
        imageUrl:
            'https://images.unsplash.com/photo-1574263867128-5c18bcadf30b?w=400&h=300&fit=crop',
        severity: 'severe',
        affectedCrops: ['All crops'],
        isCommon: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Disease(
        id: '4',
        name: 'Aphid Infestation',
        description:
            'Small insects that feed on plant sap, weakening the plant.',
        symptoms:
            'Small green or black insects on leaves, sticky honeydew, curled leaves.',
        treatment: 'Spray with insecticidal soap, release beneficial insects.',
        prevention:
            'Regular inspection, companion planting, maintain plant health.',
        imageUrl:
            'https://images.unsplash.com/photo-1629901925121-8a141c2a42f4?w=400&h=300&fit=crop',
        severity: 'moderate',
        affectedCrops: ['Most vegetables'],
        isCommon: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Government Program Management Methods
  Future<List<GovernmentProgram>> getActiveGovernmentPrograms() async {
    try {
      final response = await Supabase.instance.client
          .from('government_programs')
          .select()
          .eq('is_active', true)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GovernmentProgram.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching government programs: $e');
      // Return mock data for demo
      return _getMockGovernmentProgramsData();
    }
  }

  Future<List<GovernmentProgram>> getGovernmentProgramsByCategory(
    String category,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('government_programs')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GovernmentProgram.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to fetch government programs by category: ${e.toString()}',
      );
    }
  }

  Future<GovernmentProgram?> getGovernmentProgramById(String programId) async {
    try {
      final response = await Supabase.instance.client
          .from('government_programs')
          .select()
          .eq('id', programId)
          .maybeSingle();

      if (response != null) {
        return GovernmentProgram.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch government program: ${e.toString()}');
    }
  }

  Future<List<GovernmentProgram>> searchGovernmentPrograms(String query) async {
    try {
      final response = await Supabase.instance.client
          .from('government_programs')
          .select()
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,benefits.ilike.%$query%',
          )
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => GovernmentProgram.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search government programs: ${e.toString()}');
    }
  }

  List<GovernmentProgram> _getMockGovernmentProgramsData() {
    // Mock government program data for demo
    return [
      GovernmentProgram(
        id: '1',
        name: 'PM-KISAN Scheme',
        description:
            'Direct income support scheme for farmers providing ₹6,000 per year in three equal installments.',
        eligibility:
            'Small and marginal farmers with landholding up to 2 hectares. Must be a citizen of India.',
        benefits:
            '₹6,000 per year in three installments of ₹2,000 each. Direct transfer to bank account.',
        applicationProcess:
            'Apply online through PM-KISAN portal or visit nearest Common Service Centre (CSC).',
        imageUrl:
            'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=300&fit=crop',
        category: 'subsidy',
        status: 'active',
        maxAmount: 6000,
        deadline: '2024-12-31',
        targetCrops: ['All crops'],
        department: 'Ministry of Agriculture & Farmers Welfare',
        contactInfo: '1800-180-1551',
        website: 'https://pmkisan.gov.in',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GovernmentProgram(
        id: '2',
        name: 'Kisan Credit Card (KCC)',
        description:
            'Flexible credit facility for farmers to meet their agricultural and allied activities needs.',
        eligibility:
            'Farmers, tenant farmers, oral lessees, sharecroppers, and self-help groups.',
        benefits:
            'Credit up to ₹3 lakh at 4% interest rate. No collateral required for loans up to ₹1.6 lakh.',
        applicationProcess:
            'Apply at any commercial bank, cooperative bank, or regional rural bank.',
        imageUrl:
            'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=300&fit=crop',
        category: 'loan',
        status: 'active',
        maxAmount: 300000,
        deadline: null,
        targetCrops: ['All crops'],
        department: 'Reserve Bank of India',
        contactInfo: 'Contact your nearest bank branch',
        website: 'https://rbi.org.in',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GovernmentProgram(
        id: '3',
        name: 'Soil Health Card Scheme',
        description:
            'Provides soil health cards to farmers with recommendations for appropriate fertilizer use.',
        eligibility:
            'All farmers across India can apply for soil health cards.',
        benefits:
            'Free soil testing, personalized fertilizer recommendations, improved crop yield.',
        applicationProcess:
            'Apply online through Soil Health Card portal or visit nearest soil testing lab.',
        imageUrl:
            'https://images.unsplash.com/photo-1574263867128-5c18bcadf30b?w=400&h=300&fit=crop',
        category: 'training',
        status: 'active',
        maxAmount: null,
        deadline: null,
        targetCrops: ['All crops'],
        department: 'Ministry of Agriculture & Farmers Welfare',
        contactInfo: '1800-180-1551',
        website: 'https://soilhealth.dac.gov.in',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GovernmentProgram(
        id: '4',
        name: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
        description:
            'Crop insurance scheme to provide financial support to farmers in case of crop failure.',
        eligibility: 'All farmers growing notified crops in notified areas.',
        benefits:
            'Premium as low as 1.5% for Kharif crops, 2% for Rabi crops, and 5% for commercial crops.',
        applicationProcess:
            'Apply through insurance companies or Common Service Centres.',
        imageUrl:
            'https://images.unsplash.com/photo-1585503418537-88331351ad99?w=400&h=300&fit=crop',
        category: 'insurance',
        status: 'active',
        maxAmount: null,
        deadline: '2024-03-31',
        targetCrops: ['Rice', 'Wheat', 'Maize', 'Cotton', 'Sugarcane'],
        department: 'Ministry of Agriculture & Farmers Welfare',
        contactInfo: '1800-180-1551',
        website: 'https://pmfby.gov.in',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GovernmentProgram(
        id: '5',
        name: 'Sub-Mission on Agricultural Mechanization (SMAM)',
        description:
            'Promotes agricultural mechanization by providing financial assistance for farm equipment.',
        eligibility:
            'Individual farmers, farmer groups, cooperatives, and custom hiring centers.',
        benefits:
            'Subsidy up to 40% for general farmers and 50% for SC/ST farmers on farm equipment.',
        applicationProcess:
            'Apply through state agriculture department or online portal.',
        imageUrl:
            'https://images.unsplash.com/photo-1629901925121-8a141c2a42f4?w=400&h=300&fit=crop',
        category: 'equipment',
        status: 'active',
        maxAmount: 500000,
        deadline: '2024-12-31',
        targetCrops: ['All crops'],
        department: 'Ministry of Agriculture & Farmers Welfare',
        contactInfo: '1800-180-1551',
        website: 'https://agricoop.gov.in',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
