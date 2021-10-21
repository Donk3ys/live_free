import 'package:live_free/core/constants.dart';

class Saving {
  /// CONSTRUCT
  Saving({
    required this.uuid,
    required this.name,
    required this.amount,
  });

  final String uuid;
  final String name;
  final int amount;

  /// ENCODE / DECODE ///
  factory Saving.fromJson(JsonMap json) => Saving(
        uuid: json["uuid"] as String,
        name: json["name"] as String,
        amount: json["amount"] as int,
      );

  JsonMap toJson() => {
        "uuid": uuid,
        "name": name,
        "amount": amount,
      };

  /// COPY ///
  Saving copyWith({
    String? uuid,
    String? name,
    int? amount,
  }) =>
      Saving(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        amount: amount ?? this.amount,
      );

  /// COMPARE ///
  @override
  int get hashCode => uuid.hashCode;

  @override
  bool operator ==(dynamic other) {
    return (other is Saving) && other.uuid == uuid;
  }

  @override
  String toString() {
    return "$uuid $name $amount";
  }
}
