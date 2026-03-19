// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// LtDeserializationGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) {
  return WalletModel(
    id: json['id'] as String,
    balance: json['balance'] as double,
    currency: json['currency'] as String,
  );
}

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return TransactionModel(
    id: json['id'] as String,
    amount: json['amount'] as double,
    type: json['type'] as String,
    createdAt: json['created_at'] as String,
  );
}
