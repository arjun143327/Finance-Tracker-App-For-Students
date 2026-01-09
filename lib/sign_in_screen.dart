import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  // ... existing animation controllers ...
  late AnimationController _entranceController;
  late AnimationController _bgController;
  late Animation<double> _fadeForm;
  late Animation<Offset> _slideForm;
  
  // Input Focus Nodes
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Button State
  bool _isSignInPressed = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600), // Slightly longer for smoothness
      vsync: this,
    );
    // ... rest of initState
    _fadeForm = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
    );

    _slideForm = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Background Animation
    _bgController = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);

    // Start Entrance
    _entranceController.forward();

    // Rebuild on focus change to update glows
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bgController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onSignInPressed() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Stack(
          children: [
            // 1. Grid Pattern
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),

            // 2. Animated Gradient Mesh
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                double topOffset = math.sin(_bgController.value * math.pi) * 30;
                double bottomOffset = math.sin(_bgController.value * math.pi) * 20;

                return Stack(
                  children: [
                    Positioned(
                      top: -100,
                      left: -50 + topOffset,
                      child: _MeshOrb(color: const Color(0xFF06B6D4), size: 200),
                    ),
                    Positioned(
                      top: 100,
                      right: -50 - topOffset,
                      child: _MeshOrb(color: const Color(0xFF8B5CF6), size: 250),
                    ),
                    Positioned(
                      bottom: -50 + bottomOffset,
                      left: 50 + bottomOffset,
                      child: _MeshOrb(color: const Color(0xFF06B6D4), size: 300),
                    ),
                  ],
                );
              },
            ),

            // 3. Radial Glow
             Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.03), Colors.transparent],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                ),
              ),
            ),

            // 4. Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Top Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Sign in to continue your financial journey",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Form Section (Animated)
                  FadeTransition(
                    opacity: _fadeForm,
                    child: SlideTransition(
                      position: _slideForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            // Email Input
                            _buildGlassInput(
                              focusNode: _emailFocus,
                              placeholder: "Email address",
                              icon: Icons.email_outlined,
                            ),

                            const SizedBox(height: 16),

                            // Password Input
                            _buildGlassInput(
                              focusNode: _passwordFocus,
                              placeholder: "Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            const SizedBox(height: 12),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: const Color(0xFF06B6D4),
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFF06B6D4).withOpacity(0.5),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Sign In Button
                            GestureDetector(
                              onTapDown: (_) => setState(() => _isSignInPressed = true),
                              onTapUp: (_) {
                                setState(() => _isSignInPressed = false);
                                _onSignInPressed();
                              },
                              onTapCancel: () => setState(() => _isSignInPressed = false),
                              child: AnimatedScale(
                                scale: _isSignInPressed ? 0.95 : 1.0,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeOut,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                                        offset: const Offset(0, 20),
                                        blurRadius: 40,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text("OR", style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12)),
                                ),
                                Expanded(child: Container(height: 1, color: Colors.white.withOpacity(0.1))),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Social Login - Google
                            _buildSocialButton(
                              label: "Continue with Google",
                              icon: Icons.g_mobiledata, // Using material icon as proxy for Google logo for now
                            ),

                            const SizedBox(height: 12),

                            // Social Login - Apple
                            _buildSocialButton(
                              label: "Continue with Apple",
                              icon: Icons.apple,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Bottom Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {}, // Navigate to Sign Up
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF06B6D4),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required FocusNode focusNode,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
  }) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? const Color(0xFF06B6D4) : Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: TextField(
              focusNode: focusNode,
              obscureText: isPassword && !_isPasswordVisible,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: Icon(icon, color: const Color(0xFF06B6D4), size: 20),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF94A3B8),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeshOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _MeshOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    const double spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
