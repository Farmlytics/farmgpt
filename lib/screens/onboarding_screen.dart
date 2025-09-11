import 'package:flutter/material.dart';
import 'package:farmlytics/screens/home_screen.dart';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/services/language_service.dart';
import 'package:farmlytics/models/crop.dart';
import 'package:farmlytics/widgets/translated_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<Crop> _allCrops = [];
  List<Crop> _filteredCrops = [];
  final List<String> _selectedCropIds = [];
  bool _isLoadingCrops = true;

  List<OnboardingData> get _pages => [
    OnboardingData(
      icon: Icons.grass_outlined,
      title: LanguageService.t('add_your_crops'),
      description: LanguageService.t('select_crops_description'),
      color: const Color(0xFF1FBA55),
    ),
    OnboardingData(
      icon: Icons.agriculture_outlined,
      title: LanguageService.t('welcome_to_farmlytics'),
      description: LanguageService.t('welcome_description'),
      color: const Color(0xFF1FBA55),
    ),
    OnboardingData(
      icon: Icons.schedule_outlined,
      title: LanguageService.t('smart_scheduling'),
      description: LanguageService.t('scheduling_description'),
      color: const Color(0xFFFF9800),
    ),
    OnboardingData(
      icon: Icons.chat_outlined,
      title: LanguageService.t('ai_chat_assistant'),
      description: LanguageService.t('chat_description'),
      color: const Color(0xFF2196F3),
    ),
    OnboardingData(
      icon: Icons.analytics_outlined,
      title: LanguageService.t('data_driven_insights'),
      description: LanguageService.t('insights_description'),
      color: const Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _fetchCrops();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  Future<void> _fetchCrops() async {
    try {
      final crops = await AuthService().getCrops();
      if (mounted) {
        setState(() {
          _allCrops = crops;
          _filteredCrops = crops;
          _isLoadingCrops = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCrops = false;
        });
      }
    }
  }

  void _filterCrops(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCrops = _allCrops;
      } else {
        _filteredCrops = _allCrops.where((crop) {
          return crop.name.toLowerCase().contains(query.toLowerCase()) ||
              crop.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleCropSelection(String cropId) {
    setState(() {
      if (_selectedCropIds.contains(cropId)) {
        _selectedCropIds.remove(cropId);
      } else {
        _selectedCropIds.add(cropId);
      }
    });
  }

  Future<void> _saveSelectedCrops() async {
    try {
      for (String cropId in _selectedCropIds) {
        await AuthService().addCropToUserFarm(cropId: cropId);
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  void _goToHome() async {
    // Save selected crops if we're on the crop selection page
    if (_currentPage == 0 && _selectedCropIds.isNotEmpty) {
      await _saveSelectedCrops();
    }

    // Mark onboarding as completed
    try {
      await AuthService().markOnboardingCompleted();
    } catch (e) {
      // Handle error silently for now
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'farmlytics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'FunnelDisplay',
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: _goToHome,
                        child: Text(
                          LanguageService.t('skip'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCropSelectionPage();
                      }
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),

                // Page indicators
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Selected count (only show on crop selection page)
                if (_currentPage == 0 && _selectedCropIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '${_selectedCropIds.length} ${_selectedCropIds.length == 1 ? LanguageService.t('crop_selected') : LanguageService.t('crops_selected')}',
                      style: TextStyle(
                        color: const Color(0xFF1FBA55),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                if (_currentPage == 0 && _selectedCropIds.isNotEmpty)
                  const SizedBox(height: 8),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: _currentPage > 0 ? 1 : 2,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? LanguageService.t('get_started')
                                : LanguageService.t('next'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: data.color.withOpacity(0.3), width: 1),
            ),
            child: Icon(data.icon, color: data.color, size: 60),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'FunnelDisplay',
              height: 1.2,
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelectionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            LanguageService.t('add_your_crops'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'FunnelDisplay',
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            LanguageService.t('select_crops_description'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 16),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: const Color(0xFF1FBA55),
              decoration: InputDecoration(
                hintText: LanguageService.t('search_crops'),
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.6),
                  size: 18,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                filled: false,
                isDense: true,
              ),
              onChanged: _filterCrops,
            ),
          ),

          const SizedBox(height: 12),

          // Crops list
          Expanded(
            child: _isLoadingCrops
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1FBA55),
                      ),
                    ),
                  )
                : _filteredCrops.isEmpty
                ? Center(
                    child: Text(
                      'No crops found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _filteredCrops.length,
                    itemBuilder: (context, index) {
                      final crop = _filteredCrops[index];
                      final isSelected = _selectedCropIds.contains(crop.id);

                      return GestureDetector(
                        onTap: () => _toggleCropSelection(crop.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1FBA55).withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1FBA55).withOpacity(0.5)
                                  : Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crop.categoryColor.withOpacity(0.08),
                                ),
                                child: crop.hasIcon
                                    ? Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: ClipOval(
                                          child: Image.network(
                                            crop.iconUrl!,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.grass,
                                                    color: crop.categoryColor,
                                                    size: 12,
                                                  );
                                                },
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.grass,
                                        color: crop.categoryColor,
                                        size: 12,
                                      ),
                              ),
                              const SizedBox(height: 4),
                              TranslatedCropName(
                                crop.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(1),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1FBA55),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _pages[_currentPage].color
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
