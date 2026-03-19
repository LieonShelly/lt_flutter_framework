class WalletEntity {
  final String id;
  final double balance;
  final String currency;

  const WalletEntity({
    required this.id,
    required this.balance,
    required this.currency,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          balance == other.balance &&
          currency == other.currency;

  @override
  int get hashCode => id.hashCode ^ balance.hashCode ^ currency.hashCode;
}

class TransactionEntity {
  final String id;
  final double amount;
  final String type;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
