import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../services/voice_parser_service.dart';
import '../widgets/glass_card.dart';
import 'add_expense_screen.dart';

// ── Voice Fill Screen ────────────────────────────────────────────────────────
class VoiceFillScreen extends ConsumerStatefulWidget {
  const VoiceFillScreen({super.key});

  @override
  ConsumerState<VoiceFillScreen> createState() => _VoiceFillScreenState();
}

class _VoiceFillScreenState extends ConsumerState<VoiceFillScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();

  bool _isInitializing = true;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _transcript = '';
  VoiceParsedResult? _parsed;

  // Pulse animation for the mic orb
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) {
      setState(() => _isInitializing = false);
      // Auto-start listening once initialized
      if (_speechAvailable) _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable || _isListening) return;
    setState(() {
      _transcript = '';
      _parsed = null;
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _transcript = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              _parsed = VoiceParserService.parse(_transcript);
            }
          });
        }
      },
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  void _stopListening() {
    _speech.stop();
    if (_transcript.isNotEmpty) {
      setState(() {
        _isListening = false;
        _parsed = VoiceParserService.parse(_transcript);
      });
    } else {
      setState(() => _isListening = false);
    }
  }

  void _openPrefilled() {
    if (_parsed == null) return;
    final p = _parsed!;

    // Build a synthetic TransactionModel for pre-fill
    final prefilled = TransactionModel(
      title: p.note ?? '',
      category: p.category ?? 'Other',
      amount: p.amount ?? 0,
      date: DateTime.now(),
      method: 'Cash',
      type: TransactionType.expense,
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: AddExpenseScreen(initialTransaction: prefilled),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Voice Entry'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: _isInitializing
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : !_speechAvailable
                  ? _buildUnavailableState()
                  : _parsed != null
                      ? _buildResultView()
                      : _buildListeningView(),
        ),
      ),
    );
  }

  // ── Listening View ──────────────────────────────────────────────────────
  Widget _buildListeningView() {
    return Column(
      children: [
        const Spacer(),
        // Animated mic orb
        GestureDetector(
          onTap: _isListening ? _stopListening : _startListening,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                        alpha: _isListening ? 0.55 : 0.25),
                    blurRadius: _isListening ? 36 : 18,
                    spreadRadius: _isListening ? 4 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: AppColors.bgGradientStart,
                size: 48,
              ),
            ),
            builder: (_, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring 1
                  if (_isListening)
                    Transform.scale(
                      scale: _pulseAnim.value * 1.4,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  // Outer glow ring 2
                  if (_isListening)
                    Transform.scale(
                      scale: _pulseAnim.value * 1.2,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  // Mic button core (cached via child)
                  child!,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 36),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _isListening ? 'Listening...' : 'Tap to speak',
            key: ValueKey(_isListening),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _isListening
                ? '"Spent 450 on pizza" or "Petrol 1200"'
                : 'Speak your expense naturally',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        // Live transcript bubble
        if (_transcript.isNotEmpty) ...[
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GlassCard(
              interactive: false,
              child: Text(
                '"$_transcript"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryLight,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),
        ],
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Tap the mic to stop early',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  // ── Result / Confirmation View ──────────────────────────────────────────
  Widget _buildResultView() {
    final p = _parsed!;
    const String currency = '₹'; // We'll use the symbol directly here

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // Heard text
          Center(
            child: Text(
              '"$_transcript"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          const SizedBox(height: 32),

          // Parsed result card
          GlassCard(
            interactive: false,
            child: Column(
              children: [
                // Amount hero
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Text(
                      p.hasAmount
                          ? '$currency${p.amount!.toStringAsFixed(p.amount! % 1 == 0 ? 0 : 2)}'
                          : 'Amount not detected',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 52,
                            color: p.hasAmount
                                ? AppColors.primary
                                : AppColors.expense,
                            shadows: [
                              Shadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 18,
                                offset: const Offset(-3, -4),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 20),

                // Category row
                _detailRow(
                  context,
                  icon: Icons.category_rounded,
                  label: 'Category',
                  value: p.category ?? 'Other',
                  isDetected: p.hasCategory,
                ),
                const SizedBox(height: 14),

                // Note row
                _detailRow(
                  context,
                  icon: Icons.sticky_note_2_outlined,
                  label: 'Note',
                  value: p.hasNote ? p.note! : 'Not detected',
                  isDetected: p.hasNote,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Gentle prompt if note missing
          if (!p.hasNote)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    'Add a quick note after tapping Edit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              // Try again
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _transcript = '';
                      _parsed = null;
                    });
                    _startListening();
                  },
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.primary),
                  label: const Text('Retry',
                      style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Edit & Save
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _openPrefilled,
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.bgGradientStart),
                  label: const Text('Edit & Save',
                      style: TextStyle(
                          color: AppColors.bgGradientStart,
                          fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDetected,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDetected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Mic Unavailable State ───────────────────────────────────────────────
  Widget _buildUnavailableState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          interactive: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic_off_rounded,
                  color: AppColors.expense, size: 56),
              const SizedBox(height: 20),
              Text(
                'Microphone Unavailable',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Please grant microphone permission and try again. On Windows, make sure your microphone is connected.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Go Back',
                    style: TextStyle(color: AppColors.bgGradientStart)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
