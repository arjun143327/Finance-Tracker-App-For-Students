import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../data/providers/user_provider.dart';
import 'app_shell.dart';
import 'onboarding/welcome_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Guards so navigation only fires once
  bool _navigated = false;
  Timer? _minSplashTimer;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    // Minimum splash display time (2 s)
    _minSplashTimer = Timer(const Duration(milliseconds: 2000), () {
      _minTimeElapsed = true;
      _tryNavigate();
    });
  }

  // Called both when the min-timer fires AND when the profile provider settles
  void _tryNavigate() {
    if (_navigated || !mounted) return;
    if (!_minTimeElapsed) return; // still in min-splash window

    final profileState = ref.read(userProfileProvider);

    // Only navigate once the AsyncValue is no longer loading
    if (profileState.isLoading) return;

    _navigated = true;

    final isComplete = profileState.valueOrNull?.onboardingComplete ?? false;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: isComplete ? const AppShell() : const WelcomeScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _minSplashTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to profile state changes — triggers _tryNavigate when DB load finishes
    ref.listen(userProfileProvider, (_, next) {
      if (!next.isLoading) {
        _tryNavigate();
      }
    });

    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 26),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Budgetrix',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 70,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'YOUR FINANCIAL JOURNAL',
                    style: GoogleFonts.lato(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0.12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 46),
                  SizedBox(
                    width: 190,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1800),
                      builder: (context, value, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 4,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        );
                      },
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
