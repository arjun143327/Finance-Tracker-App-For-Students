import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecuritySetupScreen extends StatelessWidget {
  const SecuritySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9E6), Color(0xFFFFF4D6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Custom Back Button
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF333333), size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                
                const SizedBox(height: 32),
                
                // Header
                Text(
                  'Security Setup',
                  style: GoogleFonts.bodoniModa(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Description (Placeholder for now, matching style)
                const Text(
                  'Secure your financial journey.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF888888),
                    height: 1.5,
                  ),
                ),

                // "Design from scratch" area - left empty/minimal for next steps
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
