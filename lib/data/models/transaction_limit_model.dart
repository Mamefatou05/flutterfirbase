class TransactionLimits {
  final double dailyLimit;
  final double monthlyLimit;

  TransactionLimits({
    required this.dailyLimit,
    required this.monthlyLimit,
  });

  factory TransactionLimits.defaultLimits() {
    return TransactionLimits(
      dailyLimit: 5000.0,
      monthlyLimit: 50000.0,
    );
  }

  factory TransactionLimits.fromJson(Map<String, dynamic> json) {
    return TransactionLimits(
      dailyLimit: (json['dailyLimit'] ?? 5000.0).toDouble(),
      monthlyLimit: (json['monthlyLimit'] ?? 50000.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyLimit': dailyLimit,
    'monthlyLimit': monthlyLimit,
  };
}