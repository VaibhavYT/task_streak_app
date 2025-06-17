import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:task_streak_app/theme/app_theme.dart';
import 'package:task_streak_app/providers/auth_provider.dart';
import 'package:task_streak_app/providers/task_provider.dart';
import 'package:task_streak_app/screens/auth/sign_in_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false; // TODO: Connect to theme provider

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mediumDarkGreenStreak,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Delete Account'),
          content: const Text(
            'This action cannot be undone. All your tasks and data will be permanently deleted.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion not implemented yet'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Clear task data
      taskProvider.clearData();

      // Sign out
      await authProvider.signOut();

      if (mounted) {
        // Navigate to sign-in screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: LiquidGlass(
        blur: 6.0,
        glassContainsChild: true,
        settings: LiquidGlassSettings(
          thickness: 40,
          lightIntensity: 0.1,
          ambientStrength: 0,
          glassColor: Colors.white.withOpacity(0.1),
        ),
        shape: LiquidRoundedSuperellipse(
            borderRadius:
                Radius.circular(12.0)), // Changed from LiquidGlassSquircle
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListTile(
            leading: Icon(
              icon,
              color: iconColor ?? AppTheme.mediumDarkGreenStreak,
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                  )
                : null,
            trailing: trailing,
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightGreenStreak.withOpacity(0.2),
              AppTheme.backgroundColorLight,
              AppTheme.mediumDarkGreenStreak.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with glassmorphism
              LiquidGlass(
                blur: 8.0,
                glassContainsChild: true,
                settings: LiquidGlassSettings(
                  thickness: 40,
                  lightIntensity: 0.1,
                  ambientStrength: 0,
                  glassColor: Colors.white.withOpacity(0.1),
                ),
                shape: LiquidRoundedSuperellipse(
                  borderRadius: Radius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.veryDarkGreenStreak,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Settings',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.veryDarkGreenStreak,
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Settings content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info section
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: LiquidGlass(
                              blur: 8.0,
                              glassContainsChild: true,
                              settings: LiquidGlassSettings(
                                thickness: 40,
                                lightIntensity: 0.1,
                                ambientStrength: 0,
                                glassColor: Colors.white.withOpacity(0.15),
                              ),
                              shape: LiquidRoundedSuperellipse(
                                  // Changed from LiquidGlassSquircle
                                  borderRadius: Radius.circular(
                                      16.0)), // Changed from BorderRadius
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          AppTheme.lightGreenStreak,
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: AppTheme.veryDarkGreenStreak,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            authProvider.user?.email ?? 'User',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Task Streak Member',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme
                                                      .secondaryTextColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // App Settings section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'App Settings',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.veryDarkGreenStreak,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildSettingsItem(
                        icon: Icons.palette_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Toggle between light and dark theme',
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              _isDarkMode = value;
                            });
                            // TODO: Implement theme switching
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Theme switching not implemented yet'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          activeColor: AppTheme.mediumDarkGreenStreak,
                        ),
                      ),

                      _buildSettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage your notification preferences',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to notifications settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Notification settings not implemented yet'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Account section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Account',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.veryDarkGreenStreak,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildSettingsItem(
                        icon: Icons.logout,
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        iconColor: AppTheme.mediumDarkGreenStreak,
                        onTap: _showLogoutDialog,
                      ),

                      _buildSettingsItem(
                        icon: Icons.delete_outline,
                        title: 'Delete Account',
                        subtitle: 'Permanently delete your account and data',
                        iconColor: Colors.red,
                        onTap: _showDeleteAccountDialog,
                      ),

                      const SizedBox(height: 24),

                      // About section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'About',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.veryDarkGreenStreak,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildSettingsItem(
                        icon: Icons.info_outline,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        onTap: () {},
                      ),

                      _buildSettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help or contact support',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to help screen
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
