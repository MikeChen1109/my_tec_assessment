import '../../domain/entities/room_term.dart';

class RoomTermModel extends RoomTerm {
  const RoomTermModel({
    required super.languageCode,
    required super.value,
  });

  factory RoomTermModel.fromJson(Map<String, dynamic> json) {
    return RoomTermModel(
      languageCode: json['languageCode'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'value': value,
    };
  }
}
