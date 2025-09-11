import 'package:flutter/material.dart';
import 'package:farmlytics/services/auth_service.dart';
import 'package:farmlytics/services/language_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final authService = AuthService();
      final user = authService.currentUser;

      if (user != null) {
        setState(() {
          _userEmail = user.email ?? 'No email';
          _isLoading = false;
        });

        // Fetch user name
        final userName = await authService.getUserName();
        setState(() {
          _userName = userName ?? 'User';
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user info: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'FunnelDisplay',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              LanguageService.t('logout_confirmation'),
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  LanguageService.t('cancel'),
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  LanguageService.t('logout'),
                  style: const TextStyle(
                    color: Color(0xFFE53E3E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        await AuthService().signOut();
        if (mounted) {
          Navigator.of(context).pop(); // Close profile screen
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          LanguageService.t('profile'),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1FBA55)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1FBA55).withOpacity(0.2),
                            border: Border.all(
                              color: const Color(0xFF1FBA55),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: const Color(0xFF1FBA55),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // User Name
                        Text(
                          _userName.isNotEmpty ? _userName : 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FunnelDisplay',
                          ),
                        ),

                        const SizedBox(height: 8),

                        // User Email
                        Text(
                          _userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Profile Options
                  _buildProfileSection(LanguageService.t('account_settings'), [
                    _buildProfileOption(
                      icon: Icons.person_outline,
                      title: LanguageService.t('edit_profile'),
                      subtitle: 'Update your personal information',
                      onTap: () {
                        // TODO: Implement edit profile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit profile feature coming soon!'),
                            backgroundColor: Color(0xFF1FBA55),
                          ),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.notifications_outlined,
                      title: LanguageService.t('notifications'),
                      subtitle: 'Manage your notification preferences',
                      onTap: () {
                        // TODO: Implement notification settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings coming soon!'),
                            backgroundColor: Color(0xFF1FBA55),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 32),

                  _buildProfileSection('Farm', [
                    _buildProfileOption(
                      icon: Icons.agriculture_outlined,
                      title: 'My Farm Details',
                      subtitle: 'View and manage your farm information',
                      onTap: () {
                        // TODO: Implement farm details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Farm details feature coming soon!'),
                            backgroundColor: Color(0xFF1FBA55),
                          ),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.analytics_outlined,
                      title: 'Farm Analytics',
                      subtitle: 'View your farm performance data',
                      onTap: () {
                        // TODO: Implement analytics
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics feature coming soon!'),
                            backgroundColor: Color(0xFF1FBA55),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 32),

                  _buildProfileSection('Support', [
                    _buildProfileOption(
                      icon: Icons.help_outline,
                      title: LanguageService.t('help_support'),
                      subtitle: 'Get help with using the app',
                      onTap: () {
                        // TODO: Implement help
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help & support coming soon!'),
                            backgroundColor: Color(0xFF1FBA55),
                          ),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.info_outline,
                      title: LanguageService.t('about'),
                      subtitle: 'App version and information',
                      onTap: () {
                        // TODO: Implement about
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('About page coming soon!'),
                            backgroundColor: Color(0xFF1FBA55),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 40),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            LanguageService.t('logout'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'FunnelDisplay',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Column(children: options),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'FunnelDisplay',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
