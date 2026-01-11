import 'package:flutter/material.dart';
import 'theme/neo_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildProfileHeader(),
                    const SizedBox(height: 32),
                    _buildPersonalDetailsCard(),
                    const SizedBox(height: 16),
                    _buildFinancialSummaryCard(),
                    const SizedBox(height: 16),
                    _buildAchievementsSection(),
                    const SizedBox(height: 32),
                    _buildEditProfileButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: NeoColors.cream,
        border: Border(bottom: BorderSide(color: NeoColors.black, width: 2)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, size: 28, color: NeoColors.black),
            ),
          ),
          const Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NeoColors.black,
              ),
            ),
          ),
          const SizedBox(width: 44), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: NeoColors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: NeoColors.black, width: 4),
          ),
          child: const Center(
            child: Text(
              "R",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 48,
                color: NeoColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Edit Photo",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: NeoColors.orange,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Rahul Kumar",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: NeoColors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "rahul@student.com",
          style: TextStyle(
            fontSize: 14,
            color: NeoColors.gray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeoColors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow("📱", "Phone", "+91 9876543210"),
          const SizedBox(height: 12),
          _buildDetailRow("🎓", "College", "Delhi University"),
          const SizedBox(height: 12),
          _buildDetailRow("📅", "Age", "21"),
          const SizedBox(height: 12),
          _buildDetailRow("🎂", "Date of Birth", "Jan 15, 2003"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: NeoColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.black,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: NeoColors.gray,
        ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeoColors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Financial Journey",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard("Total Saved", "₹12,500", NeoColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("Expenses", "147", NeoColors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard("Active Goals", "3", NeoColors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("Member Since", "Jan 2026", NeoColors.darkGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: NeoColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Achievements 🏆",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeoColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildAchievementBadge("🔥", "5-Day\nStreak", NeoColors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildAchievementBadge("💰", "First ₹10K\nSaved", NeoColors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildAchievementBadge("📊", "Budget\nMaster", NeoColors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeoColors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: NeoColors.black.withOpacity(0.1),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          // Navigate to edit mode
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: NeoColors.orange,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: NeoColors.black,
                offset: Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: NeoColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
