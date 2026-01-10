import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'theme/neo_colors.dart';
import 'widgets/neo_button.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: Stack(
        children: [
          // Background Geometric Shapes
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: NeoColors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 3),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -30,
            child: Transform.rotate(
              angle: 15 * 3.14159 / 180,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: NeoColors.blue,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: NeoColors.black, width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: NeoColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 3),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                const Text(
                  'Saveton',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.black,
                    letterSpacing: -1,
                  ),
                ),
                
                const Spacer(flex: 1),

                // Illustration
                Center(
                  child: Image.asset(
                    'assets/images/welcome_piggy_bank.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                // Tagline
                const Text(
                  'Track expenses\nwithout the stress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: NeoColors.black,
                    height: 1.2,
                  ),
                ),

                const Spacer(flex: 2),

                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: NeoButton(
                    text: "Let's Start!",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInScreen()),
                      );
                    },
                    color: NeoColors.orange,
                  ),
                ),
                
                const SizedBox(height: 40),

                // Footer
                Column(
                  children: [
                    const Text(
                      'For students, by students',
                      style: TextStyle(
                        color: NeoColors.gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge(Icons.lock_outline, 'Secure'),
                        const SizedBox(width: 12),
                        _buildBadge(Icons.star_outline, 'Free'),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NeoColors.black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: NeoColors.black),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NeoColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

