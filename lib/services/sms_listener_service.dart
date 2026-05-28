import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'sms_parser_service.dart';
import 'notification_service.dart';

/// SmsListenerService
///
/// Binds to Android's SMS broadcast system via the `telephony` package.
/// - Foreground: listens while the app is open.
/// - Background: the top-level `onBackgroundSms` handler picks up messages
///   when the app is in the background or closed.
///
/// Privacy guarantee: No SMS text, amount, or merchant data ever leaves the
/// device. All processing is local and no network calls are made.
class SmsListenerService {
  SmsListenerService._();
  static final SmsListenerService instance = SmsListenerService._();

  final Telephony _telephony = Telephony.instance;
  bool _initialized = false;

  /// Call once from [main()] after services are ready.
  Future<void> initialize() async {
    // This feature is Android-only. Silently no-op on other platforms.
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) return;
    if (_initialized) return;

    // Request SMS permissions
    final granted = await _telephony.requestPhoneAndSmsPermissions ?? false;
    if (!granted) return;

    // Listen to foreground SMS messages
    _telephony.listenIncomingSms(
      onNewMessage: _processSms,
      onBackgroundMessage: onBackgroundSms,
      listenInBackground: true,
    );

    _initialized = true;
  }

  /// Processes a single SMS message through the parser pipeline.
  void _processSms(SmsMessage message) {
    final body = message.body;
    if (body == null || body.trim().isEmpty) return;

    final parsed = SmsParserService.parse(body);
    if (parsed == null) return; // Not a financial transaction — discard

    // Fire a local notification for the user to log the expense
    NotificationService.instance.showTransactionAlert(parsed);
  }
}

/// ── Background SMS handler ─────────────────────────────────────────────────
///
/// IMPORTANT: This MUST be a top-level function (not inside any class).
/// The `telephony` package requires this to run in a separate Dart isolate
/// when the app is closed or backgrounded.
@pragma('vm:entry-point')
void onBackgroundSms(SmsMessage message) {
  final body = message.body;
  if (body == null || body.trim().isEmpty) return;

  final parsed = SmsParserService.parse(body);
  if (parsed == null) return;

  // In background context, we post the notification directly
  NotificationService.instance.showTransactionAlert(parsed);
}
