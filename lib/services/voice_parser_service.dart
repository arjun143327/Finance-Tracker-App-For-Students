/// VoiceParserService
///
/// Pure Dart — zero API calls, zero external dependencies.
/// Uses RegEx for amount extraction and keyword maps for category matching.
/// Also handles English number words like "four hundred fifty" → 450.
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
  static const Map<String, List<String>> _categoryKeywords = {
    'Food': [
      'food', 'eat', 'eating', 'lunch', 'dinner', 'breakfast', 'pizza',
      'burger', 'restaurant', 'cafe', 'coffee', 'tea', 'snack', 'biryani',
      'swiggy', 'zomato', 'grocery', 'groceries', 'vegetables', 'fruit',
      'bread', 'milk', 'hotel', 'tiffin', 'canteen', 'mess', 'rice',
      'dosa', 'idli', 'paratha', 'chai', 'juice', 'water bottle',
    ],
    'Transport': [
      'transport', 'travel', 'bus', 'train', 'metro', 'auto', 'cab', 'taxi',
      'ola', 'uber', 'petrol', 'fuel', 'diesel', 'bike', 'vehicle',
      'commute', 'ticket', 'ride', 'rapido', 'rickshaw', 'flight', 'toll',
    ],
    'Shopping': [
      'shopping', 'shop', 'bought', 'buy', 'purchase', 'shirt', 'clothes',
      'clothing', 'shoes', 'amazon', 'flipkart', 'myntra', 'dress',
      'jeans', 'mall', 'market', 'watch', 'bag', 'accessories',
    ],
    'Bills': [
      'bill', 'electricity', 'water', 'gas', 'internet', 'wifi', 'phone',
      'recharge', 'mobile', 'jio', 'airtel', 'vi', 'bsnl', 'postpaid',
      'prepaid', 'broadband', 'dth', 'subscription', 'emi', 'rent',
    ],
    'Health': [
      'health', 'medicine', 'doctor', 'hospital', 'medical', 'clinic',
      'pharmacy', 'tablet', 'checkup', 'gym', 'fitness', 'dentist',
      'lab', 'surgery', 'tablets', 'pills', 'injection',
    ],
    'Education': [
      'education', 'school', 'college', 'tuition', 'fees', 'course',
      'book', 'books', 'study', 'exam', 'class', 'coaching', 'institute',
      'udemy', 'coursera', 'stationery', 'pen', 'notebook',
    ],
    'Entertainment': [
      'entertainment', 'movie', 'film', 'cinema', 'netflix', 'hotstar',
      'prime', 'disney', 'concert', 'game', 'games', 'spotify', 'music',
      'theatre', 'outing', 'party', 'club', 'fun', 'show', 'ticket',
    ],
  };

  // ── English number words map ─────────────────────────────────────────────
  static const Map<String, int> _ones = {
    'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
    'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
    'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14,
    'fifteen': 15, 'sixteen': 16, 'seventeen': 17, 'eighteen': 18,
    'nineteen': 19, 'twenty': 20, 'thirty': 30, 'forty': 40,
    'fifty': 50, 'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90,
  };

  static const Map<String, int> _multipliers = {
    'hundred': 100,
    'thousand': 1000,
    'lakh': 100000,
    'lakhs': 100000,
    'million': 1000000,
  };

  // ── Amount RegEx (digit-based) ───────────────────────────────────────────
  // Matches numeric amounts like 450, 1,200, 1200.50, ₹450, Rs. 1200
  static final _digitAmountRegex = RegExp(
    r'(?:rs\.?\s*|inr\s*|₹\s*)?(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ── Noise words to strip when building note ──────────────────────────────
  static const _noiseWords = {
    'spent', 'spend', 'paid', 'pay', 'bought', 'buy', 'purchase',
    'on', 'for', 'at', 'in', 'the', 'a', 'an', 'and', 'to', 'of',
    'rs', 'inr', 'rupees', 'rupee', 'i', 'me', 'my', 'have', 'had',
    'did', 'just', 'today', 'yesterday', 'now',
  };

  /// Main entry point — parses raw speech transcript.
  static VoiceParsedResult parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return VoiceParsedResult(rawText: rawText);
    }

    final lower = rawText.toLowerCase().trim();

    // 1. Try digit-based amount first
    double? amount = _extractDigitAmount(lower);

    // 2. If no digit found, try word-based number parsing
    amount ??= _extractWordAmount(lower);

    // 3. Detect category via keyword matching
    String detectedCategory = 'Other';
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

    // 4. Build note by stripping noise words and number tokens
    final noteWords = lower.split(RegExp(r'\s+'))
      .where((w) {
        if (_noiseWords.contains(w)) return false;
        if (RegExp(r'^[\d,\.₹]+$').hasMatch(w)) return false;
        if (RegExp(r'^(?:rs\.?|inr|₹)\d').hasMatch(w)) return false;
        // Strip pure number words used as the amount
        if (_ones.containsKey(w)) return false;
        if (_multipliers.containsKey(w)) return false;
        return true;
      })
      .map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w)
      .where((w) => w.isNotEmpty)
      .toList();

    final note = noteWords.isEmpty ? null : noteWords.join(' ');

    return VoiceParsedResult(
      rawText: rawText,
      amount: amount,
      category: detectedCategory,
      note: note,
    );
  }

  // ── Digit amount extractor ───────────────────────────────────────────────
  static double? _extractDigitAmount(String lower) {
    final matches = _digitAmountRegex.allMatches(lower).toList();
    double? best;
    for (final match in matches) {
      final raw = match.group(1)?.replaceAll(',', '');
      final parsed = double.tryParse(raw ?? '');
      if (parsed != null && parsed > 0) {
        if (best == null || parsed > best) {
          best = parsed;
        }
      }
    }
    return best;
  }

  // ── Word-to-number converter ─────────────────────────────────────────────
  // Handles: "four fifty", "three hundred", "one thousand two hundred"
  static double? _extractWordAmount(String lower) {
    final words = lower.split(RegExp(r'\s+'));
    int current = 0;
    int total = 0;
    bool foundAny = false;

    for (final word in words) {
      if (_ones.containsKey(word)) {
        current += _ones[word]!;
        foundAny = true;
      } else if (_multipliers.containsKey(word)) {
        final mult = _multipliers[word]!;
        if (mult >= 1000) {
          total += (current == 0 ? 1 : current) * mult;
          current = 0;
        } else {
          current *= mult;
        }
        foundAny = true;
      } else if (foundAny) {
        // Non-number word after we've started — stop collecting
        break;
      }
    }

    final result = total + current;
    return (foundAny && result > 0) ? result.toDouble() : null;
  }
}
