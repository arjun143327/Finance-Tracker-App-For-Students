import 'package:flutter_riverpod/flutter_riverpod.dart';

// Since native plugins cannot be installed without Windows Developer Mode on this machine,
// we are using a dummy state provider to represent the user's notification preference.
final dailyReminderProvider = StateProvider<bool>((ref) => false);
