import 'package:flutter_test/flutter_test.dart';
import 'package:my_tec_assessment_test/core/error/app_result.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/centre.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/city.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/meeting_room.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/room_availability.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/room_pricing.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/entities/room_term.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/repositories/meeting_room_repository.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/usecases/get_centres.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/usecases/get_cities.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/usecases/get_meeting_rooms.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/usecases/get_room_availability.dart';
import 'package:my_tec_assessment_test/features/meeting_room/domain/usecases/get_room_pricing.dart';
import 'package:my_tec_assessment_test/features/meeting_room/presentation/services/user_location_service.dart';
import 'package:my_tec_assessment_test/features/meeting_room/presentation/state/meeting_room_filter_state_provider.dart';
import 'package:my_tec_assessment_test/features/meeting_room/presentation/state/meeting_room_home_state.dart';
import 'package:my_tec_assessment_test/features/meeting_room/presentation/state/meeting_room_home_state_provider.dart';
import 'package:my_tec_assessment_test/features/meeting_room/presentation/state/meeting_room_view_mode.dart';

class _FakeMeetingRoomRepository implements MeetingRoomRepository {
  _FakeMeetingRoomRepository({
    required this.cities,
    required this.centres,
    required this.rooms,
    required this.pricing,
  });

  final List<City> cities;
  final List<Centre> centres;
  final List<MeetingRoom> rooms;
  final List<RoomPricing> pricing;

  @override
  Future<AppResult<List<RoomAvailability>>> getRoomAvailability({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
  }) async {
    return const AppResult.success([]);
  }

  @override
  Future<AppResult<List<RoomPricing>>> getRoomPricing({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
    required bool isVcBooking,
    String? profileId,
  }) async {
    return AppResult.success(pricing);
  }

  @override
  Future<AppResult<List<MeetingRoom>>> getMeetingRooms({
    String? cityCode,
  }) async {
    return AppResult.success(rooms);
  }

  @override
  Future<AppResult<List<Centre>>> getCentres() async {
    return AppResult.success(centres);
  }

  @override
  Future<AppResult<List<City>>> getCities({
    int? pageSize,
    int? pageNumber,
  }) async {
    return AppResult.success(cities);
  }
}

class _TestUserLocationService extends UserLocationService {
  _TestUserLocationService({required this.location});

  final UserLocation location;

  @override
  Future<UserLocation> fetchAndLogLocation() async => location;
}

Future<void> _waitForData(MeetingRoomHomeStateNotifier notifier) async {
  for (var i = 0; i < 30; i += 1) {
    if (notifier.state.status == MeetingRoomHomeStatus.data) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw TestFailure('MeetingRoomHomeStateNotifier did not reach data status.');
}

City _buildCity({required String code, required String name}) {
  return City(
    cityId: 1,
    countryId: 1,
    code: code,
    name: name,
    timeZone: const CityTimeZone(
      displayName: 'UTC+8',
      standardName: 'UTC+8',
      baseUtcOffset: '+08:00',
    ),
    isActive: true,
    accountEmail: 'test@example.com',
    currencyIsoCode: 'USD',
    generalEmail: 'general@example.com',
    generalPhone: '+123456789',
    meEmail: 'me@example.com',
    nameTranslation: const {},
    paymentGateway: 'gateway',
    paymentMethod: 'method',
    sequence: 1,
    voCwEmail: 'vocw@example.com',
    bdGroupEmail: 'bd@example.com',
    region: const CityRegion(id: 'r1', name: {'en': 'Asia'}),
  );
}

Centre _buildCentre({
  required String id,
  required String cityCode,
  required String name,
  required String centreCode,
  required double lat,
  required double lng,
}) {
  return Centre(
    id: id,
    country: 'TW',
    cityId: '1',
    cityCode: cityCode,
    citySlug: 'slug',
    displayEmail: 'centre@example.com',
    displayPhone: '+123456789',
    centreCodesForVoCwCheckout: [centreCode],
    amenities: const {},
    centreHighlights: const {},
    centreSchedule: const {},
    displayAddress: const {},
    displayAddressWithLevel: const {},
    localizedName: LocalizedName(
      en: name,
      jp: null,
      kr: null,
      zhHans: null,
      zhHant: null,
    ),
    slug: 'slug',
    status: 'active',
    mapboxCoordinates:
        CentreMapboxCoordinates(latitude: lat, longitude: lng),
    isDeleted: false,
  );
}

MeetingRoom _buildRoom({
  required String centreCode,
  required String roomCode,
  required String name,
  required int capacity,
}) {
  return MeetingRoom(
    centreCode: centreCode,
    roomCode: roomCode,
    roomName: name,
    floor: '1F',
    capacity: capacity,
    hasVideoConference: false,
    amenities: const [],
    photoUrls: const [],
    isBookable: true,
    isFromNewObs: false,
    isClosed: false,
    isInternal: false,
    terms: const <RoomTerm>[],
  );
}

RoomPricing _buildPricing({
  required String roomCode,
  required num price,
}) {
  return RoomPricing(
    roomCode: roomCode,
    bestPricingStrategyName: 'standard',
    initialPrice: price,
    finalPrice: price,
    currencyCode: 'USD',
    isPackageApplicable: false,
  );
}

void main() {
  test('setViewMode updates state correctly', () async {
    final city = _buildCity(code: 'CITY_A', name: 'City A');
    final centres = [
      _buildCentre(
        id: 'A1',
        cityCode: city.code,
        name: 'Centre A1',
        centreCode: 'A1',
        lat: 10,
        lng: 10,
      ),
    ];
    final rooms = [
      _buildRoom(
        centreCode: 'A1',
        roomCode: 'R1',
        name: 'Room 1',
        capacity: 4,
      ),
    ];
    final pricing = [
      _buildPricing(roomCode: 'R1', price: 100),
    ];

    final repository = _FakeMeetingRoomRepository(
      cities: [city],
      centres: centres,
      rooms: rooms,
      pricing: pricing,
    );
    final notifier = MeetingRoomHomeStateNotifier(
      locationService:
          _TestUserLocationService(location: const UserLocation(latitude: 10, longitude: 10)),
      getCities: GetCities(repository),
      getCentres: GetCentres(repository),
      getRoomPricing: GetRoomPricing(repository),
      getMeetingRooms: GetMeetingRooms(repository),
      filterStateReader: () => MeetingRoomFilterState.initial(),
      getRoomAvailability: GetRoomAvailability(repository),
    );

    await _waitForData(notifier);

    expect(notifier.state.viewMode, MeetingRoomViewMode.map);
    notifier.setViewMode(MeetingRoomViewMode.list);
    expect(notifier.state.viewMode, MeetingRoomViewMode.list);
    notifier.setViewMode(MeetingRoomViewMode.map);
    expect(notifier.state.viewMode, MeetingRoomViewMode.map);
  });
}
