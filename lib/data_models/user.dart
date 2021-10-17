import 'package:live_free/core/constants.dart';

class IncomeItem {
  /// CONSTRUCT
  IncomeItem({
    required this.uuid,
    required this.name,
    required this.amount,
  });

  final String uuid;
  final String name;
  final int amount;

  /// ENCODE / DECODE ///
  factory IncomeItem.fromJson(JsonMap json) => IncomeItem(
        uuid: json["income_uuid"] as String,
        name: json["name"] as String,
        amount: json["amount"] as int,
      );

  Map<String, dynamic> toJson() => {
        "income_uuid": uuid,
        "name": name,
        "amount": amount,
      };

  /// COPY ///
  IncomeItem copyWith({
    String? uuid,
    String? name,
    int? amount,
  }) =>
      IncomeItem(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        amount: amount ?? this.amount,
      );

  @override
  int get hashCode => uuid.hashCode;

  /// COMPARE ///
  @override
  bool operator ==(dynamic other) {
    return (other is IncomeItem) && other.uuid == uuid;
  }

  @override
  String toString() {
    return "$uuid $name $amount";
  }
}
