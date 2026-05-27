/// VoiceParserService
///
/// Pure Dart — zero API calls, zero external dependencies.
/// Uses RegEx for amount extraction and keyword maps for category matching.
library;

class VoiceParsedResult {
  final double? amount;
  final String? category;
  final String? note;
  final String rawText;

  const VoiceParsedResult({
    required this.rawText,
    this.amount,
    this.category,
    this.note,
  });

  bool get hasAmount => amount != null && amount! > 0;
  bool get hasCategory => category != null && category!.isNotEmpty;
  bool get hasNote => note != null && note!.isNotEmpty;
}

class VoiceParserService {
  VoiceParserService._();

  // ── Category keyword map ────────────────────────────────────────────────
  // Maps category name → list of trigger words (all lowercase)
  static const Map<String, List<String>> _categoryKeywords = {
    'Food': [
      'food', 'eat', 'lunch', 'dinner', 'breakfast', 'pizza', 'burger',
      'restaurant', 'café', 'cafe', 'coffee', 'tea', 'snack', 'biryani',
      'swiggy', 'zomato', 'grocery', 'groceries', 'vegetables', 'fruit',
      'bread', 'milk', 'hotel', 'tiffin', 'canteen', 'mess', 'rice',
    ],
    'Transport': [
      'transport', 'travel', 'bus', 'train', 'metro', 'auto', 'cab', 'taxi',
      'ola', 'uber', 'petrol', 'fuel', 'diesel', 'bike', 'vehicle',
      'commute', 'ticket', 'ride', 'rapido', 'rickshaw', 'flight',
    ],
    'Shopping': [
      'shopping', 'shop', 'bought', 'buy', 'purchase', 'shirt', 'clothes',
      'clothing', 'shoes', 'amazon', 'flipkart', 'myntra', 'dress',
      'jeans', 'mall', 'market', 'watch', 'bag',
    ],
    'Bills': [
      'bill', 'electricity', 'water', 'gas', 'internet', 'wifi', 'phone',
      'recharge', 'mobile', 'jio', 'airtel', 'vi', 'bsnl', 'postpaid',
      'prepaid', 'broadband', 'dth', 'subscription', 'emi',
    ],
    'Health': [
      'health', 'medicine', 'doctor', 'hospital', 'medical', 'clinic',
      'pharmacy', 'tablet', 'medicine', 'checkup', 'gym', 'fitness',
      'dentist', 'lab', 'test', 'surgery',
    ],
    'Education': [
      'education', 'school', 'college', 'tuition', 'fees', 'course',
      'book', 'books', 'study', 'exam', 'class', 'coaching', 'institute',
      'udemy', 'coursera', 'stationery',
    ],
    'Entertainment': [
      'entertainment', 'movie', 'film', 'cinema', 'netflix', 'hotstar',
      'prime', 'disney', 'concert', 'game', 'games', 'spotify', 'music',
      'theatre', 'outing', 'party', 'club',
    ],
  };

  // ── Amount RegEx ─────────────────────────────────────────────────────────
  // Matches: "450", "1,200", "1200.50", preceded or followed by currency words
  static final _amountRegex = RegExp(
    r'(?:rs\.?|inr|₹|rupees?)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ── Noise words to strip when building note ──────────────────────────────
  static const _noiseWords = {
    'spent', 'spend', 'paid', 'pay', 'bought', 'buy', 'purchase',
    'on', 'for', 'at', 'in', 'the', 'a', 'an', 'and', 'to', 'of',
    'rs', 'rs.', 'inr', 'rupees', 'rupee',
    'i', 'me', 'my', 'have', 'had', 'did', 'just',
  };

  /// Main entry point — parses raw speech transcript.
  static VoiceParsedResult parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return VoiceParsedResult(rawText: rawText);
    }

    final lower = rawText.toLowerCase().trim();

    // 1. Extract amount (pick the largest number, usually the transaction amount)
    final amountMatches = _amountRegex.allMatches(lower).toList();
    double? amount;
    for (final match in amountMatches) {
      final raw = match.group(1)?.replaceAll(',', '');
      final parsed = double.tryParse(raw ?? '');
      if (parsed != null && parsed > 0) {
        if (amount == null || parsed > amount) {
          amount = parsed;
        }
      }
    }

    // 2. Detect category via keyword matching
    String? detectedCategory;
    int bestScore = 0;
    _categoryKeywords.forEach((category, keywords) {
      int score = 0;
      for (final kw in keywords) {
        if (lower.contains(kw)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        detectedCategory = category;
      }
    });
    // Fall back to 'Other' if nothing matched
    if (bestScore == 0) detectedCategory = 'Other';

    // 3. Build note by stripping noise words and the amount string
    final noteWords = lower.split(RegExp(r'\s+'))
      .where((w) {
        // Remove pure noise words
        if (_noiseWords.contains(w)) return false;
        // Remove number tokens (they become the amount)
        if (RegExp(r'^[\d,\.₹]+$').hasMatch(w)) return false;
        // Remove currency prefix glued to a number e.g. "rs450"
        if (RegExp(r'^(?:rs\.?|inr|₹)\d').hasMatch(w)) return false;
        return true;
      })
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .toList();

    final note = noteWords.isEmpty ? null : noteWords.join(' ');

    return VoiceParsedResult(
      rawText: rawText,
      amount: amount,
      category: detectedCategory,
      note: note,
    );
  }
}
