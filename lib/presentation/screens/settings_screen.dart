import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../data/providers/notifications_provider.dart';
import '../widgets/glass_card.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSettingTile(
              context,
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              subtitle: 'Update your name, balance, income & goals',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),

            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Manage alerts and reminders',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.bgGradientEnd,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                    content: Consumer(
                      builder: (context, childRef, _) {
                        final isEnabled = childRef.watch(dailyReminderProvider);
                        return SwitchListTile(
                          title: const Text('Daily spending reminder', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Remind me at 9 PM every day', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                          value: isEnabled,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            childRef.read(dailyReminderProvider.notifier).state = val;
                          },
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Done', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.security_rounded,
              title: 'Security',
              subtitle: 'Passcode and biometric lock',
              onTap: () {
                // Future feature
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About Budgetrix',
              subtitle: 'Version 1.1',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

