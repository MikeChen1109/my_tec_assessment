import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/centre.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/city.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/meeting_room.dart';

import 'meeting_room_view_mode.dart';

enum MeetingRoomHomeStatus { loading, data, error }

class MeetingRoomHomeState {
  const MeetingRoomHomeState({
    required this.status,
    required this.city,
    required this.viewMode,
    required this.centreGroups,
    required this.roomsWithPricing,
    required this.groupedRoomsWithPricing,
    required this.citiesGroupedByRegion,
  });

  final MeetingRoomHomeStatus status;
  final City? city;
  final MeetingRoomViewMode viewMode;
  final List<Centre> centreGroups;
  final List<MeetingRoomWithPricing> roomsWithPricing;
  final Map<String, List<MeetingRoomWithPricing>> groupedRoomsWithPricing;
  final Map<String, List<City>> citiesGroupedByRegion;

  MeetingRoomHomeState copyWith({
    MeetingRoomHomeStatus? status,
    City? city,
    MeetingRoomViewMode? viewMode,
    List<Centre>? nearestCityCentres,
    List<MeetingRoomWithPricing>? roomsWithPricing,
    Map<String, List<MeetingRoomWithPricing>>? groupedRoomsWithPricing,
    Map<String, List<City>>? citiesGroupedByRegion,
  }) {
    return MeetingRoomHomeState(
      status: status ?? this.status,
      city: city ?? this.city,
      viewMode: viewMode ?? this.viewMode,
      centreGroups: nearestCityCentres ?? this.centreGroups,
      roomsWithPricing: roomsWithPricing ?? this.roomsWithPricing,
      groupedRoomsWithPricing:
          groupedRoomsWithPricing ?? this.groupedRoomsWithPricing,
      citiesGroupedByRegion:
          citiesGroupedByRegion ?? this.citiesGroupedByRegion,
    );
  }
}

class MeetingRoomWithPricing {
  const MeetingRoomWithPricing({
    required this.room,
    required this.finalPrice,
    required this.currencyCode,
  });

  final MeetingRoom room;
  final num? finalPrice;
  final String? currencyCode;
}
