import 'package:live_free/core/constants.dart';

enum TransactionType { expence, income }
enum IncomeType { other, salary, sale }
enum ExpenceType { entertainment, food, gift, gas, rent }

class Transaction {
  /// CONSTRUCT
  Transaction({
    required this.uuid,
    // required this.name,
    required this.amount,
    required this.timestamp,
    required TransactionType transactionType,
    required this.type,
  }) : _transactionType = transactionType;

  final String uuid;
  // final String name;
  final int amount;
  final DateTime timestamp;
  final TransactionType _transactionType;
  final Enum type;

  bool get isIncome => _transactionType == TransactionType.income;
  bool get isExpence => _transactionType == TransactionType.expence;

  /// ENCODE / DECODE ///
  Transaction.fromJson(JsonMap json)
      : uuid = json["income_uuid"] as String,
        // name = json["name"] as String,
        amount = json["amount"] as int,
        timestamp =
            DateTime.tryParse(json["timestamp"] as String) ?? DateTime(1970),
        _transactionType = json["transaction_type"] as TransactionType,
        type = json["transaction_type"] as int == 1
            ? json["type"] as IncomeType
            : json["type"] as ExpenceType;

  JsonMap toJson() => {
        "income_uuid": uuid,
        // "name": name,
        "amount": amount,
        "timestamp": timestamp,
        "transactionType": _transactionType,
        "type": type,
      };

  /// COPY ///
  Transaction copyWith({
    String? uuid,
    String? name,
    int? amount,
    DateTime? timestamp,
    Enum? type,
  }) =>
      Transaction(
        uuid: uuid ?? this.uuid,
        // name: name ?? this.name,
        amount: amount ?? this.amount,
        timestamp: timestamp ?? this.timestamp,
        transactionType: _transactionType,
        type: type ?? this.type,
      );

  @override
  int get hashCode => uuid.hashCode;

  /// COMPARE ///
  @override
  bool operator ==(dynamic other) {
    return (other is Transaction) && other.uuid == uuid;
  }

  @override
  String toString() {
    return "$_transactionType $uuid $amount $timestamp";
  }
}


// class IncomeTransaction extends Transaction {
//   IncomeTransaction({
//     required String uuid,
//     // required String name,
//     required int amount,
//     required DateTime timestamp,
//     required this.type,
//   }) : super(
//           uuid: uuid,
//           // name: name,
//           amount: amount,
//           timestamp: timestamp,
//           transactionType: TransactionType.income,
//         );
//
//   final IncomeType type;
//
//   IncomeTransaction.fromJson(JsonMap json)
//       : type = json["type"] as IncomeType,
//         super.fromJson(json);
//
//   @override
//   JsonMap toJson() {
//     final JsonMap map = {
//       "type": type,
//     };
//     map.addAll(super.toJson());
//     return map;
//   }
//
//   @override
//   String toString() => "$type : ${super.toString()}";
// }
//
//
// class ExpenceTransaction extends Transaction {
//   ExpenceTransaction({
//     required String uuid,
//     // required String name,
//     required int amount,
//     required DateTime timestamp,
//     required this.type,
//   }) : super(
//           uuid: uuid,
//           // name: name,
//           amount: amount,
//           timestamp: timestamp,
//           transactionType: TransactionType.expence,
//         );
//
//   final ExpenceType type;
//
//   ExpenceTransaction.fromJson(JsonMap json)
//       : type = json["type"] as ExpenceType,
//         super.fromJson(json);
//
//   @override
//   JsonMap toJson() {
//     final JsonMap map = {
//       "type": type,
//     };
//     map.addAll(super.toJson());
//     return map;
//   }
//
//   @override
//   String toString() => "$type : ${super.toString()}";
// }
