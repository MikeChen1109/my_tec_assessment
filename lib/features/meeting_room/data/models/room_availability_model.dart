import '../../domain/entities/room_availability.dart';

class RoomAvailabilityModel extends RoomAvailability {
  const RoomAvailabilityModel({
    required super.roomCode,
    required super.isAvailable,
    required super.isWithinOfficeHour,
    required super.isPast,
    required super.nextAvailabilities,
  });

  factory RoomAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return RoomAvailabilityModel(
      roomCode: json['roomCode'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
      isWithinOfficeHour: json['isWithinOfficeHour'] as bool? ?? false,
      isPast: json['isPast'] as bool? ?? false,
      nextAvailabilities: (json['nextAvailabilities'] as List<dynamic>? ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'isAvailable': isAvailable,
      'isWithinOfficeHour': isWithinOfficeHour,
      'isPast': isPast,
      'nextAvailabilities': nextAvailabilities,
    };
  }
}
