import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../data/providers/user_provider.dart';
import '../widgets/glass_card.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _incomeController;
  late String _currency;
  late String _goal;

  final List<String> _currencies = ['\u20b9', '\$', '€', '£'];
  final List<String> _goals = [
    'Save more',
    'Control spending',
    'Track habits'
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).valueOrNull;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _balanceController = TextEditingController(text: profile?.balance.toStringAsFixed(0) ?? '');
    _incomeController = TextEditingController(text: profile?.income.toStringAsFixed(0) ?? '');
    _currency = profile?.currency ?? '\u20b9';
    
    // Ensure goal is one of the predefined list or default to the first one
    _goal = _goals.contains(profile?.goal) ? profile!.goal : _goals.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentProfile = ref.read(userProfileProvider).valueOrNull;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      name: _nameController.text.trim(),
      balance: double.tryParse(_balanceController.text.trim()) ?? 0.0,
      income: double.tryParse(_incomeController.text.trim()) ?? 0.0,
      currency: _currency,
      goal: _goal,
    );

    await ref.read(userProfileProvider.notifier).saveProfile(updatedProfile);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lato(color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  interactive: false,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.lato(color: Colors.white),
                        decoration: _inputDecoration('Name'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _balanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.lato(color: Colors.white),
                        decoration: _inputDecoration('Starting Balance'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Starting balance is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _incomeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.lato(color: Colors.white),
                        decoration: _inputDecoration('Monthly Income'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Monthly income is required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _currency,
                        dropdownColor: AppColors.bgGradientEnd,
                        decoration: _inputDecoration('Currency'),
                        items: _currencies.map((cur) => DropdownMenuItem(value: cur, child: Text(cur))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _currency = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _goal,
                        dropdownColor: AppColors.bgGradientEnd,
                        decoration: _inputDecoration('Financial Goal'),
                        items: _goals.map((goal) => DropdownMenuItem(value: goal, child: Text(goal))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _goal = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.bgGradientStart,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
