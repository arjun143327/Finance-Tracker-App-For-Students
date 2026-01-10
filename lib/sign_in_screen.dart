import 'package:flutter/material.dart';
import 'budget_setup_screen.dart';
import 'theme/neo_colors.dart';
import 'widgets/neo_button.dart';
import 'widgets/neo_input.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: Stack(
        children: [
          // Background Accent
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                color: NeoColors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // App Bar / Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: NeoColors.black, size: 32),
                  ),

                  const SizedBox(height: 40),

                  // Header
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.black,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Let's catch up on your spending",
                    style: TextStyle(
                      fontSize: 16,
                      color: NeoColors.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Inputs
                  const NeoInput(
                    hintText: "Your email",
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  const NeoInput(
                    hintText: "Password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: NeoColors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: NeoColors.orange,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign In Button
                  NeoButton(
                    text: "Sign In",
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const BudgetSetupScreen()),
                          (route) => false);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 2, color: NeoColors.black),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 2, color: NeoColors.black),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Social Login (Google Only)
                  _buildSocialButton(
                    text: "Continue with Google",
                    icon: Icons.g_mobiledata, 
                    color: NeoColors.white,
                    textColor: NeoColors.black,
                    onTap: () {
                       Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const BudgetSetupScreen()),
                          (route) => false);
                    },
                  ),

                  const SizedBox(height: 40),

                  // Sign Up Link
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        text: "New here? ",
                        style: TextStyle(
                          color: NeoColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: NeoColors.orange,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NeoColors.black, width: 3),
           boxShadow: [
            BoxShadow(
              color: NeoColors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
