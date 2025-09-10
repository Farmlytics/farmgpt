import 'package:flutter/material.dart';
import 'dart:async';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/models/info_card.dart';
import 'package:farmlytics/models/user_crop.dart';
import 'package:farmlytics/models/crop.dart';
import 'package:farmlytics/models/weather.dart';
import 'package:geolocator/geolocator.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _userName;
  bool _isLoadingName = true;
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

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchInfoCards();
    _fetchUserCrops();
    _fetchWeather();
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
    if (_userName == null || _userName!.isEmpty) return 'User';
    final parts = _userName!.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'User';
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userCrops = [];
          _isLoadingUserCrops = false;
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
          _locationError = 'Location permission permanently denied. Enable in settings.';
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

  Widget _buildWeatherBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 8, 30, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 60,
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
                     _locationError!.contains('permanently denied') ? 'Settings' : 'Retry',
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
                      const SizedBox(height: 2),
                      Text(
                        _weather!.weatherMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
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
                    const SizedBox(height: 2),
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'FunnelDisplay',
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  )
                                : Text(
                                    'hi, ${_getFirstName()}!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'FunnelDisplay',
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                            Text(
                              'welcome to farmlytics',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
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

              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'FunnelDisplay',
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildActionCard(
                          icon: Icons.chat_outlined,
                          title: 'AI Chat',
                          subtitle: 'Ask farming questions',
                          color: const Color(0xFF1DB954),
                        ),
                        _buildActionCard(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Weather',
                          subtitle: 'Check forecast',
                          color: const Color(0xFF2196F3),
                        ),
                        _buildActionCard(
                          icon: Icons.analytics_outlined,
                          title: 'Analytics',
                          subtitle: 'View farm data',
                          color: const Color(0xFF9C27B0),
                        ),
                        _buildActionCard(
                          icon: Icons.schedule_outlined,
                          title: 'Schedule',
                          subtitle: 'Plan activities',
                          color: const Color(0xFFFF9800),
                        ),
                      ],
                    ),
                  ],
                ),
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

                    const SizedBox(height: 32),

                    // Recent Activity
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'FunnelDisplay',
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_outlined,
                            color: Colors.white.withOpacity(0.4),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start using farmlytics to see your activity here',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Implement action
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
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
}
