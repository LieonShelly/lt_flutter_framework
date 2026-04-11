import 'package:lt_annotation/annotation.dart';
import 'package:wallet_domain/wallet_domain.dart';

part 'wallet_model.lt_model.dart';

@ltDeserialization
class WalletModel {
  final String id;
  final double balance;
  final String currency;

  WalletModel({
    required this.id,
    required this.balance,
    required this.currency,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  WalletEntity toEntity() {
    return WalletEntity(id: id, balance: balance, currency: currency);
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      id: entity.id,
      balance: entity.balance,
      currency: entity.currency,
    );
  }
}

@ltDeserialization
class TransactionModel {
  final String id;
  final double amount;
  final String type;
  @LtJsonKey('created_at')
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: type,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

// ticker_model.dart
class TickerModel {
  final String symbol;
  final double price;
  final String timestamp;

  TickerModel({
    required this.symbol,
    required this.price,
    required this.timestamp,
  });

  factory TickerModel.fromJson(Map<String, dynamic> json) {
    return TickerModel(
      symbol: json['symbol'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }
}
