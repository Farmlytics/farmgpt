import 'package:flutter/material.dart';
import 'dart:async';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/models/info_card.dart';
import 'package:farmlytics/models/user_crop.dart';
import 'package:farmlytics/models/crop.dart';
import 'package:farmlytics/models/weather.dart';
import 'package:farmlytics/models/disease.dart';
import 'package:farmlytics/models/government_program.dart';
import 'package:farmlytics/screens/profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<InfoCard> _infoCards = [];
  bool _isLoadingCards = true;
  PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentCardIndex = 0;
  List<UserCrop> _userCrops = [];
  bool _isLoadingUserCrops = true;
  List<Crop> _allCrops = [];
  List<Crop> _filteredCrops = [];
  Weather? _weather;
  bool _isLoadingWeather = true;
  String? _locationError;
  List<Disease> _diseases = [];
  bool _isLoadingDiseases = true;
  List<GovernmentProgram> _governmentPrograms = [];
  bool _isLoadingGovernmentPrograms = true;
  String? _userName;
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchInfoCards();
    _fetchUserCrops(); // This will call _fetchDiseases() after crops are loaded
    _fetchWeather();
    _fetchGovernmentPrograms();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    try {
      final authService = AuthService();
      final userProfile = await authService.getUserProfile();
      if (mounted) {
        setState(() {
          _userName = userProfile?['name'];
          _isLoadingName = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = null;
          _isLoadingName = false;
        });
      }
    }
  }

  String _getFirstName() {
    if (_userName == null || _userName!.isEmpty) return 'user';
    final parts = _userName!.trim().split(' ');
    return parts.isNotEmpty ? parts.first.toLowerCase() : 'user';
  }

  Future<void> _fetchInfoCards() async {
    try {
      final authService = AuthService();
      final cards = await authService.getInfoCards();
      if (mounted) {
        setState(() {
          _infoCards = cards;
          _isLoadingCards = false;
        });
        _startAutoScroll();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _infoCards = [];
          _isLoadingCards = false;
        });
      }
    }
  }

  void _startAutoScroll() {
    if (_infoCards.length <= 1)
      return; // Don't auto-scroll if only one card or no cards

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || _infoCards.isEmpty) {
        timer.cancel();
        return;
      }

      _currentCardIndex = (_currentCardIndex + 1) % _infoCards.length;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentCardIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  Future<void> _fetchUserCrops() async {
    try {
      final authService = AuthService();
      final crops = await authService.getUserCrops();
      if (mounted) {
        setState(() {
          _userCrops = crops;
          _isLoadingUserCrops = false;
        });
        // Fetch diseases after user crops are loaded
        _fetchDiseases();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userCrops = [];
          _isLoadingUserCrops = false;
        });
        // Still try to fetch diseases even if user crops fail
        _fetchDiseases();
      }
      print('Error fetching user crops: $e');
    }
  }

  void _filterCrops(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCrops = _allCrops;
      } else {
        _filteredCrops = _allCrops.where((crop) {
          return crop.name.toLowerCase().contains(query.toLowerCase()) ||
              crop.category.toLowerCase().contains(query.toLowerCase()) ||
              (crop.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  Future<void> _fetchWeather() async {
    try {
      setState(() {
        _isLoadingWeather = true;
        _locationError = null;
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled';
          _isLoadingWeather = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permission denied';
            _isLoadingWeather = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permission permanently denied. Enable in settings.';
          _isLoadingWeather = false;
        });
        return;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Fetch weather data
      final weather = await AuthService().getWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Failed to get location: ${e.toString()}';
          _isLoadingWeather = false;
        });
      }
      print('Weather fetch error: $e');
    }
  }

  Future<void> _fetchDiseases() async {
    try {
      setState(() {
        _isLoadingDiseases = true;
      });

      final allDiseases = await AuthService().getCommonDiseases();

      // Get user's crop names
      final userCropNames = _userCrops
          .where((userCrop) => userCrop.crop != null)
          .map((userCrop) => userCrop.crop!.name)
          .toSet();

      // Filter diseases that affect user's crops
      final relevantDiseases = allDiseases.where((disease) {
        // If disease affects "All crops", include it
        if (disease.affectedCrops.any(
          (crop) => crop.toLowerCase() == 'all crops',
        )) {
          return true;
        }

        // Check if any of the user's crops are affected by this disease
        return disease.affectedCrops.any((affectedCrop) {
          return userCropNames.any(
            (userCrop) =>
                userCrop.toLowerCase().contains(affectedCrop.toLowerCase()) ||
                affectedCrop.toLowerCase().contains(userCrop.toLowerCase()),
          );
        });
      }).toList();

      // Sort diseases by severity (severe first, then moderate, then mild)
      relevantDiseases.sort((a, b) {
        const severityOrder = {'severe': 0, 'moderate': 1, 'mild': 2};
        final aOrder = severityOrder[a.severity.toLowerCase()] ?? 3;
        final bOrder = severityOrder[b.severity.toLowerCase()] ?? 3;

        if (aOrder != bOrder) {
          return aOrder.compareTo(bOrder);
        }

        // If same severity, sort alphabetically by name
        return a.name.compareTo(b.name);
      });

      if (mounted) {
        setState(() {
          _diseases = relevantDiseases;
          _isLoadingDiseases = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _diseases = [];
          _isLoadingDiseases = false;
        });
      }
      print('Disease fetch error: $e');
    }
  }

  Future<void> _fetchGovernmentPrograms() async {
    try {
      setState(() {
        _isLoadingGovernmentPrograms = true;
      });

      final programs = await AuthService().getActiveGovernmentPrograms();

      if (mounted) {
        setState(() {
          _governmentPrograms = programs;
          _isLoadingGovernmentPrograms = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _governmentPrograms = [];
          _isLoadingGovernmentPrograms = false;
        });
      }
      print('Government programs fetch error: $e');
    }
  }

  Widget _buildWeatherBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 8, 30, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color:
            _weather?.backgroundColor.withOpacity(0.1) ??
            Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _weather?.backgroundColor.withOpacity(0.2) ??
              Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: _isLoadingWeather
          ? Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1FBA55),
                    ),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Getting weather...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontFamily: 'FunnelDisplay',
                  ),
                ),
              ],
            )
          : _locationError != null
          ? Row(
              children: [
                Icon(
                  Icons.location_off,
                  color: Colors.orange.withOpacity(0.8),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _locationError!,
                    style: TextStyle(
                      color: Colors.orange.withOpacity(0.8),
                      fontSize: 14,
                      fontFamily: 'FunnelDisplay',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _locationError!.contains('permanently denied')
                      ? () async {
                          await Geolocator.openAppSettings();
                        }
                      : _fetchWeather,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    _locationError!.contains('permanently denied')
                        ? 'Settings'
                        : 'Retry',
                    style: TextStyle(
                      color: Color(0xFF1FBA55),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          : _weather != null
          ? Row(
              children: [
                // Weather Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _weather!.backgroundColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _weather!.iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.wb_sunny,
                          color: _weather!.backgroundColor,
                          size: 20,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Weather Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            _weather!.formattedTemp,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'FunnelDisplay',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _weather!.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _weather!.weatherMessage,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Additional Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.white.withOpacity(0.6),
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${_weather!.humidity}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.air,
                          color: Colors.white.withOpacity(0.6),
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${_weather!.windSpeed.toStringAsFixed(1)}m/s',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  color: Colors.white.withOpacity(0.5),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Weather unavailable',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontFamily: 'FunnelDisplay',
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          floating: true,
          snap: true,
          expandedHeight: 80,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _isLoadingName
                                ? Text(
                              'farmlytics',
                              style: TextStyle(
                                      fontSize: 28,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'FunnelDisplay',
                                color: Colors.white,
                                      letterSpacing: -0.8,
                                    ),
                                  )
                                : Text(
                                    'hi, ${_getFirstName()}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'FunnelDisplay',
                                      color: Colors.white,
                                      letterSpacing: -0.8,
                              ),
                            ),
                            Text(
                              'welcome to farmlytics',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFF1FBA55).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF1FBA55).withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                            Icons.person_outline,
                            color: const Color(0xFF1FBA55),
                          size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Content
        SliverPadding(
          padding: const EdgeInsets.all(0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Weather Bar
              _buildWeatherBar(),

              // Info Cards Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildInfoCardsCarousel(),
              ),

              const SizedBox(height: 32),

              // My Crops Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildMyCropsSection(),
              ),

              const SizedBox(height: 32),

              // Most Common Diseases Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildDiseasesSection(),
              ),

              const SizedBox(height: 32),

              // Government Programs Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildGovernmentProgramsSection(),
              ),

              const SizedBox(height: 32),

              // Farm Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'FunnelDisplay',
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            title: 'Crops',
                            value: '12',
                            subtitle: 'Active',
                            color: const Color(0xFF1FBA55),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatusCard(
                            title: 'Tasks',
                            value: '5',
                            subtitle: 'Pending',
                            color: const Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // Footer
              _buildFooter(),

              const SizedBox(height: 32), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'FunnelDisplay',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardsCarousel() {
    if (_isLoadingCards) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1FBA55)),
          ),
        ),
      );
    }

    if (_infoCards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('👋', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'FunnelDisplay',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
              'Ready to optimize your farming with insights and recommendations.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _infoCards.length,
            onPageChanged: (index) {
              setState(() {
                _currentCardIndex = index;
              });
              // Pause auto-scroll when user manually scrolls
              _stopAutoScroll();
              // Restart auto-scroll after 5 seconds of no interaction
              Timer(const Duration(seconds: 5), () {
                if (mounted) _startAutoScroll();
              });
            },
            itemBuilder: (context, index) {
              final card = _infoCards[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card.priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: card.priorityColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: card.priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            card.iconData,
                            color: card.priorityColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'FunnelDisplay',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                card.priorityLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: card.priorityColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (card.actionText != null)
                          IconButton(
                            onPressed: () {
                              // Handle action - could navigate or show details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${card.actionText} - ${card.title}',
                                  ),
                                  backgroundColor: card.priorityColor,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: card.priorityColor,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        card.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_infoCards.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _infoCards.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCardIndex == index
                      ? _infoCards[index].priorityColor
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMyCropsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
              Text(
          'My Crops',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: 'FunnelDisplay',
                ),
              ),
              const SizedBox(height: 16),
        _isLoadingUserCrops
            ? Container(
                height: 80,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1FBA55),
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _userCrops.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == _userCrops.length) {
                      // Add crop button
                      return _buildAddCropButton();
                    }
                    final userCrop = _userCrops[index];
                    return _buildCropIcon(userCrop);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildCropIcon(UserCrop userCrop) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
                children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: userCrop.crop?.categoryColor.withOpacity(0.08),
            ),
            child: userCrop.crop?.hasIcon == true
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Image.network(
                        userCrop.crop!.iconUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.grass,
                            color: userCrop.crop?.categoryColor ?? Colors.grey,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  )
                : Icon(
                    Icons.grass,
                    color: userCrop.crop?.categoryColor ?? Colors.grey,
                    size: 24,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            userCrop.crop?.name ?? 'Unknown',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
    );
  }

  Widget _buildAddCropButton() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showAddCropDialog(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1FBA55).withOpacity(0.08),
              ),
              child: const Icon(Icons.add, color: Color(0xFF1FBA55), size: 30),
            ),
          ),
          const SizedBox(height: 4),
              Text(
            'Add',
                style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCropDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Crop to Your Farm',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'FunnelDisplay',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose from available crops to add to your farming dashboard.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 19),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.white.withOpacity(0.8),
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(2),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: const Color(0xFF1FBA55),
                    decoration: InputDecoration(
                      hintText: 'Search crops...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.6),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: false,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      _filterCrops(value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Crops list
                  Expanded(
                child: FutureBuilder<List<Crop>>(
                  future: AuthService().getCrops(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Fetch all crops when data is loaded
                      if (snapshot.hasData && _allCrops.isEmpty) {
                        _allCrops = snapshot.data!;
                        _filteredCrops = _allCrops;
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1FBA55),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load crops',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                    ),
                  ),
                ],
              ),
                      );
                    }

                    // Initialize crops data if not done yet
                    if (_allCrops.isEmpty && snapshot.hasData) {
                      _allCrops = snapshot.data!;
                      _filteredCrops = _allCrops;
                    }

                    final crops = _filteredCrops;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        final crop = crops[index];
                        final userHasCrop = _userCrops.any(
                          (userCrop) => userCrop.cropId == crop.id,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: crop.categoryColor.withOpacity(0.08),
                              ),
                              child: crop.hasIcon
                                  ? Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: ClipOval(
                                        child: Image.network(
                                          crop.iconUrl!,
                                          width: 38,
                                          height: 38,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.grass,
                                                  color: crop.categoryColor,
                                                  size: 18,
                                                );
                                              },
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.grass,
                                      color: crop.categoryColor,
                                      size: 18,
                                    ),
                            ),
                            title: Text(
                              crop.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: crop.categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    crop.category.toUpperCase(),
                                    style: TextStyle(
                                      color: crop.categoryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (crop.description != null) ...[
                                  const SizedBox(height: 4),
              Text(
                                    crop.description!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: userHasCrop
                                    ? const Color(0xFF1FBA55).withOpacity(0.2)
                                    : const Color(0xFF1FBA55).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                userHasCrop ? Icons.check : Icons.add,
                                color: const Color(0xFF1FBA55),
                                size: 20,
                              ),
                            ),
                            onTap: userHasCrop
                                ? null
                                : () async {
                                    try {
                                      await AuthService().addCropToUserFarm(
                                        cropId: crop.id,
                                      );
                                      Navigator.of(context).pop();
                                      _fetchUserCrops(); // Refresh the crops list
                                      _fetchDiseases(); // Refresh diseases for new crops
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${crop.name} added to your farm!',
                                          ),
                                          backgroundColor: const Color(
                                            0xFF1FBA55,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to add ${crop.name}',
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiseasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Diseases for Your Crops',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: 'FunnelDisplay',
                ),
              ),
              const SizedBox(height: 16),
        _isLoadingDiseases
            ? Container(
                height: 200,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1FBA55),
                    ),
                  ),
                ),
              )
            : _diseases.isEmpty
            ? Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        Icons.bug_report_outlined,
                      color: Colors.white.withOpacity(0.4),
                        size: 32,
                    ),
                      const SizedBox(height: 8),
                    Text(
                        _userCrops.isEmpty
                            ? 'Add crops to see relevant diseases'
                            : 'No diseases found for your crops',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              )
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _diseases.length,
                  itemBuilder: (context, index) {
                    final disease = _diseases[index];
                    return _buildDiseaseCard(disease);
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseCard(Disease disease) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Disease Image
                Container(
            height: 80,
                  decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Colors.white.withOpacity(0.1),
            ),
            child: disease.hasImage
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      disease.imageUrl,
                      width: double.infinity,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 80,
                          color: disease.severityColor.withOpacity(0.1),
                          child: Icon(
                            Icons.bug_report,
                            color: disease.severityColor,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 80,
                    color: disease.severityColor.withOpacity(0.1),
                    child: Icon(
                      Icons.bug_report,
                      color: disease.severityColor,
                      size: 32,
                    ),
                  ),
          ),

          // Disease Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Severity
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          disease.name,
                  style: const TextStyle(
                            fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                            fontFamily: 'FunnelDisplay',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: disease.severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: disease.severityColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              disease.severityIcon,
                              color: disease.severityColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                Text(
                              disease.severityLabel,
                              style: TextStyle(
                                color: disease.severityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    disease.shortDescription,
                  style: TextStyle(
                    fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                  const Spacer(),

                  // Affected Crops
                  Text(
                    'Affects: ${disease.affectedCropsText}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildGovernmentProgramsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Government Programs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'FunnelDisplay',
          ),
        ),
        const SizedBox(height: 16),
        _isLoadingGovernmentPrograms
            ? Container(
                height: 180,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1FBA55),
                    ),
                  ),
                ),
              )
            : _governmentPrograms.isEmpty
            ? Container(
                height: 120,
      padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance,
                        color: Colors.white.withOpacity(0.4),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No government programs available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _governmentPrograms.length,
                  itemBuilder: (context, index) {
                    final program = _governmentPrograms[index];
                    return _buildGovernmentProgramCard(program);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildGovernmentProgramCard(GovernmentProgram program) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Image
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Colors.white.withOpacity(0.1),
            ),
            child: program.hasImage
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      program.imageUrl,
                      width: double.infinity,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 80,
                          color: program.categoryColor.withOpacity(0.1),
                          child: Icon(
                            program.categoryIcon,
                            color: program.categoryColor,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 80,
                    color: program.categoryColor.withOpacity(0.1),
                    child: Icon(
                      program.categoryIcon,
                      color: program.categoryColor,
                      size: 32,
                    ),
                  ),
          ),

          // Program Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          program.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'FunnelDisplay',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: program.categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: program.categoryColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              program.categoryIcon,
                              color: program.categoryColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
          Text(
                              program.categoryLabel,
            style: TextStyle(
                                color: program.categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Description
          Text(
                    program.shortDescription,
            style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Amount and Deadline
                  Row(
                    children: [
                      if (program.maxAmount != null) ...[
                        Icon(
                          Icons.account_balance_wallet,
                          color: const Color(0xFF1FBA55),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.formattedAmount,
                          style: const TextStyle(
                            color: Color(0xFF1FBA55),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (program.deadline != null) ...[
                        const Spacer(),
                        Icon(
                          Icons.schedule,
                          color: program.isUrgent
                              ? const Color(0xFFE53E3E)
                              : Colors.white.withOpacity(0.6),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline',
                          style: TextStyle(
                            color: program.isUrgent
                                ? const Color(0xFFE53E3E)
                                : Colors.white.withOpacity(0.6),
                            fontSize: 10,
                            fontWeight: program.isUrgent
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Main tagline left aligned
          Text(
            'Helping Farmers Grow',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'FunnelDisplay',
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.left,
          ),

          const SizedBox(height: 16),

          // Bottom section with name and SIH info left aligned
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
          Text(
                    'Designed and Developed by ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final Uri url = Uri.parse('https://ashuwhy.com');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          // Fallback: try with platformDefault mode
                          await launchUrl(
                            url,
                            mode: LaunchMode.platformDefault,
                          );
                        }
                      } catch (e) {
                        print('Error launching URL: $e');
                        // Show a snackbar to inform user
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open link: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Ashutosh Sharma',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF1FBA55),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(
                          0xFF1FBA55,
                        ).withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'SIH • Farmlytics • IIT Khargpur • © 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
