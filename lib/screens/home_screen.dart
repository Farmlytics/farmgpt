import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmlytics/screens/tabs/home_tab.dart';
import 'package:farmlytics/screens/tabs/schedule_tab.dart';
import 'package:farmlytics/screens/tabs/ai_chat_tab.dart';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<TabItem> get _tabs => [
    TabItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: LanguageService.t('home'),
    ),
    TabItem(
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule,
      label: LanguageService.t('calendar'),
    ),
    TabItem(
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat,
      label: LanguageService.t('chat'),
    ),
  ];

  final List<Widget> _pages = [
    const HomeTab(),
    const ScheduleTab(),
    const AiChatTab(),
  ];

  @override
  void initState() {
    super.initState();

    // Set status bar for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();

    // Start auth listener
    AuthService().startAuthListener();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
            colors: [
              Color(0xFF0A0A0A), // Very dark center
              Color(0xFF000000), // Pure black edges
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Main content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: _pages,
                  ),
                ),

                // Minimal Bottom Navigation
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_tabs.length, (index) {
                          final tab = _tabs[index];
                          final isActive = _currentIndex == index;

                          return GestureDetector(
                            onTap: () => _onTabTapped(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              width: 100,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF1FBA55).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isActive ? tab.activeIcon : tab.icon,
                                    color: isActive
                                        ? const Color(0xFF1FBA55)
                                        : Colors.white.withOpacity(0.6),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tab.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isActive
                                          ? const Color(0xFF1FBA55)
                                          : Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  TabItem({required this.icon, required this.activeIcon, required this.label});
}
