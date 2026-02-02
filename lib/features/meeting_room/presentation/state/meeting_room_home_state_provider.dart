import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'meeting_room_home_state.dart';
import 'meeting_room_view_mode.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/centre.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/room_pricing.dart';
import '../../domain/usecases/city_discovery.dart';
import '../../domain/usecases/get_centres.dart';
import '../../domain/usecases/get_cities.dart';
import '../../domain/usecases/get_meeting_rooms.dart';
import '../../domain/usecases/get_room_pricing.dart';
import '../services/user_location_service.dart';
import 'meeting_room_filter_state_provider.dart';

final meetingRoomHomeStateProvider =
    StateNotifierProvider<MeetingRoomHomeStateNotifier, MeetingRoomHomeState>((
      ref,
    ) {
      return MeetingRoomHomeStateNotifier(
        locationService: ref.read(userLocationServiceProvider),
        getCities: ref.read(getCitiesProvider),
        getCentres: ref.read(getCentresProvider),
        getRoomPricing: ref.read(getRoomPricingProvider),
        getMeetingRooms: ref.read(getMeetingRoomsProvider),
        filterStateReader: () => ref.read(meetingRoomFilterStateProvider),
      );
    });

class MeetingRoomHomeStateNotifier extends StateNotifier<MeetingRoomHomeState> {
  MeetingRoomHomeStateNotifier({
    required UserLocationService locationService,
    required GetCities getCities,
    required GetCentres getCentres,
    required GetRoomPricing getRoomPricing,
    required GetMeetingRooms getMeetingRooms,
    required MeetingRoomFilterState Function() filterStateReader,
  }) : _locationService = locationService,
       _getCities = getCities,
       _getCentres = getCentres,
       _getRoomPricing = getRoomPricing,
       _getMeetingRooms = getMeetingRooms,
       _filterStateReader = filterStateReader,
       _cityDiscoveryUseCase = const CityDiscoveryUseCase(),
       super(
         const MeetingRoomHomeState(
           status: MeetingRoomHomeStatus.loading,
           city: null,
           viewMode: MeetingRoomViewMode.map,
           centreGroups: [],
           roomsWithPricing: [],
           groupedRoomsWithPricing: {},
           citiesGroupedByRegion: {},
         ),
       ) {
    _init();
  }

  bool _isLoading = false;
  List<City> _cities = const [];
  List<Centre> _centres = const [];
  final UserLocationService _locationService;
  final GetCities _getCities;
  final GetCentres _getCentres;
  final GetRoomPricing _getRoomPricing;
  final GetMeetingRooms _getMeetingRooms;
  final MeetingRoomFilterState Function() _filterStateReader;
  final CityDiscoveryUseCase _cityDiscoveryUseCase;

  Future<void> _init({bool keepCity = false}) async {
    await _runLoading(
      status: MeetingRoomHomeStatus.loading,
      resetCity: !keepCity,
      keepCity: keepCity,
      errorContext: 'load meeting room data',
      body: () async {
        final data = await _loadData();
        if (!mounted) return;
        _centres = data.centres;
        _applyDiscovery(data);
      },
    );
  }

  void setViewMode(MeetingRoomViewMode viewMode) {
    if (state.viewMode == viewMode) return;
    state = state.copyWith(viewMode: viewMode);
  }

  Future<void> retry() async {
    await _init();
  }

  Future<void> refresh() async {
    await _init(keepCity: true);
  }

  Future<void> refreshForFilter() async {
    await _runLoading(
      status: MeetingRoomHomeStatus.loading,
      keepCity: true,
      errorContext: 'refresh meeting rooms',
      body: () async {
        final roomsWithPricing = await _loadRoomsWithPricing(
          cityCode: state.city?.code,
        );
        if (!mounted) return;
        final filteredRoomsWithPricing = _applyRoomFilters(roomsWithPricing);
        final groupedRoomsWithPricing = _groupRoomsByCentreName(
          filteredRoomsWithPricing,
          _centres,
        );
        state = state.copyWith(
          status: MeetingRoomHomeStatus.data,
          roomsWithPricing: filteredRoomsWithPricing,
          groupedRoomsWithPricing: groupedRoomsWithPricing,
        );
      },
    );
  }

