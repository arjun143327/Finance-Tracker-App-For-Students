/// SmsParserService
///
/// Privacy-first, pure Dart SMS transaction parser.
/// - ZERO network calls. All processing is done on-device.
/// - Instantly discards OTPs, marketing, and personal messages.
/// - Parses debited/credited amounts and merchant names from bank alerts.
library;

/// Structured result from parsing an SMS.
class SmsParsedTransaction {
  final double amount;
  final String? merchant;
  final String? paymentMethod;
  final bool isDebit;
  final String rawSms;

  const SmsParsedTransaction({
    required this.amount,
    required this.rawSms,
    required this.isDebit,
    this.merchant,
    this.paymentMethod,
  });
}

class SmsParserService {
  SmsParserService._();

  // ── Gatekeeper: Discard non-transaction messages immediately ────────────

  /// Keywords that indicate a transaction SMS (debit/credit events).
  static const _transactionKeywords = [
    'debited', 'debit', 'credited', 'credit', 'paid', 'spent',
    'transferred', 'sent', 'payment', 'transaction', 'purchase',
    'withdrawn', 'withdrawn', 'upi', 'neft', 'imps', 'rtgs',
  ];

  /// If any of these are present, discard immediately (not a transaction).
  static const _discardKeywords = [
    'otp', 'one time', 'password', 'verification code', 'login',
    'sign in', 'alert: your otp', 'do not share', 'not share',
    'offer', 'cashback offer', 'click here', 'subscribe', 'unsubscribe',
    'congratulations', 'winner', 'lucky draw',
  ];

  // ── Amount Patterns ─────────────────────────────────────────────────────
  // Matches: Rs. 1,200  /  INR 450  /  ₹450.50  /  Rs1200
  // Group 1 captures the numeric amount.
  static final _amountRegex = RegExp(
    r'(?:rs\.?\s*|inr\s*|₹\s*)(\d{1,3}(?:,\d{3})+(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ── Merchant / Payee Patterns ───────────────────────────────────────────
  // "to MERCHANT NAME" / "at MERCHANT NAME" / "VPA abc@upi"
  static final _merchantRegexList = [
    RegExp(r'(?:to|towards|at)\s+([A-Za-z0-9&\s\-\.]{2,30})(?:\s+on|\s+via|\s+ref|\.|\,|$)',
        caseSensitive: false),
    RegExp(r'(?:at|merchant)\s+([A-Za-z0-9&\s\-\.]{2,30})(?:\s|\.|\,|$)',
        caseSensitive: false),
    RegExp(r'vpa\s+([\w\.\-]+@[\w]+)',
        caseSensitive: false),
  ];

  // ── Payment Method Keywords ─────────────────────────────────────────────
  static const Map<String, String> _methodKeywords = {
    'gpay': 'GPay',
    'google pay': 'GPay',
    'phonepe': 'PhonePe',
    'phone pe': 'PhonePe',
    'paytm': 'Paytm',
    'upi': 'UPI',
    'neft': 'Net Banking',
    'imps': 'Net Banking',
    'rtgs': 'Net Banking',
    'credit card': 'Card',
    'debit card': 'Card',
    'atm': 'Card',
  };

  /// Main entry point.
  ///
  /// Returns `null` if the SMS is NOT a financial transaction (OTP, spam, etc.).
  /// Returns a [SmsParsedTransaction] if a debit/credit transaction is detected.
  static SmsParsedTransaction? parse(String smsBody) {
    final lower = smsBody.toLowerCase();

    // 1. Discard guard — any discard keyword → ignore immediately
    for (final kw in _discardKeywords) {
      if (lower.contains(kw)) return null;
    }

    // 2. Transaction guard — must have at least one transaction keyword
    bool isTransaction = false;
    for (final kw in _transactionKeywords) {
      if (lower.contains(kw)) {
        isTransaction = true;
        break;
      }
    }
    if (!isTransaction) return null;

    // 3. Extract amount
    final amountMatch = _amountRegex.firstMatch(lower);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '';
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return null;

    // 4. Determine debit vs credit
    final isDebit = lower.contains('debit') ||
        lower.contains('debited') ||
        lower.contains('paid') ||
        lower.contains('sent') ||
        lower.contains('withdrawn') ||
        lower.contains('purchase');

    // 5. Extract merchant name (best-effort, nullable)
    String? merchant;
    for (final regex in _merchantRegexList) {
      final match = regex.firstMatch(smsBody);
      if (match != null) {
        final raw = match.group(1)?.trim();
        if (raw != null && raw.length > 1) {
          // Title-case the merchant name
          merchant = raw.split(' ').map((w) {
            if (w.isEmpty) return w;
            return w[0].toUpperCase() + w.substring(1).toLowerCase();
          }).join(' ');
          break;
        }
      }
    }

    // 6. Detect payment method
    String? paymentMethod;
    _methodKeywords.forEach((kw, label) {
      if (lower.contains(kw)) paymentMethod = label;
    });

    return SmsParsedTransaction(
      amount: amount,
      merchant: merchant,
      paymentMethod: paymentMethod,
      isDebit: isDebit,
      rawSms: smsBody,
    );
  }
}
