import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  // ... existing animation controllers ...
  late AnimationController _entranceController;
  late Animation<double> _fadeTitle;
  late Animation<double> _fadeButton;
  late Animation<Offset> _slideButton;

  // Floating Animations (Independent)
  late AnimationController _float1Controller; // 3s
  late AnimationController _float2Controller; // 3.5s
  late AnimationController _float3Controller; // 2.8s

  // Pulse Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Background Animation
  late AnimationController _bgController;

  // Button State
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller (On Load)
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Total animation time window
      vsync: this,
    );
    // ... rest of initState ...
    _fadeTitle = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    );

    _fadeButton = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _slideButton = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Floating Controllers
    _float1Controller = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _float2Controller = AnimationController(duration: const Duration(milliseconds: 3500), vsync: this)..repeat(reverse: true);
    _float3Controller = AnimationController(duration: const Duration(milliseconds: 2800), vsync: this)..repeat(reverse: true);

    // 3. Pulse Controller
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(_pulseController);

    // 4. Background Controller
    _bgController = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);

    // Start Entrance
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _float1Controller.dispose();
    _float2Controller.dispose();
    _float3Controller.dispose();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onGetStartedPressed() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
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
              child: CustomPaint(painter: GridPainter()),
            ),

            // 2. Animated Gradient Mesh (Drifting)
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                // Top circle: Move horizontally 30px left to right
                double topOffset = math.sin(_bgController.value * math.pi) * 30;
                // Bottom circle: Move diagonally 20px
                double bottomOffset = math.sin(_bgController.value * math.pi) * 20;

                return Stack(
                  children: [
                    Positioned(
                      top: -100,
                      left: -50 + topOffset,
                      child: _buildMeshOrb(const Color(0xFF06B6D4), 200),
                    ),
                    Positioned(
                      top: 100,
                      right: -50 - topOffset, // Move opposite
                      child: _buildMeshOrb(const Color(0xFF8B5CF6), 250),
                    ),
                    Positioned(
                      bottom: -50 + bottomOffset,
                      left: 50 + bottomOffset,
                      child: _buildMeshOrb(const Color(0xFF06B6D4), 300),
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

            // 4. Floating Cards with Entrance and Independent Float
            // Card 1 (+12.5%) - Top Left
            _buildAnimatedCardWrapper(
              controller: _floatingControllerFor(1),
              entranceController: _entranceController,
              startTime: 0.0, // Immediate
              floatDistance: 15.0,
              baseTop: 180,
              baseLeft: 40,
              angle: -5 * math.pi / 180,
              child: _buildMiniChartCard(
                  icon: Icons.trending_up, color: const Color(0xFF06B6D4), label: "+12.5%", chartType: 1),
            ),

            // Card 2 (Savings) - Top Right
            _buildAnimatedCardWrapper(
              controller: _floatingControllerFor(2),
              entranceController: _entranceController,
              startTime: 0.150, // 150ms delay (approx 0.125 of 1200ms)
              floatDistance: 12.0,
              baseTop: 140,
              baseRight: 40,
              angle: 8 * math.pi / 180,
              child: _buildMiniChartCard(
                  icon: Icons.pie_chart_outline, color: const Color(0xFF8B5CF6), label: "Savings", chartType: 2),
            ),

            // Card 3 ($2,450) - Bottom Center
            _buildAnimatedCardWrapper(
              controller: _floatingControllerFor(3),
              entranceController: _entranceController,
              startTime: 0.300, // 300ms delay
              floatDistance: 18.0,
              baseTop: 300,
              alignment: Alignment.topCenter,
              angle: -3 * math.pi / 180,
              child: _buildMiniChartCard(
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF10B981),
                  label: "\$2,450",
                  chartType: 3),
            ),

            // 5. Foreground Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Top Badge (Static fade or simple entrance)
                  FadeTransition(
                    opacity: _fadeTitle, // Reuse title fade for simplicity or create new
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.lock_outline, color: Colors.white70, size: 12),
                          SizedBox(width: 6),
                          Text(
                            "Secure & Encrypted",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3), // Visual spacing around cards

                  const SizedBox(height: 300), // Reserve space for cards

                  const Spacer(flex: 2),

                  // Typography
                  FadeTransition(
                    opacity: _fadeTitle,
                    child: Column(
                      children: const [
                        Text(
                          "Saveton",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Smart spending, smarter saving",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Button with Animations
                  SlideTransition(
                    position: _slideButton,
                    child: FadeTransition(
                      opacity: _fadeButton,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _isButtonPressed = true),
                          onTapUp: (_) {
                            setState(() => _isButtonPressed = false);
                            _onGetStartedPressed();
                          },
                          onTapCancel: () => setState(() => _isButtonPressed = false),
                          child: AnimatedScale(
                            scale: _isButtonPressed ? 0.95 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 327,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      // Pulsing Glow
                                      BoxShadow(
                                        color: const Color(0xFF8B5CF6).withOpacity(_pulseAnimation.value),
                                        offset: const Offset(0, 20),
                                        blurRadius: 40,
                                      ),
                                      // Static inner glow
                                      BoxShadow(
                                        color: const Color(0xFF06B6D4).withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Get Started",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Version
                  FadeTransition(
                    opacity: _fadeButton,
                    child: const Text(
                      "v1.0",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimationController _floatingControllerFor(int cardIndex) {
    switch (cardIndex) {
      case 1: return _float1Controller;
      case 2: return _float2Controller;
      case 3: return _float3Controller;
      default: return _float1Controller;
    }
  }

  Widget _buildAnimatedCardWrapper({
    required AnimationController controller,
    required AnimationController entranceController,
    required double startTime, // in seconds relative to entrance start, but we use Interval
    required double floatDistance,
    double? baseTop,
    double? baseLeft,
    double? baseRight,
    Alignment? alignment,
    required double angle,
    required Widget child,
  }) {
    // Entrance: Slide + Fade
    // Approx duration 600ms. startTime logic:
    // Let's say master is 1200ms. 
    // Card 1: 0ms -> 600ms = 0.0 -> 0.5
    // Card 2: 150ms -> 750ms = 0.125 -> 0.625
    // Card 3: 300ms -> 900ms = 0.25 -> 0.75
    
    double start = startTime; // assume startTime passed is safe normalized value 0..1 or adjust
    // Re-mapping logic:
    // startTime passed is delay in seconds? No, let's map it.
    // Master duration: 1200ms.
    // Card 1 (0ms): range 0.0 to 0.5
    // Card 2 (150ms): range 0.125 to 0.625
    // Card 3 (300ms): range 0.25 to 0.75

    // Normalize:
    double totalDuration = 1.2; // seconds
    double animDuration = 0.6; // seconds
    
    double begin = startTime;
    double end = begin + (animDuration / totalDuration);

    final fade = CurvedAnimation(
      parent: entranceController,
      curve: Interval(begin, end.clamp(0.0, 1.0), curve: Curves.easeIn),
    );

    final slide = Tween<Offset>(begin: const Offset(0, 50), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: Interval(begin, end.clamp(0.0, 1.0), curve: Curves.elasticOut),
      ),
    );

    return Positioned(
      top: baseTop,
      left: baseLeft,
      right: baseRight,
      child: alignment != null 
      ? Align(
          alignment: alignment,
          child: _buildCardContent(controller, fade, slide, floatDistance, angle, child),
        )
      : _buildCardContent(controller, fade, slide, floatDistance, angle, child),
    );
  }

  Widget _buildCardContent(
    AnimationController floatController,
    Animation<double> fade,
    Animation<Offset> slide,
    double floatDist,
    double angle,
    Widget child
  ) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (context, _) {
        // Sine wave motion
        double floatVal = math.sin(floatController.value * 2 * math.pi) * floatDist;
        
        return FadeTransition(
          opacity: fade,
          child: AnimatedBuilder(
            animation: slide, // Reusing AnimatedBuilder logic manually or nesting
            builder: (ctx, ch) => Transform.translate(
              offset: Offset(slide.value.dx, slide.value.dy + floatVal), // Entrance Slide + Float
              child: Transform.rotate(
                angle: angle,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniChartCard({
    required IconData icon,
    required Color color,
    required String label,
    required int chartType,
  }) {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 32,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Mini chart mimic
                SizedBox(
                  height: 20,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: MiniChartPainter(color: color, type: chartType),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeshOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05), // 5% opacity
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

// Custom Painter for the background grid
class GridPainter extends CustomPainter {
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

// Custom Painter for mini charts
class MiniChartPainter extends CustomPainter {
  final Color color;
  final int type;

  MiniChartPainter({required this.color, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (type == 1) { // Upward trend
      path.moveTo(0, size.height);
      path.quadraticBezierTo(size.width * 0.3, size.height * 0.8, size.width * 0.5, size.height * 0.4);
      path.quadraticBezierTo(size.width * 0.7, size.height * 0.6, size.width, 0);
    } else if (type == 2) { // Pieish curve
       path.addArc(Rect.fromLTWH(0, 0, size.height * 1.5, size.height * 1.5), math.pi, math.pi / 2);
    } else { // Wavy
      path.moveTo(0, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.5);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