  void selectCity(City city) {
    _updateCentres(city);
  }

  Future<void> changeCity(City city) async {
    await _runLoading(
      status: MeetingRoomHomeStatus.loading,
      city: city,
      errorContext: 'change city',
      body: () async {
        if (_centres.isEmpty) {
          _centres = await _getCentres();
        }
        final roomsWithPricing = await _loadRoomsWithPricing(
          cityCode: city.code,
        );
        if (!mounted) return;
        final filteredRoomsWithPricing = _applyRoomFilters(roomsWithPricing);
        final groupedRoomsWithPricing = _groupRoomsByCentreName(
          filteredRoomsWithPricing,
          _centres,
        );
        final centreGroups = _cityDiscoveryUseCase.centresForCityCode(
          centres: _centres,
          cityCode: city.code,
        );
        state = state.copyWith(
          status: MeetingRoomHomeStatus.data,
          city: city,
          nearestCityCentres: centreGroups,
          roomsWithPricing: filteredRoomsWithPricing,
          groupedRoomsWithPricing: groupedRoomsWithPricing,
        );
      },
    );
  }

  Future<void> _runLoading({
    required MeetingRoomHomeStatus status,
    required String errorContext,
    required Future<void> Function() body,
    City? city,
    bool keepCity = false,
    bool resetCity = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    state = state.copyWith(
      status: status,
      city: resetCity ? null : (keepCity ? state.city : city ?? state.city),
    );
    try {
      await body();
    } catch (error, stackTrace) {
      debugPrint('Failed to $errorContext: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      state = state.copyWith(status: MeetingRoomHomeStatus.error);
    } finally {
      _isLoading = false;
    }
  }

  Future<City?> resolveNearestCity() async {
    final cities = _cities.isNotEmpty ? _cities : await _getCities();
    final centres = _centres.isNotEmpty ? _centres : await _getCentres();
    if (_cities.isEmpty) {
      _cities = cities;
    }
    if (_centres.isEmpty) {
      _centres = centres;
    }
    final userLocation = await _locationService.fetchAndLogLocation();
    final discovery = _cityDiscoveryUseCase(
      cities: cities,
      centres: centres,
      userLat: userLocation.latitude,
      userLng: userLocation.longitude,
    );
    return discovery.nearestCity;
  }

  void _updateCentres(City city) {
    final centreGroups = _cityDiscoveryUseCase.centresForCityCode(
      centres: _centres,
      cityCode: city.code,
    );
    state = state.copyWith(
      city: city,
      nearestCityCentres: centreGroups,
    );
  }

  Future<_MeetingRoomHomeLoadData> _loadData() async {
    final citiesFuture = _getCities();
    final centresFuture = _getCentres();
    final userLocation = await _locationService.fetchAndLogLocation();
    final cities = await citiesFuture;
    final centres = await centresFuture;
    final discovery = _cityDiscoveryUseCase(
      cities: cities,
      centres: centres,
      userLat: userLocation.latitude,
      userLng: userLocation.longitude,
    );
    final roomsWithPricing = await _loadRoomsWithPricing(
      cityCode: discovery.nearestCity?.code,
    );
    final filteredRoomsWithPricing = _applyRoomFilters(roomsWithPricing);
    final groupedRoomsWithPricing = _groupRoomsByCentreName(
      filteredRoomsWithPricing,
      centres,
    );
    return _MeetingRoomHomeLoadData(
      cities: cities,
      centres: centres,
      discovery: discovery,
      roomsWithPricing: filteredRoomsWithPricing,
      groupedRoomsWithPricing: groupedRoomsWithPricing,
      userLocation: userLocation,
    );
  }

  void _applyDiscovery(_MeetingRoomHomeLoadData data) {
    final discovery = data.discovery;
    final nearestCity = discovery.nearestCity;
    final nearestCityCentres = discovery.nearestCityCentres;
    _cities = data.cities;
    debugPrint(
      nearestCity == null
          ? 'Nearest city not found.'
          : 'Nearest city: ${nearestCity.code} - ${nearestCity.name}',
    );
    state = state.copyWith(
      status: MeetingRoomHomeStatus.data,
      city: nearestCity,
      nearestCityCentres: nearestCityCentres,
      roomsWithPricing: data.roomsWithPricing,
      groupedRoomsWithPricing: data.groupedRoomsWithPricing,
      citiesGroupedByRegion: discovery.citiesGroupedByRegion,
    );
  }

  Future<List<MeetingRoomWithPricing>> _loadRoomsWithPricing({
    required String? cityCode,
  }) async {
    final resolvedCityCode = cityCode?.trim();
    if (resolvedCityCode == null || resolvedCityCode.isEmpty) {
      return const [];
    }
    final filterState = _filterStateReader();
    final pricingFuture = _getRoomPricing(
      startDate: filterState.startDateTime,
      endDate: filterState.endDateTime,
      cityCode: resolvedCityCode,
      isVcBooking: filterState.videoConferenceEnabled,
    );
    final roomsFuture = _getMeetingRooms(
      cityCode: resolvedCityCode,
    );
    final pricing = await pricingFuture;
    final rooms = await roomsFuture;
    if (rooms.isEmpty) {
      return const [];
    }
    final pricingByRoomCode = <String, RoomPricing>{
      for (final price in pricing) price.roomCode: price,
    };
    return rooms.map((room) {
      final price = pricingByRoomCode[room.roomCode];
      return MeetingRoomWithPricing(
        room: room,
        finalPrice: price?.finalPrice,
        currencyCode: price?.currencyCode,
      );
    }).toList();
  }

  List<MeetingRoomWithPricing> _applyRoomFilters(
    List<MeetingRoomWithPricing> rooms,
  ) {
    if (rooms.isEmpty) {
      return const [];
    }
    final filterState = _filterStateReader();
    final selectedCentreCodes = filterState.selectedCentreCodes;
    final capacity = filterState.capacity;
    return rooms.where((item) {
      if (item.room.capacity < capacity) {
        return false;
      }
      if (selectedCentreCodes != null && selectedCentreCodes.isNotEmpty) {
        return selectedCentreCodes.contains(item.room.centreCode);
      }
      return true;
    }).toList();
  }

  Map<String, List<MeetingRoomWithPricing>> _groupRoomsByCentreName(
    List<MeetingRoomWithPricing> rooms,
    List<Centre> centres,
  ) {
    if (rooms.isEmpty) {
      return const {};
    }
    final centreCodeToName = <String, String>{};
    for (final centre in centres) {
      final name = centre.localizedName.en?.trim();
      if (name == null || name.isEmpty) {
        continue;
      }
      for (final code in centre.centreCodesForVoCwCheckout) {
        final trimmed = code.trim();
        if (trimmed.isNotEmpty) {
          centreCodeToName[trimmed] = name;
        }
      }
    }
    final grouped = <String, List<MeetingRoomWithPricing>>{};
    for (final item in rooms) {
      final groupName =
          centreCodeToName[item.room.centreCode] ?? 'Other';
      grouped.putIfAbsent(groupName, () => []).add(item);
    }
    return grouped;
  }
}

class _MeetingRoomHomeLoadData {
  const _MeetingRoomHomeLoadData({
    required this.cities,
    required this.centres,
    required this.discovery,
    required this.roomsWithPricing,
    required this.groupedRoomsWithPricing,
    required this.userLocation,
  });

  final List<City> cities;
  final List<Centre> centres;
  final CityDiscoveryResult discovery;
  final List<MeetingRoomWithPricing> roomsWithPricing;
  final Map<String, List<MeetingRoomWithPricing>> groupedRoomsWithPricing;
  final UserLocation userLocation;
}
