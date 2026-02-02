import 'room_term.dart';

class MeetingRoom {
  const MeetingRoom({
    required this.centreCode,
    required this.roomCode,
    required this.roomName,
    required this.floor,
    required this.capacity,
    required this.hasVideoConference,
    required this.amenities,
    required this.photoUrls,
    required this.isBookable,
    required this.isFromNewObs,
    required this.isClosed,
    required this.isInternal,
    required this.terms,
  });

  final String centreCode;
  final String roomCode;
  final String roomName;
  final String floor;
  final int capacity;
  final bool hasVideoConference;
  final List<String> amenities;
  final List<String> photoUrls;
  final bool isBookable;
  final bool isFromNewObs;
  final bool isClosed;
  final bool isInternal;
  final List<RoomTerm> terms;
}
