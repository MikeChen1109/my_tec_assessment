import '../../domain/entities/meeting_room.dart';
import 'room_term_model.dart';

class MeetingRoomModel extends MeetingRoom {
  const MeetingRoomModel({
    required super.centreCode,
    required super.roomCode,
    required super.roomName,
    required super.floor,
    required super.capacity,
    required super.hasVideoConference,
    required super.amenities,
    required super.photoUrls,
    required super.isBookable,
    required super.isFromNewObs,
    required super.isClosed,
    required super.isInternal,
    required super.terms,
  });

  factory MeetingRoomModel.fromJson(Map<String, dynamic> json) {
    return MeetingRoomModel(
      centreCode: json['centreCode'] as String? ?? '',
      roomCode: json['roomCode'] as String? ?? '',
      roomName: json['roomName'] as String? ?? '',
      floor: json['floor'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      hasVideoConference: json['hasVideoConference'] as bool? ?? false,
      amenities: (json['amenities'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      photoUrls: (json['photoUrls'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      isBookable: json['isBookable'] as bool? ?? false,
      isFromNewObs: json['isFromNewObs'] as bool? ?? false,
      isClosed: json['isClosed'] as bool? ?? false,
      isInternal: json['isInternal'] as bool? ?? false,
      terms: (json['terms'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RoomTermModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centreCode': centreCode,
      'roomCode': roomCode,
      'roomName': roomName,
      'floor': floor,
      'capacity': capacity,
      'hasVideoConference': hasVideoConference,
      'amenities': amenities,
      'photoUrls': photoUrls,
      'isBookable': isBookable,
      'isFromNewObs': isFromNewObs,
      'isClosed': isClosed,
      'isInternal': isInternal,
      'terms': terms
          .map((term) => term is RoomTermModel
              ? term.toJson()
              : {
                  'languageCode': term.languageCode,
                  'value': term.value,
                })
          .toList(),
    };
  }
}
