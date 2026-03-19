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

  /// DTO → Entity 转换
  WalletEntity toEntity() {
    return WalletEntity(id: id, balance: balance, currency: currency);
  }

  /// Entity → DTO 转换
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

  /// DTO → Entity 转换
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: type,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Entity → DTO 转换
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
