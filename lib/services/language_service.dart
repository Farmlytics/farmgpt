import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static String _currentLanguage = 'en';

  // Google Cloud Translation API configuration
  static String get _googleApiKey =>
      dotenv.env['GOOGLE_TRANSLATION_API_KEY'] ?? '';
  static const String _googleTranslateUrl =
      'https://translation.googleapis.com/language/translate/v2';

  // Translation maps
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Onboarding
      'add_your_crops': 'Add Your Crops',
      'select_crops_description':
          'Tap to select the crops you grow. This helps us provide personalized insights and recommendations.',
      'search_crops': 'Search crops...',
      'crops_selected': 'crops selected',
      'crop_selected': 'crop selected',
      'next': 'Next',
      'get_started': 'Get Started',
      'skip': 'Skip',
      'welcome_to_farmlytics': 'Welcome to Farmlytics',
      'welcome_description':
          'Your AI-powered farming assistant that helps you make smarter decisions for better crop yields.',
      'smart_scheduling': 'Smart Scheduling',
      'scheduling_description':
          'Plan and track your farming activities with intelligent scheduling based on weather and crop cycles.',
      'ai_chat_assistant': 'AI Chat Assistant',
      'chat_description':
          'Get instant answers to your farming questions from our AI assistant trained on agricultural best practices.',
      'data_driven_insights': 'Data-Driven Insights',
      'insights_description':
          'Monitor your farm\'s performance with detailed analytics and personalized recommendations.',

      // Language Selection
      'choose_language': 'Choose Your Language',
      'language_description':
          'Select your preferred language for the best farming experience.',
      'continue': 'Continue',

      // Common
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'done': 'Done',
      'close': 'Close',
      'back': 'Back',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',

      // Home Screen
      'hi': 'hi',
      'my_crops': 'My Crops',
      'add': 'Add',
      'common_diseases': 'Common Diseases for Your Crops',
      'add_crops_to_see_diseases': 'Add crops to see relevant diseases',
      'no_diseases_found': 'No diseases found for your crops',
      'government_programs': 'Government Programs',
      'no_programs_available': 'No government programs available',
      'farm_status': 'Farm Status',
      'crops': 'Crops',
      'active': 'Active',
      'tasks': 'Tasks',
      'pending': 'Pending',
      'helping_farmers_grow': 'Helping Farmers Grow',
      'cultivated_with_love': 'Cultivated with ❤️ by',
      'getting_weather': 'Getting weather...',
      'weather_unavailable': 'Weather unavailable',
      'location_services_disabled': 'Location services are disabled',
      'location_permission_denied': 'Location permission denied',
      'location_permission_permanently_denied':
          'Location permission permanently denied. Enable in settings.',
      'failed_to_get_location': 'Failed to get location',
      'add_crop_to_farm': 'Add Crop to Your Farm',
      'choose_crops_description':
          'Choose from available crops to add to your farming dashboard.',
      'failed_to_load_crops': 'Failed to load crops',
      'crop_added_to_farm': 'added to your farm!',
      'failed_to_add_crop': 'Failed to add',

      // Auth Screen
      'welcome_back': 'Welcome Back',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'phone_number': 'Phone Number',
      'enter_phone_number': 'Enter your phone number',
      'verification_code': 'Verification Code',
      'enter_verification_code':
          'Enter the verification code sent to your phone',
      'name': 'Name',
      'enter_your_name': 'Enter your name',
      'send_code': 'Send Code',
      'verify': 'Verify',
      'resend_code': 'Resend Code',
      'invalid_phone_number': 'Please enter a valid phone number',
      'invalid_verification_code': 'Please enter a valid verification code',
      'invalid_name': 'Please enter your name',
      'sign_in_successful': 'Sign in successful',
      'sign_up_successful': 'Sign up successful',
      'sign_in_failed': 'Sign in failed',
      'sign_up_failed': 'Sign up failed',
      'verification_failed': 'Verification failed',
      'resend_code_in': 'Resend code in',
      'seconds': 'seconds',

      // Profile Screen
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'logout': 'Logout',
      'account_settings': 'Account Settings',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'help_support': 'Help & Support',
      'about': 'About',
      'version': 'Version',
      'logout_confirmation': 'Are you sure you want to logout?',

      // AI Chat
      'ai_assistant': 'AI Assistant',
      'ask_anything': 'Ask me anything about farming...',
      'send': 'Send',
      'typing': 'AI is typing...',
      'chat_history': 'Chat History',
      'new_chat': 'New Chat',
      'clear_chat': 'Clear Chat',
      'clear_chat_confirmation': 'Are you sure you want to clear the chat?',
      'quick_questions': 'Quick Questions',

      // Tabs
      'home': 'Home',
      'chat': 'Chat',
      'calendar': 'Calendar',
      'profile_tab': 'Profile',

      // Schedule Tab
      'schedule': 'Schedule',
      'plan_farming_activities': 'Plan your farming activities',
      'today': 'Today',
      'this_week': 'This Week',
      'completed': 'Completed',
      'this_month': 'This month',
      'upcoming_tasks': 'Upcoming Tasks',
      'water_tomato_plants': 'Water Tomato Plants',
      'check_soil_moisture': 'Check soil moisture and water if needed',
      'apply_fertilizer': 'Apply Fertilizer',
      'apply_nitrogen_fertilizer':
          'Apply nitrogen-rich fertilizer to corn field',
      'pest_inspection': 'Pest Inspection',
      'check_for_aphids': 'Check for aphids and other pests',
      'harvest_lettuce': 'Harvest Lettuce',
      'harvest_mature_lettuce': 'Harvest mature lettuce heads',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'tomorrow': 'Tomorrow',

      // AI Chat Tab
      'get_farming_insights': 'Get farming insights and advice',
      'hello_ai_assistant':
          'Hello! I\'m your AI farming assistant. How can I help you today? You can ask me about crop management, pest control, weather advice, or any other farming questions.',
      'when_water_tomatoes': 'When should I water my tomatoes?',
      'how_deal_aphids': 'How to deal with aphids?',
      'best_fertilizer_corn': 'Best fertilizer for corn?',
      'weather_forecast_impact': 'Weather forecast impact',
      'crop_rotation_advice': 'Crop rotation advice',
      'soil_ph_management': 'Soil pH management',
      'optimal_watering_advice':
          'For optimal watering, check soil moisture 2-3 inches deep. Water early morning or late evening to reduce evaporation. Most crops need 1-2 inches per week.',
      'tomato_watering_advice':
          'Tomatoes need consistent watering - avoid both drought stress and overwatering. Water at the base to prevent leaf diseases. Mulching helps retain moisture.',
      'fertilizer_advice':
          'Use balanced fertilizers during vegetative growth (N-P-K 10-10-10), then switch to lower nitrogen for flowering/fruiting stages. Always test soil first.',
      'pest_management_advice':
          'Integrated Pest Management (IPM) is best: use beneficial insects, crop rotation, and targeted treatments only when necessary. Regular monitoring is key.',
      'weather_advice':
          'Check local weather forecasts and adjust activities accordingly. Avoid fertilizing before heavy rains, and protect sensitive plants from extreme weather.',
      'general_ai_response':
          'That\'s a great question! For the most accurate advice, I\'d recommend consulting with local agricultural extension services or soil testing labs. Is there a specific aspect of farming you\'d like to explore further?',
    },
    'hi': {
      // Onboarding
      'add_your_crops': 'अपनी फसलें जोड़ें',
      'select_crops_description':
          'अपनी उगाई जाने वाली फसलों का चयन करने के लिए टैप करें। यह हमें व्यक्तिगत अंतर्दृष्टि और सिफारिशें प्रदान करने में मदद करता है।',
      'search_crops': 'फसलें खोजें...',
      'crops_selected': 'फसलें चुनी गईं',
      'crop_selected': 'फसल चुनी गई',
      'next': 'आगे',
      'get_started': 'शुरू करें',
      'skip': 'छोड़ें',
      'welcome_to_farmlytics': 'फार्मलिटिक्स में आपका स्वागत है',
      'welcome_description':
          'आपका AI-संचालित कृषि सहायक जो बेहतर फसल उत्पादन के लिए आपको स्मार्ट निर्णय लेने में मदद करता है।',
      'smart_scheduling': 'स्मार्ट शेड्यूलिंग',
      'scheduling_description':
          'मौसम और फसल चक्रों के आधार पर बुद्धिमान शेड्यूलिंग के साथ अपनी कृषि गतिविधियों की योजना बनाएं और ट्रैक करें।',
      'ai_chat_assistant': 'AI चैट सहायक',
      'chat_description':
          'कृषि सर्वोत्तम प्रथाओं पर प्रशिक्षित हमारे AI सहायक से अपने कृषि प्रश्नों के तत्काल उत्तर प्राप्त करें।',
      'data_driven_insights': 'डेटा-संचालित अंतर्दृष्टि',
      'insights_description':
          'विस्तृत विश्लेषण और व्यक्तिगत सिफारिशों के साथ अपने खेत के प्रदर्शन की निगरानी करें।',

      // Language Selection
      'choose_language': 'अपनी भाषा चुनें',
      'language_description':
          'सर्वोत्तम कृषि अनुभव के लिए अपनी पसंदीदा भाषा का चयन करें।',
      'continue': 'जारी रखें',

      // Common
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'retry': 'पुनः प्रयास करें',
      'settings': 'सेटिंग्स',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'done': 'हो गया',
      'close': 'बंद करें',
      'back': 'वापस',
      'yes': 'हाँ',
      'no': 'नहीं',
      'ok': 'ठीक है',

      // Home Screen
      'hi': 'नमस्ते',
      'my_crops': 'मेरी फसलें',
      'add': 'जोड़ें',
      'common_diseases': 'आपकी फसलों के लिए सामान्य रोग',
      'add_crops_to_see_diseases': 'संबंधित रोग देखने के लिए फसलें जोड़ें',
      'no_diseases_found': 'आपकी फसलों के लिए कोई रोग नहीं मिला',
      'government_programs': 'सरकारी कार्यक्रम',
      'no_programs_available': 'कोई सरकारी कार्यक्रम उपलब्ध नहीं',
      'farm_status': 'खेत की स्थिति',
      'crops': 'फसलें',
      'active': 'सक्रिय',
      'tasks': 'कार्य',
      'pending': 'लंबित',
      'helping_farmers_grow': 'किसानों को बढ़ने में मदद करना',
      'cultivated_with_love': '❤️ के साथ खेती की गई ',
      'getting_weather': 'मौसम जानकारी मिल रही है...',
      'weather_unavailable': 'मौसम जानकारी उपलब्ध नहीं',
      'location_services_disabled': 'स्थान सेवाएं अक्षम हैं',
      'location_permission_denied': 'स्थान की अनुमति अस्वीकृत',
      'location_permission_permanently_denied':
          'स्थान की अनुमति स्थायी रूप से अस्वीकृत। सेटिंग्स में सक्षम करें।',
      'failed_to_get_location': 'स्थान प्राप्त करने में विफल',
      'add_crop_to_farm': 'अपने खेत में फसल जोड़ें',
      'choose_crops_description':
          'अपने कृषि डैशबोर्ड में जोड़ने के लिए उपलब्ध फसलों में से चुनें।',
      'failed_to_load_crops': 'फसलें लोड करने में विफल',
      'crop_added_to_farm': 'आपके खेत में जोड़ दी गई!',
      'failed_to_add_crop': 'जोड़ने में विफल',

      // Auth Screen
      'welcome_back': 'वापस स्वागत है',
      'sign_in': 'साइन इन करें',
      'sign_up': 'साइन अप करें',
      'phone_number': 'फोन नंबर',
      'enter_phone_number': 'अपना फोन नंबर दर्ज करें',
      'verification_code': 'सत्यापन कोड',
      'enter_verification_code': 'अपने फोन पर भेजे गए सत्यापन कोड को दर्ज करें',
      'name': 'नाम',
      'enter_your_name': 'अपना नाम दर्ज करें',
      'send_code': 'कोड भेजें',
      'verify': 'सत्यापित करें',
      'resend_code': 'कोड पुनः भेजें',
      'invalid_phone_number': 'कृपया एक वैध फोन नंबर दर्ज करें',
      'invalid_verification_code': 'कृपया एक वैध सत्यापन कोड दर्ज करें',
      'invalid_name': 'कृपया अपना नाम दर्ज करें',
      'sign_in_successful': 'साइन इन सफल',
      'sign_up_successful': 'साइन अप सफल',
      'sign_in_failed': 'साइन इन विफल',
      'sign_up_failed': 'साइन अप विफल',
      'verification_failed': 'सत्यापन विफल',
      'resend_code_in': 'कोड पुनः भेजें',
      'seconds': 'सेकंड',

      // Profile Screen
      'profile': 'प्रोफ़ाइल',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'logout': 'लॉग आउट',
      'account_settings': 'खाता सेटिंग्स',
      'notifications': 'सूचनाएं',
      'privacy': 'गोपनीयता',
      'help_support': 'सहायता और समर्थन',
      'about': 'के बारे में',
      'version': 'संस्करण',
      'logout_confirmation': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',

      // AI Chat
      'ai_assistant': 'AI सहायक',
      'ask_anything': 'कृषि के बारे में कुछ भी पूछें...',
      'send': 'भेजें',
      'typing': 'AI टाइप कर रहा है...',
      'chat_history': 'चैट इतिहास',
      'new_chat': 'नई चैट',
      'clear_chat': 'चैट साफ़ करें',
      'clear_chat_confirmation': 'क्या आप वाकई चैट साफ़ करना चाहते हैं?',
      'quick_questions': 'त्वरित प्रश्न',

      // Tabs
      'home': 'होम',
      'chat': 'चैट',
      'calendar': 'कैलेंडर',
      'profile_tab': 'प्रोफ़ाइल',

      // Schedule Tab
      'schedule': 'समय सारणी',
      'plan_farming_activities': 'अपनी कृषि गतिविधियों की योजना बनाएं',
      'today': 'आज',
      'this_week': 'इस सप्ताह',
      'completed': 'पूर्ण',
      'this_month': 'इस महीने',
      'upcoming_tasks': 'आगामी कार्य',
      'water_tomato_plants': 'टमाटर के पौधों को पानी दें',
      'check_soil_moisture': 'मिट्टी की नमी जांचें और आवश्यकता हो तो पानी दें',
      'apply_fertilizer': 'उर्वरक लगाएं',
      'apply_nitrogen_fertilizer':
          'मकई के खेत में नाइट्रोजन युक्त उर्वरक लगाएं',
      'pest_inspection': 'कीट निरीक्षण',
      'check_for_aphids': 'एफिड्स और अन्य कीटों की जांच करें',
      'harvest_lettuce': 'लेट्यूस की कटाई',
      'harvest_mature_lettuce': 'पके लेट्यूस के सिर काटें',
      'monday': 'सोमवार',
      'tuesday': 'मंगलवार',
      'wednesday': 'बुधवार',
      'thursday': 'गुरुवार',
      'friday': 'शुक्रवार',
      'saturday': 'शनिवार',
      'sunday': 'रविवार',
      'tomorrow': 'कल',

      // AI Chat Tab
      'get_farming_insights': 'कृषि अंतर्दृष्टि और सलाह प्राप्त करें',
      'hello_ai_assistant':
          'नमस्ते! मैं आपका AI कृषि सहायक हूं। आज मैं आपकी कैसे मदद कर सकता हूं? आप मुझसे फसल प्रबंधन, कीट नियंत्रण, मौसम सलाह या किसी अन्य कृषि प्रश्न के बारे में पूछ सकते हैं।',
      'when_water_tomatoes': 'मुझे अपने टमाटरों को कब पानी देना चाहिए?',
      'how_deal_aphids': 'एफिड्स से कैसे निपटें?',
      'best_fertilizer_corn': 'मकई के लिए सबसे अच्छा उर्वरक?',
      'weather_forecast_impact': 'मौसम पूर्वानुमान प्रभाव',
      'crop_rotation_advice': 'फसल चक्र सलाह',
      'soil_ph_management': 'मिट्टी का pH प्रबंधन',
      'optimal_watering_advice':
          'इष्टतम पानी के लिए, मिट्टी की नमी 2-3 इंच गहराई तक जांचें। वाष्पीकरण कम करने के लिए सुबह जल्दी या शाम को देर से पानी दें। अधिकांश फसलों को सप्ताह में 1-2 इंच पानी की आवश्यकता होती है।',
      'tomato_watering_advice':
          'टमाटर को लगातार पानी की आवश्यकता होती है - सूखे तनाव और अधिक पानी दोनों से बचें। पत्ती रोगों को रोकने के लिए जड़ में पानी दें। गीली घास नमी बनाए रखने में मदद करती है।',
      'fertilizer_advice':
          'वनस्पति वृद्धि के दौरान संतुलित उर्वरकों का उपयोग करें (N-P-K 10-10-10), फिर फूल/फलने के चरणों के लिए कम नाइट्रोजन पर स्विच करें। हमेशा पहले मिट्टी का परीक्षण करें।',
      'pest_management_advice':
          'एकीकृत कीट प्रबंधन (IPM) सबसे अच्छा है: लाभकारी कीड़ों, फसल चक्र, और आवश्यकता होने पर ही लक्षित उपचार का उपयोग करें। नियमित निगरानी महत्वपूर्ण है।',
      'weather_advice':
          'स्थानीय मौसम पूर्वानुमान जांचें और गतिविधियों को तदनुसार समायोजित करें। भारी बारिश से पहले उर्वरक लगाने से बचें, और चरम मौसम से संवेदनशील पौधों की रक्षा करें।',
      'general_ai_response':
          'यह एक बेहतरीन सवाल है! सबसे सटीक सलाह के लिए, मैं स्थानीय कृषि विस्तार सेवाओं या मिट्टी परीक्षण प्रयोगशालाओं से परामर्श करने की सलाह दूंगा। क्या आप कृषि के किसी विशिष्ट पहलू का और पता लगाना चाहते हैं?',
    },
    'bn': {
      // Onboarding
      'add_your_crops': 'আপনার ফসল যোগ করুন',
      'select_crops_description':
          'আপনার চাষ করা ফসল নির্বাচন করতে ট্যাপ করুন। এটি আমাদের ব্যক্তিগত অন্তর্দৃষ্টি এবং সুপারিশ প্রদান করতে সাহায্য করে।',
      'search_crops': 'ফসল খুঁজুন...',
      'crops_selected': 'ফসল নির্বাচিত',
      'crop_selected': 'ফসল নির্বাচিত',
      'next': 'পরবর্তী',
      'get_started': 'শুরু করুন',
      'skip': 'এড়িয়ে যান',
      'welcome_to_farmlytics': 'ফার্মলিটিক্সে স্বাগতম',
      'welcome_description':
          'আপনার AI-চালিত কৃষি সহায়ক যা ভাল ফসল ফলনের জন্য আপনাকে স্মার্ট সিদ্ধান্ত নিতে সাহায্য করে।',
      'smart_scheduling': 'স্মার্ট সময়সূচী',
      'scheduling_description':
          'আবহাওয়া এবং ফসল চক্রের উপর ভিত্তি করে বুদ্ধিমান সময়সূচীর সাথে আপনার কৃষি কার্যক্রম পরিকল্পনা এবং ট্র্যাক করুন।',
      'ai_chat_assistant': 'AI চ্যাট সহায়ক',
      'chat_description':
          'কৃষি সেরা অনুশীলনে প্রশিক্ষিত আমাদের AI সহায়ক থেকে আপনার কৃষি প্রশ্নের তাত্ক্ষণিক উত্তর পান।',
      'data_driven_insights': 'ডেটা-চালিত অন্তর্দৃষ্টি',
      'insights_description':
          'বিস্তারিত বিশ্লেষণ এবং ব্যক্তিগত সুপারিশের সাথে আপনার খামারের কর্মক্ষমতা নিরীক্ষণ করুন।',

      // Language Selection
      'choose_language': 'আপনার ভাষা নির্বাচন করুন',
      'language_description':
          'সেরা কৃষি অভিজ্ঞতার জন্য আপনার পছন্দের ভাষা নির্বাচন করুন।',
      'continue': 'চালিয়ে যান',

      // Common
      'loading': 'লোড হচ্ছে...',
      'error': 'ত্রুটি',
      'retry': 'পুনরায় চেষ্টা করুন',
      'settings': 'সেটিংস',
      'save': 'সংরক্ষণ',
      'cancel': 'বাতিল',
      'done': 'সম্পন্ন',
      'close': 'বন্ধ',
      'back': 'ফিরে',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'ok': 'ঠিক আছে',

      // Home Screen
      'hi': 'হ্যালো',
      'my_crops': 'আমার ফসল',
      'add': 'যোগ করুন',
      'common_diseases': 'আপনার ফসলের জন্য সাধারণ রোগ',
      'add_crops_to_see_diseases': 'প্রাসঙ্গিক রোগ দেখতে ফসল যোগ করুন',
      'no_diseases_found': 'আপনার ফসলের জন্য কোন রোগ পাওয়া যায়নি',
      'government_programs': 'সরকারি কর্মসূচি',
      'no_programs_available': 'কোন সরকারি কর্মসূচি উপলব্ধ নেই',
      'farm_status': 'খামারের অবস্থা',
      'crops': 'ফসল',
      'active': 'সক্রিয়',
      'tasks': 'কাজ',
      'pending': 'অপেক্ষমান',
      'helping_farmers_grow': 'কৃষকদের বৃদ্ধিতে সাহায্য করা',
      'cultivated_with_love': '❤️ দিয়ে চাষ করা হয়েছে',
      'getting_weather': 'আবহাওয়ার তথ্য পাওয়া হচ্ছে...',
      'weather_unavailable': 'আবহাওয়ার তথ্য উপলব্ধ নেই',
      'location_services_disabled': 'অবস্থান পরিষেবা নিষ্ক্রিয়',
      'location_permission_denied': 'অবস্থানের অনুমতি অস্বীকার',
      'location_permission_permanently_denied':
          'অবস্থানের অনুমতি স্থায়ীভাবে অস্বীকার। সেটিংসে সক্রিয় করুন।',
      'failed_to_get_location': 'অবস্থান পেতে ব্যর্থ',
      'add_crop_to_farm': 'আপনার খামারে ফসল যোগ করুন',
      'choose_crops_description':
          'আপনার কৃষি ড্যাশবোর্ডে যোগ করার জন্য উপলব্ধ ফসল থেকে বেছে নিন।',
      'failed_to_load_crops': 'ফসল লোড করতে ব্যর্থ',
      'crop_added_to_farm': 'আপনার খামারে যোগ করা হয়েছে!',
      'failed_to_add_crop': 'যোগ করতে ব্যর্থ',

      // Auth Screen
      'welcome_back': 'ফিরে স্বাগতম',
      'sign_in': 'সাইন ইন',
      'sign_up': 'সাইন আপ',
      'phone_number': 'ফোন নম্বর',
      'enter_phone_number': 'আপনার ফোন নম্বর লিখুন',
      'verification_code': 'যাচাইকরণ কোড',
      'enter_verification_code': 'আপনার ফোনে পাঠানো যাচাইকরণ কোড লিখুন',
      'name': 'নাম',
      'enter_your_name': 'আপনার নাম লিখুন',
      'send_code': 'কোড পাঠান',
      'verify': 'যাচাই করুন',
      'resend_code': 'কোড পুনরায় পাঠান',
      'invalid_phone_number': 'অনুগ্রহ করে একটি বৈধ ফোন নম্বর লিখুন',
      'invalid_verification_code': 'অনুগ্রহ করে একটি বৈধ যাচাইকরণ কোড লিখুন',
      'invalid_name': 'অনুগ্রহ করে আপনার নাম লিখুন',
      'sign_in_successful': 'সাইন ইন সফল',
      'sign_up_successful': 'সাইন আপ সফল',
      'sign_in_failed': 'সাইন ইন ব্যর্থ',
      'sign_up_failed': 'সাইন আপ ব্যর্থ',
      'verification_failed': 'যাচাইকরণ ব্যর্থ',
      'resend_code_in': 'কোড পুনরায় পাঠান',
      'seconds': 'সেকেন্ড',

      // Profile Screen
      'profile': 'প্রোফাইল',
      'edit_profile': 'প্রোফাইল সম্পাদনা',
      'logout': 'লগ আউট',
      'account_settings': 'অ্যাকাউন্ট সেটিংস',
      'notifications': 'বিজ্ঞপ্তি',
      'privacy': 'গোপনীয়তা',
      'help_support': 'সাহায্য ও সহায়তা',
      'about': 'সম্পর্কে',
      'version': 'সংস্করণ',
      'logout_confirmation': 'আপনি কি নিশ্চিত যে লগ আউট করতে চান?',

      // AI Chat
      'ai_assistant': 'AI সহায়ক',
      'ask_anything': 'কৃষি সম্পর্কে কিছু জিজ্ঞাসা করুন...',
      'send': 'পাঠান',
      'typing': 'AI টাইপ করছে...',
      'chat_history': 'চ্যাট ইতিহাস',
      'new_chat': 'নতুন চ্যাট',
      'clear_chat': 'চ্যাট সাফ করুন',
      'clear_chat_confirmation': 'আপনি কি নিশ্চিত যে চ্যাট সাফ করতে চান?',
      'quick_questions': 'দ্রুত প্রশ্ন',

      // Tabs
      'home': 'হোম',
      'chat': 'চ্যাট',
      'calendar': 'ক্যালেন্ডার',
      'profile_tab': 'প্রোফাইল',

      // Schedule Tab
      'schedule': 'সময়সূচী',
      'plan_farming_activities': 'আপনার কৃষি কার্যক্রম পরিকল্পনা করুন',
      'today': 'আজ',
      'this_week': 'এই সপ্তাহ',
      'completed': 'সম্পূর্ণ',
      'this_month': 'এই মাসে',
      'upcoming_tasks': 'আসন্ন কাজ',
      'water_tomato_plants': 'টমেটো গাছ জল দিন',
      'check_soil_moisture':
          'মাটির আর্দ্রতা পরীক্ষা করুন এবং প্রয়োজন হলে জল দিন',
      'apply_fertilizer': 'সার প্রয়োগ করুন',
      'apply_nitrogen_fertilizer':
          'ভুট্টা ক্ষেতে নাইট্রোজেন সমৃদ্ধ সার প্রয়োগ করুন',
      'pest_inspection': 'পোকামাকড় পরিদর্শন',
      'check_for_aphids': 'এফিড এবং অন্যান্য পোকামাকড়ের জন্য পরীক্ষা করুন',
      'harvest_lettuce': 'লেটুস কাটুন',
      'harvest_mature_lettuce': 'পাকা লেটুসের মাথা কাটুন',
      'monday': 'সোমবার',
      'tuesday': 'মঙ্গলবার',
      'wednesday': 'বুধবার',
      'thursday': 'বৃহস্পতিবার',
      'friday': 'শুক্রবার',
      'saturday': 'শনিবার',
      'sunday': 'রবিবার',
      'tomorrow': 'আগামীকাল',

      // AI Chat Tab
      'get_farming_insights': 'কৃষি অন্তর্দৃষ্টি এবং পরামর্শ পান',
      'hello_ai_assistant':
          'হ্যালো! আমি আপনার AI কৃষি সহায়ক। আজ আমি আপনাকে কীভাবে সাহায্য করতে পারি? আপনি আমাকে ফসল ব্যবস্থাপনা, পোকামাকড় নিয়ন্ত্রণ, আবহাওয়া পরামর্শ বা অন্য কোন কৃষি প্রশ্ন সম্পর্কে জিজ্ঞাসা করতে পারেন।',
      'when_water_tomatoes': 'আমার টমেটোতে কখন জল দেব?',
      'how_deal_aphids': 'এফিডের সাথে কীভাবে মোকাবিলা করব?',
      'best_fertilizer_corn': 'ভুট্টার জন্য সেরা সার?',
      'weather_forecast_impact': 'আবহাওয়া পূর্বাভাস প্রভাব',
      'crop_rotation_advice': 'ফসল আবর্তন পরামর্শ',
      'soil_ph_management': 'মাটির pH ব্যবস্থাপনা',
      'optimal_watering_advice':
          'সর্বোত্তম জল দেওয়ার জন্য, মাটির আর্দ্রতা 2-3 ইঞ্চি গভীরে পরীক্ষা করুন। বাষ্পীভবন কমাতে সকালে বা সন্ধ্যায় জল দিন। বেশিরভাগ ফসলে সপ্তাহে 1-2 ইঞ্চি জল প্রয়োজন।',
      'tomato_watering_advice':
          'টমেটোতে সামঞ্জস্যপূর্ণ জল দেওয়া প্রয়োজন - খরা চাপ এবং অতিরিক্ত জল দেওয়া উভয়ই এড়ান। পাতার রোগ প্রতিরোধ করতে গোড়ায় জল দিন। মালচিং আর্দ্রতা ধরে রাখতে সাহায্য করে।',
      'fertilizer_advice':
          'বৃদ্ধির সময়ে ভারসাম্যপূর্ণ সার ব্যবহার করুন (N-P-K 10-10-10), তারপর ফুল/ফল ধারণের পর্যায়ে কম নাইট্রোজেনে স্যুইচ করুন। সর্বদা প্রথমে মাটি পরীক্ষা করুন।',
      'pest_management_advice':
          'সমন্বিত কীট ব্যবস্থাপনা (IPM) সেরা: উপকারী পোকামাকড়, ফসল আবর্তন এবং প্রয়োজন হলে লক্ষ্যযুক্ত চিকিৎসা ব্যবহার করুন। নিয়মিত পর্যবেক্ষণ গুরুত্বপূর্ণ।',
      'weather_advice':
          'স্থানীয় আবহাওয়া পূর্বাভাস পরীক্ষা করুন এবং কার্যক্রম তদনুযায়ী সামঞ্জস্য করুন। ভারী বৃষ্টির আগে সার দেওয়া এড়ান এবং চরম আবহাওয়া থেকে সংবেদনশীল গাছপালা রক্ষা করুন।',
      'general_ai_response':
          'এটি একটি দুর্দান্ত প্রশ্ন! সবচেয়ে সঠিক পরামর্শের জন্য, আমি স্থানীয় কৃষি সম্প্রসারণ পরিষেবা বা মাটি পরীক্ষার ল্যাবের সাথে পরামর্শ করার পরামর্শ দেব। আপনি কি কৃষির কোন নির্দিষ্ট দিক সম্পর্কে আরও জানতে চান?',
    },
    'te': {
      // Onboarding
      'add_your_crops': 'మీ పంటలను జోడించండి',
      'select_crops_description':
          'మీరు పండించే పంటలను ఎంచుకోవడానికి ట్యాప్ చేయండి. ఇది మాకు వ్యక్తిగత అంతర్దృష్టులు మరియు సిఫార్సులను అందించడంలో సహాయపడుతుంది.',
      'search_crops': 'పంటలను వెతకండి...',
      'crops_selected': 'పంటలు ఎంచుకోబడ్డాయి',
      'crop_selected': 'పంట ఎంచుకోబడింది',
      'next': 'తదుపరి',
      'get_started': 'ప్రారంభించండి',
      'skip': 'దాటవేయి',
      'welcome_to_farmlytics': 'ఫార్మ్లిటిక్స్‌కు స్వాగతం',
      'welcome_description':
          'మీ AI-ఆధారిత వ్యవసాయ సహాయకుడు, ఇది మంచి పంట దిగుబడుల కోసం మీరు తెలివైన నిర్ణయాలు తీసుకోవడంలో సహాయపడుతుంది.',
      'smart_scheduling': 'స్మార్ట్ షెడ్యూలింగ్',
      'scheduling_description':
          'వాతావరణం మరియు పంట చక్రాల ఆధారంగా తెలివైన షెడ్యూలింగ్‌తో మీ వ్యవసాయ కార్యకలాపాలను ప్రణాళిక మరియు ట్రాక్ చేయండి.',
      'ai_chat_assistant': 'AI చాట్ సహాయకుడు',
      'chat_description':
          'వ్యవసాయ ఉత్తమ అభ్యాసాలపై శిక్షణ పొందిన మా AI సహాయకుడి నుండి మీ వ్యవసాయ ప్రశ్నలకు తక్షణ సమాధానాలు పొందండి.',
      'data_driven_insights': 'డేటా-ఆధారిత అంతర్దృష్టులు',
      'insights_description':
          'వివరణాత్మక విశ్లేషణ మరియు వ్యక్తిగత సిఫార్సులతో మీ పొలం పనితీరును పర్యవేక్షించండి.',

      // Language Selection
      'choose_language': 'మీ భాషను ఎంచుకోండి',
      'language_description':
          'ఉత్తమ వ్యవసాయ అనుభవం కోసం మీకు ఇష్టమైన భాషను ఎంచుకోండి.',
      'continue': 'కొనసాగించండి',

      // Common
      'loading': 'లోడ్ అవుతోంది...',
      'error': 'లోపం',
      'retry': 'మళ్లీ ప్రయత్నించండి',
      'settings': 'సెట్టింగ్‌లు',
      'save': 'సేవ్ చేయండి',
      'cancel': 'రద్దు చేయండి',
      'done': 'పూర్తయింది',
      'close': 'మూసివేయండి',
      'back': 'వెనుకకు',
      'yes': 'అవును',
      'no': 'కాదు',
      'ok': 'సరే',

      // Home Screen
      'hi': 'హలో',
      'my_crops': 'నా పంటలు',
      'add': 'జోడించండి',
      'common_diseases': 'మీ పంటలకు సాధారణ వ్యాధులు',
      'add_crops_to_see_diseases':
          'సంబంధిత వ్యాధులను చూడటానికి పంటలను జోడించండి',
      'no_diseases_found': 'మీ పంటలకు వ్యాధులు కనుగొనబడలేదు',
      'government_programs': 'ప్రభుత్వ కార్యక్రమాలు',
      'no_programs_available': 'ప్రభుత్వ కార్యక్రమాలు అందుబాటులో లేవు',
      'farm_status': 'వ్యవసాయ భూమి స్థితి',
      'crops': 'పంటలు',
      'active': 'క్రియాశీల',
      'tasks': 'పనులు',
      'pending': 'పెండింగ్',
      'helping_farmers_grow': 'రైతులను పెంచడంలో సహాయం',
      'cultivated_with_love': '❤️ తో సాగు చేయబడింది',
      'getting_weather': 'వాతావరణ సమాచారం పొందుతోంది...',
      'weather_unavailable': 'వాతావరణ సమాచారం అందుబాటులో లేదు',
      'location_services_disabled': 'స్థాన సేవలు నిలిపివేయబడ్డాయి',
      'location_permission_denied': 'స్థాన అనుమతి తిరస్కరించబడింది',
      'location_permission_permanently_denied':
          'స్థాన అనుమతి శాశ్వతంగా తిరస్కరించబడింది. సెట్టింగ్‌లలో ప్రారంభించండి.',
      'failed_to_get_location': 'స్థానం పొందడంలో విఫలం',
      'add_crop_to_farm': 'మీ వ్యవసాయ భూమికి పంటను జోడించండి',
      'choose_crops_description':
          'మీ వ్యవసాయ డాష్‌బోర్డ్‌లో జోడించడానికి అందుబాటులో ఉన్న పంటల నుండి ఎంచుకోండి.',
      'failed_to_load_crops': 'పంటలను లోడ్ చేయడంలో విఫలం',
      'crop_added_to_farm': 'మీ వ్యవసాయ భూమికి జోడించబడింది!',
      'failed_to_add_crop': 'జోడించడంలో విఫలం',

      // Auth Screen
      'welcome_back': 'మళ్లీ స్వాగతం',
      'sign_in': 'సైన్ ఇన్',
      'sign_up': 'సైన్ అప్',
      'phone_number': 'ఫోన్ నంబర్',
      'enter_phone_number': 'మీ ఫోన్ నంబర్‌ను నమోదు చేయండి',
      'verification_code': 'ధృవీకరణ కోడ్',
      'enter_verification_code':
          'మీ ఫోన్‌కు పంపిన ధృవీకరణ కోడ్‌ను నమోదు చేయండి',
      'name': 'పేరు',
      'enter_your_name': 'మీ పేరును నమోదు చేయండి',
      'send_code': 'కోడ్ పంపండి',
      'verify': 'ధృవీకరించండి',
      'resend_code': 'కోడ్ మళ్లీ పంపండి',
      'invalid_phone_number':
          'దయచేసి చెల్లుబాటు అయ్యే ఫోన్ నంబర్‌ను నమోదు చేయండి',
      'invalid_verification_code':
          'దయచేసి చెల్లుబాటు అయ్యే ధృవీకరణ కోడ్‌ను నమోదు చేయండి',
      'invalid_name': 'దయచేసి మీ పేరును నమోదు చేయండి',
      'sign_in_successful': 'సైన్ ఇన్ విజయవంతం',
      'sign_up_successful': 'సైన్ అప్ విజయవంతం',
      'sign_in_failed': 'సైన్ ఇన్ విఫలం',
      'sign_up_failed': 'సైన్ అప్ విఫలం',
      'verification_failed': 'ధృవీకరణ విఫలం',
      'resend_code_in': 'కోడ్ మళ్లీ పంపండి',
      'seconds': 'సెకన్లు',

      // Profile Screen
      'profile': 'ప్రొఫైల్',
      'edit_profile': 'ప్రొఫైల్‌ను సవరించండి',
      'logout': 'లాగ్ అవుట్',
      'account_settings': 'ఖాతా సెట్టింగ్‌లు',
      'notifications': 'నోటిఫికేషన్‌లు',
      'privacy': 'గోప్యత',
      'help_support': 'సహాయం మరియు మద్దతు',
      'about': 'గురించి',
      'version': 'వెర్షన్',
      'logout_confirmation':
          'మీరు లాగ్ అవుట్ చేయాలని ఖచ్చితంగా అనుకుంటున్నారా?',

      // AI Chat
      'ai_assistant': 'AI సహాయకుడు',
      'ask_anything': 'వ్యవసాయం గురించి ఏదైనా అడగండి...',
      'send': 'పంపండి',
      'typing': 'AI టైప్ చేస్తోంది...',
      'chat_history': 'చాట్ చరిత్ర',
      'new_chat': 'కొత్త చాట్',
      'clear_chat': 'చాట్‌ను క్లియర్ చేయండి',
      'clear_chat_confirmation':
          'మీరు చాట్‌ను క్లియర్ చేయాలని ఖచ్చితంగా అనుకుంటున్నారా?',
      'quick_questions': 'త్వరిత ప్రశ్నలు',

      // Tabs
      'home': 'హోమ్',
      'chat': 'చాట్',
      'calendar': 'క్యాలెండర్',
      'profile_tab': 'ప్రొఫైల్',

      // Schedule Tab
      'schedule': 'షెడ్యూల్',
      'plan_farming_activities': 'మీ వ్యవసాయ కార్యకలాపాలను ప్లాన్ చేయండి',
      'today': 'ఈరోజు',
      'this_week': 'ఈ వారం',
      'completed': 'పూర్తయింది',
      'this_month': 'ఈ నెలలో',
      'upcoming_tasks': 'రాబోయే పనులు',
      'water_tomato_plants': 'టమాటా మొక్కలకు నీరు ఇవ్వండి',
      'check_soil_moisture': 'నేల తేమను తనిఖీ చేసి అవసరమైతే నీరు ఇవ్వండి',
      'apply_fertilizer': 'ఎరువు వేయండి',
      'apply_nitrogen_fertilizer': 'మొక్కజొన్న పొలంలో నైట్రోజన్ ఎరువు వేయండి',
      'pest_inspection': 'కీటక పరిశీలన',
      'check_for_aphids': 'ఆఫిడ్లు మరియు ఇతర కీటకాలను తనిఖీ చేయండి',
      'harvest_lettuce': 'లెట్యూస్ పండించండి',
      'harvest_mature_lettuce': 'పండిన లెట్యూస్ తలలను పండించండి',
      'monday': 'సోమవారం',
      'tuesday': 'మంగళవారం',
      'wednesday': 'బుధవారం',
      'thursday': 'గురువారం',
      'friday': 'శుక్రవారం',
      'saturday': 'శనివారం',
      'sunday': 'ఆదివారం',
      'tomorrow': 'రేపు',

      // AI Chat Tab
      'get_farming_insights': 'వ్యవసాయ అంతర్దృష్టులు మరియు సలహాలు పొందండి',
      'hello_ai_assistant':
          'హలో! నేను మీ AI వ్యవసాయ సహాయకుడిని. ఈరోజు నేను మీకు ఎలా సహాయం చేయగలను? మీరు నన్ను పంట నిర్వహణ, కీటక నియంత్రణ, వాతావరణ సలహా లేదా ఇతర వ్యవసాయ ప్రశ్నల గురించి అడగవచ్చు.',
      'when_water_tomatoes': 'నేను నా టమాటాలకు ఎప్పుడు నీరు ఇవ్వాలి?',
      'how_deal_aphids': 'ఆఫిడ్లతో ఎలా వ్యవహరించాలి?',
      'best_fertilizer_corn': 'మొక్కజొన్నకు ఉత్తమ ఎరువు?',
      'weather_forecast_impact': 'వాతావరణ పూర్వానుమాన ప్రభావం',
      'crop_rotation_advice': 'పంట భ్రమణ సలహా',
      'soil_ph_management': 'నేల pH నిర్వహణ',
      'optimal_watering_advice':
          'ఉత్తమ నీటిపారుదల కోసం, నేల తేమను 2-3 అంగుళాల లోతులో తనిఖీ చేయండి. బాష్పీభవనం తగ్గించడానికి ఉదయం లేదా సాయంత్రం నీరు ఇవ్వండి. చాలా పంటలకు వారానికి 1-2 అంగుళాల నీరు అవసరం.',
      'tomato_watering_advice':
          'టమాటాలకు స్థిరమైన నీటిపారుదల అవసరం - కరువు ఒత్తిడి మరియు అధిక నీటిపారుదల రెండింటినీ నివారించండి. ఆకు వ్యాధులను నివారించడానికి వేర్ల వద్ద నీరు ఇవ్వండి. మల్చింగ్ తేమను నిలుపుకోవడంలో సహాయపడుతుంది.',
      'fertilizer_advice':
          'వృక్ష వృద్ధి సమయంలో సమతుల్య ఎరువులను ఉపయోగించండి (N-P-K 10-10-10), తర్వాత పుష్పించే/పండించే దశలలో తక్కువ నైట్రోజన్‌కు మారండి. ఎల్లప్పుడూ మొదట నేలను పరీక్షించండి.',
      'pest_management_advice':
          'సమగ్ర కీటక నిర్వహణ (IPM) ఉత్తమం: ప్రయోజనకరమైన కీటకాలు, పంట భ్రమణ మరియు అవసరమైనప్పుడు లక్ష్యిత చికిత్సలను ఉపయోగించండి. నియమిత పర్యవేక్షణ ముఖ్యం.',
      'weather_advice':
          'స్థానిక వాతావరణ పూర్వానుమానాలను తనిఖీ చేసి కార్యకలాపాలను తదనుగుణంగా సర్దుబాటు చేయండి. భారీ వర్షాల ముందు ఎరువు వేయడం నివారించండి మరియు తీవ్రమైన వాతావరణం నుండి సున్నితమైన మొక్కలను రక్షించండి.',
      'general_ai_response':
          'అది ఒక గొప్ప ప్రశ్న! అత్యంత ఖచ్చితమైన సలహా కోసం, స్థానిక వ్యవసాయ విస్తరణ సేవలు లేదా నేల పరీక్షా ప్రయోగశాలలతో సంప్రదించమని నేను సిఫారసు చేస్తాను. వ్యవసాయంలోని నిర్దిష్ట అంశం గురించి మీరు మరింత అన్వేషించాలనుకుంటున్నారా?',
    },
  };

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? 'en';
  }

  static String getCurrentLanguage() {
    return _currentLanguage;
  }

  static Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    // Clear translation cache when language changes
    clearTranslationCache();

    // Pre-load common translations in background
    preloadCommonTranslations();
  }

  static String translate(String key) {
    final translations =
        _translations[_currentLanguage] ?? _translations['en']!;
    return translations[key] ?? key;
  }

  static String t(String key) {
    return translate(key);
  }

  // Automatic translation methods
  static Future<String> translateText(
    String text, {
    String? targetLanguage,
  }) async {
    if (text.isEmpty) return text;

    final target = targetLanguage ?? _currentLanguage;
    print('🔍 Translating: "$text" to $target');

    if (target == 'en') {
      print('✅ No translation needed (English)');
      return text; // No need to translate English to English
    }

    // Try MyMemory API first (free)
    final myMemoryResult = await _translateWithMyMemory(text, target);
    if (myMemoryResult != text) {
      return myMemoryResult;
    }

    // Fallback to Google Cloud Translation API
    print('🔄 MyMemory failed, trying Google Cloud Translation API...');
    final googleResult = await _translateWithGoogle(text, target);
    if (googleResult != text) {
      return googleResult;
    }

    print('❌ All translation methods failed, returning original text');
    return text;
  }

  // MyMemory Translation API (free tier)
  static Future<String> _translateWithMyMemory(
    String text,
    String target,
  ) async {
    try {
      // Convert our language codes to MyMemory API codes
      String apiLanguageCode;
      switch (target) {
        case 'hi':
          apiLanguageCode = 'hi'; // Hindi
          break;
        case 'bn':
          apiLanguageCode = 'bn'; // Bengali
          break;
        case 'te':
          apiLanguageCode = 'te'; // Telugu
          break;
        default:
          apiLanguageCode = target;
      }

      final url =
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|$apiLanguageCode';

      print('🌐 MyMemory API URL: $url');

      final response = await http.get(Uri.parse(url));
      print('📡 MyMemory Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📄 MyMemory Response data: $data');

        // Check different possible response formats
        String? translatedText;

        // Format 1: Standard MyMemory format
        if (data['responseStatus'] == 200 && data['responseData'] != null) {
          translatedText = data['responseData']['translatedText'];
        }
        // Format 2: Alternative format
        else if (data['translatedText'] != null) {
          translatedText = data['translatedText'];
        }
        // Format 3: Direct translation field
        else if (data['translation'] != null) {
          translatedText = data['translation'];
        }

        print('✅ MyMemory Translation result: "$translatedText"');

        if (translatedText != null &&
            translatedText.isNotEmpty &&
            translatedText != text) {
          return translatedText;
        }
      }

      print('❌ MyMemory translation failed');
      return text;
    } catch (e) {
      print('💥 MyMemory translation error: $e');
      return text;
    }
  }

  // Google Cloud Translation API (requires API key)
  static Future<String> _translateWithGoogle(String text, String target) async {
    // Skip if no API key configured
    if (_googleApiKey.isEmpty) {
      print('⚠️ Google API key not configured, skipping Google translation');
      return text;
    }

    try {
      // Convert our language codes to Google API codes
      String googleLanguageCode;
      switch (target) {
        case 'hi':
          googleLanguageCode = 'hi'; // Hindi
          break;
        case 'bn':
          googleLanguageCode = 'bn'; // Bengali
          break;
        case 'te':
          googleLanguageCode = 'te'; // Telugu
          break;
        default:
          googleLanguageCode = target;
      }

      final url = '$_googleTranslateUrl?key=$_googleApiKey';

      final requestBody = {
        'q': text,
        'target': googleLanguageCode,
        'source': 'en',
        'format': 'text',
      };

      print('🌐 Google API URL: $url');
      print('📤 Google API Request: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📡 Google Response status: ${response.statusCode}');
      print('📄 Google Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null &&
            data['data']['translations'] != null &&
            data['data']['translations'].isNotEmpty) {
          final translatedText =
              data['data']['translations'][0]['translatedText'];
          print('✅ Google Translation result: "$translatedText"');

          if (translatedText != null &&
              translatedText.isNotEmpty &&
              translatedText != text) {
            return translatedText;
          }
        }
      }

      print('❌ Google translation failed');
      return text;
    } catch (e) {
      print('💥 Google translation error: $e');
      return text;
    }
  }

  // Translate crop names from database
  static Future<String> translateCrop(String cropName) async {
    // First check if we have a manual translation
    final manualTranslation =
        _translations[_currentLanguage]?[cropName.toLowerCase().replaceAll(
          ' ',
          '_',
        )];
    if (manualTranslation != null) {
      return manualTranslation;
    }

    // If no manual translation, use automatic translation
    return await translateText(cropName);
  }

  // Translate disease names from database
  static Future<String> translateDisease(String diseaseName) async {
    // First check if we have a manual translation
    final manualTranslation =
        _translations[_currentLanguage]?[diseaseName.toLowerCase().replaceAll(
          ' ',
          '_',
        )];
    if (manualTranslation != null) {
      return manualTranslation;
    }

    // If no manual translation, use automatic translation
    return await translateText(diseaseName);
  }

  // Translate government program names from database
  static Future<String> translateProgram(String programName) async {
    // First check if we have a manual translation
    final manualTranslation =
        _translations[_currentLanguage]?[programName.toLowerCase().replaceAll(
          ' ',
          '_',
        )];
    if (manualTranslation != null) {
      return manualTranslation;
    }

    // If no manual translation, use automatic translation
    return await translateText(programName);
  }

  // Translate any database content
  static Future<String> translateDatabaseContent(String content) async {
    if (content.isEmpty) return content;

    // First check if we have a manual translation
    final key = content.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    final manualTranslation = _translations[_currentLanguage]?[key];
    if (manualTranslation != null) {
      return manualTranslation;
    }

    // If no manual translation, use automatic translation
    return await translateText(content);
  }

  // Batch translate multiple items
  static Future<List<String>> translateBatch(List<String> items) async {
    final List<String> translatedItems = [];

    for (final item in items) {
      final translated = await translateDatabaseContent(item);
      translatedItems.add(translated);
    }

    return translatedItems;
  }

  // Cache for translations to avoid repeated API calls
  static final Map<String, String> _translationCache = {};

  static Future<String> translateWithCache(String text) async {
    if (text.isEmpty) return text;

    final cacheKey = '${_currentLanguage}_$text';
    if (_translationCache.containsKey(cacheKey)) {
      print('💾 Cache hit for: "$text" -> "${_translationCache[cacheKey]}"');
      return _translationCache[cacheKey]!;
    }

    print('🔄 Cache miss for: "$text", translating...');
    final translated = await translateText(text);
    _translationCache[cacheKey] = translated;
    print('💾 Cached: "$text" -> "$translated"');

    return translated;
  }

  // Get cached translation synchronously
  static String? getCachedTranslation(String text) {
    if (text.isEmpty) return text;

    final cacheKey = '${_currentLanguage}_$text';
    final cached = _translationCache[cacheKey];
    if (cached != null) {
      print('⚡ Sync cache hit for: "$text" -> "$cached"');
    } else {
      print('❌ Sync cache miss for: "$text"');
    }
    return cached;
  }

  // Pre-load common translations to improve user experience
  static Future<void> preloadCommonTranslations() async {
    if (_currentLanguage == 'en') return; // No need to preload English

    final commonTexts = [
      'Rice',
      'Wheat',
      'Corn',
      'Tomato',
      'Potato',
      'Onion',
      'Carrot',
      'Common diseases',
      'Government programs',
      'Weather forecast',
      'Crop management',
      'Pest control',
      'Fertilizer application',
      'Soil testing',
      'Irrigation',
      'Harvesting',
      'Planting',
    ];

    // Pre-load translations in background
    for (final text in commonTexts) {
      if (!_translationCache.containsKey('${_currentLanguage}_$text')) {
        try {
          final translated = await translateText(text);
          _translationCache['${_currentLanguage}_$text'] = translated;
        } catch (e) {
          // Ignore errors for preloading
        }
      }
    }
  }

  // Debug method to test translation system
  static Future<void> debugTranslation() async {
    print('🔧 === TRANSLATION DEBUG ===');
    print('Current language: $_currentLanguage');
    print('Cache size: ${_translationCache.length}');
    print('Cache contents: $_translationCache');
    print('Google API Key configured: ${_googleApiKey.isNotEmpty}');
    print(
      'Google API Key value: ${_googleApiKey.isNotEmpty ? '***${_googleApiKey.substring(_googleApiKey.length - 4)}' : 'Not set'}',
    );

    // Test a simple translation
    print('Testing translation of "Rice"...');
    final result = await translateText('Rice');
    print('Final Result: $result');

    // Test MyMemory API directly
    print('Testing MyMemory API directly...');
    try {
      final url =
          'https://api.mymemory.translated.net/get?q=Rice&langpair=en|hi';
      print('MyMemory API URL: $url');
      final response = await http.get(Uri.parse(url));
      print('MyMemory API Response: ${response.statusCode}');
      print('MyMemory API Body: ${response.body}');
    } catch (e) {
      print('MyMemory API Error: $e');
    }

    // Test Google API directly (if key is configured)
    if (_googleApiKey.isNotEmpty) {
      print('Testing Google API directly...');
      try {
        final url = '$_googleTranslateUrl?key=$_googleApiKey';
        final requestBody = {
          'q': 'Rice',
          'target': 'hi',
          'source': 'en',
          'format': 'text',
        };
        print('Google API URL: $url');
        print('Google API Request: $requestBody');
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        print('Google API Response: ${response.statusCode}');
        print('Google API Body: ${response.body}');
      } catch (e) {
        print('Google API Error: $e');
      }
    } else {
      print('⚠️ Google API key not configured, skipping Google API test');
    }

    print('🔧 === END DEBUG ===');
  }

  // Clear translation cache (useful when language changes)
  static void clearTranslationCache() {
    _translationCache.clear();
  }
}
