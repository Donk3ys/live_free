import 'package:flutter/foundation.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/core/util_core.dart';

enum TransactionType { expence, income }

extension TransactionTypeExtension on TransactionType {
  String get display => describeEnum(this).camelCaseToString.capitalizeFirst;
  bool get isIncome => this == TransactionType.income;
  bool get isExpence => this == TransactionType.expence;

  static TransactionType fromString(String t) =>
      TransactionType.values.firstWhere(
        (v) => describeEnum(v) == t,
        orElse: () => throw FormatException(
          "No transaction type ${TransactionType.values.length} > & < 0",
        ),
      );

  int get toInt {
    late int rInt;
    switch (this) {
      case TransactionType.expence:
        rInt = 0;
        break;
      case TransactionType.income:
        rInt = 1;
        break;
    }

    return rInt;
  }

  static TransactionType fromInt(int t) {
    switch (t) {
      case 0:
        return TransactionType.expence;
      case 1:
        return TransactionType.income;
      default:
        throw FormatException(
          "No transaction type ${TransactionType.values.length} > & < 0",
        );
    }
  }
}

class Transaction {
  /// CONSTRUCT
  Transaction({
    required this.uuid,
    // required this.name,
    required this.amount,
    required this.timestamp,
    required TransactionType transactionType,
    required this.category,
  }) : _transactionType = transactionType;

  final String uuid;
  // final String name;
  final int amount;
  final DateTime timestamp;
  final TransactionType _transactionType;
  final TransactionCategory category;

  bool get isIncome => _transactionType == TransactionType.income;
  bool get isExpence => _transactionType == TransactionType.expence;

  /// ENCODE / DECODE ///
  Transaction.fromJson(JsonMap json)
      : uuid = json["income_uuid"] as String,
        // name = json["name"] as String,
        amount = json["amount"] as int,
        timestamp =
            DateTime.tryParse(json["timestamp"] as String) ?? DateTime(1970),
        _transactionType =
            TransactionTypeExtension.fromInt(json["transaction_type"] as int),
        category = TransactionCategory.fromJson(json);

  JsonMap toJson() => {
        "income_uuid": uuid,
        // "name": name,
        "amount": amount,
        "timestamp": timestamp,
        "transactionType": _transactionType.toInt,
        "type": category.toJson(),
      };

  /// COPY ///
  Transaction copyWith({
    String? uuid,
    String? name,
    int? amount,
    DateTime? timestamp,
    TransactionCategory? category,
  }) =>
      Transaction(
        uuid: uuid ?? this.uuid,
        // name: name ?? this.name,
        amount: amount ?? this.amount,
        timestamp: timestamp ?? this.timestamp,
        transactionType: _transactionType,
        category: category ?? this.category,
      );

  /// COMPARE ///
  @override
  int get hashCode => uuid.hashCode;

  @override
  bool operator ==(dynamic other) {
    return (other is Transaction) && other.uuid == uuid;
  }

  @override
  String toString() {
    return "$_transactionType $uuid $amount $timestamp";
  }
}

class TransactionCategory {
  final int id;
  final String name;

  TransactionCategory({required this.id, required this.name});

  TransactionCategory.fromJson(JsonMap json)
      : id = json["id"] as int,
        name = json["name"] as String;

  JsonMap toJson() => {
        "id": id,
        "name": name,
      };

	/// COMPARE ///
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) {
    return (other is TransactionCategory) && other.id == id;
  }
}
