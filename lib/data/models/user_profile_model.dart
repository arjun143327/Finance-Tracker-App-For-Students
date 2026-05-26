class UserProfileModel {
  final int? id;
  final String name;
  final double balance;
  final double income;
  final double budget;
  final String goal;
  final bool onboardingComplete;
  final String currency; // e.g. '₹', '$', '€', '£'

  UserProfileModel({
    this.id,
    required this.name,
    required this.balance,
    required this.income,
    required this.budget,
    required this.goal,
    required this.onboardingComplete,
    this.currency = '\u20b9',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'income': income,
      'budget': budget,
      'goal': goal,
      'onboarding_complete': onboardingComplete ? 1 : 0,
      'currency': currency,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'],
      name: map['name'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      income: (map['income'] ?? 0.0).toDouble(),
      budget: (map['budget'] ?? 0.0).toDouble(),
      goal: map['goal'] ?? '',
      onboardingComplete: (map['onboarding_complete'] ?? 0) == 1,
      currency: map['currency'] ?? '\u20b9',
    );
  }

  UserProfileModel copyWith({
    String? name,
    double? balance,
    double? income,
    double? budget,
    String? goal,
    bool? onboardingComplete,
    String? currency,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      income: income ?? this.income,
      budget: budget ?? this.budget,
      goal: goal ?? this.goal,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currency: currency ?? this.currency,
    );
  }
}

