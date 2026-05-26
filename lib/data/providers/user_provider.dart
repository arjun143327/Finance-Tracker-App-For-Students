import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import 'transaction_provider.dart';
import '../../services/database/database_service.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfileModel?>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return UserProfileNotifier(dbService);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfileModel?>> {
  final DatabaseService _dbService;

  UserProfileNotifier(this._dbService) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _dbService.getUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      await _dbService.saveUserProfile(profile);
      await loadProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

