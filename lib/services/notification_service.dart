import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'sms_parser_service.dart';

/// NotificationService
///
/// Singleton wrapper around flutter_local_notifications.
/// Handles:
/// - Initialization and notification channel creation (Android 8+)
/// - Requesting notification permissions (Android 13+)
/// - Posting transaction reminder alerts with JSON payload
/// - Exposing a stream for notification tap events (for deep-linking)
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Stream callback — set by AppShell to navigate on notification tap
  void Function(SmsParsedTransaction)? onNotificationTapped;

  // ── Channel configuration ─────────────────────────────────────────────
  static const _channelId = 'budgetrix_sms_alerts';
  static const _channelName = 'Transaction Alerts';
  static const _channelDesc =
      'Alerts you when a payment is detected so you can log it.';

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDesc,
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFFC69C6D), // AppColors.primary
    enableVibration: true,
    playSound: true,
  );

  static const NotificationDetails _notificationDetails =
      NotificationDetails(android: _androidDetails);

  // ── Initialize ────────────────────────────────────────────────────────
  Future<void> initialize() async {
    // Only functional on Android. Silently skip on other platforms.
    if (defaultTargetPlatform != TargetPlatform.android) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create the Android notification channel
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // Request notification permission (Android 13+ / API 33+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Post a transaction alert ──────────────────────────────────────────
  Future<void> showTransactionAlert(SmsParsedTransaction tx) async {
    // Only post for debit (expense) transactions
    if (!tx.isDebit) return;

    final amountStr =
        '₹${tx.amount % 1 == 0 ? tx.amount.toInt() : tx.amount.toStringAsFixed(2)}';
    final merchantPart =
        tx.merchant != null ? ' at ${tx.merchant}' : '';

    const String title = '💸 Log your expense!';
    final body =
        'You spent $amountStr$merchantPart. Tap to add it to Budgetrix.';

    // Encode the parsed transaction as JSON payload for deep-linking
    final payload = jsonEncode({
      'amount': tx.amount,
      'merchant': tx.merchant,
      'paymentMethod': tx.paymentMethod,
    });

    await _plugin.show(
      tx.hashCode.abs() % 10000, // unique-ish notification ID
      title,
      body,
      _notificationDetails,
      payload: payload,
    );
  }

  // ── Handle notification tap ───────────────────────────────────────────
  void _onNotificationTapped(NotificationResponse response) {
    final payloadStr = response.payload;
    if (payloadStr == null || payloadStr.isEmpty) return;

    try {
      final map = jsonDecode(payloadStr) as Map<String, dynamic>;
      final tx = SmsParsedTransaction(
        amount: (map['amount'] as num).toDouble(),
        merchant: map['merchant'] as String?,
        paymentMethod: map['paymentMethod'] as String?,
        isDebit: true,
        rawSms: '',
      );
      onNotificationTapped?.call(tx);
    } catch (_) {
      // Malformed payload — silently ignore
    }
  }
}
