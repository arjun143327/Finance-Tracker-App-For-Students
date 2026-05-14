import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../widgets/glass_card.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              icon: Icons.category_rounded,
              title: 'Manage Categories',
              subtitle: 'Add or remove expense categories',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
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
                // Future feature
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
                // Future feature
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
                  color: AppColors.primary.withOpacity(0.1),
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
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
