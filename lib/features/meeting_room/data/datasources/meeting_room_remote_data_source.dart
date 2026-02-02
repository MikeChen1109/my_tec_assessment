import '../../../../core/network/api_client.dart';
import '../models/centre_model.dart';
import '../models/city_model.dart';
import '../models/meeting_room_model.dart';
import '../models/room_availability_model.dart';
import '../models/room_pricing_model.dart';
import 'meeting_room_endpoints.dart';

class MeetingRoomRemoteDataSource {
  MeetingRoomRemoteDataSource(this._networkService);

  final NetworkService _networkService;

  Future<List<RoomAvailabilityModel>> getRoomAvailability({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
  }) async {
    final endpoint = GetRoomAvailabilityEndpoint(
      startDate: startDate,
      endDate: endDate,
      cityCode: cityCode,
    );

    return _networkService.request(
      endpoint,
      (json) => _decodeList(json, RoomAvailabilityModel.fromJson),
    );
  }

  Future<List<RoomPricingModel>> getRoomPricing({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
    required bool isVcBooking,
    String? profileId,
  }) async {
    final endpoint = GetRoomPricingEndpoint(
      startDate: startDate,
      endDate: endDate,
      cityCode: cityCode,
      isVcBooking: isVcBooking,
      profileId: profileId,
    );

    return _networkService.request(
      endpoint,
      (json) => _decodeList(json, RoomPricingModel.fromJson),
    );
  }

  Future<List<MeetingRoomModel>> getMeetingRooms({
    String? cityCode,
  }) async {
    final endpoint = GetMeetingRoomsEndpoint(
      cityCode: cityCode,
    );

    return _networkService.request(endpoint, (json) {
      final items = (json as Map<String, dynamic>?)?['items'] as List<dynamic>?;
      return _decodeList(items, MeetingRoomModel.fromJson);
    });
  }

  Future<List<CentreModel>> getCentres() async {
    final endpoint = GetCentresEndpoint();
    return _networkService.request(endpoint, (json) {
      return _decodeList(json, CentreModel.fromJson);
    });
  }

  Future<List<CityModel>> getCities({int? pageSize, int? pageNumber}) async {
    final endpoint = GetCitiesEndpoint(
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    return _networkService.request(endpoint, (json) {
      final items = (json as Map<String, dynamic>?)?['items'] as List<dynamic>?;
      return _decodeList(items, CityModel.fromJson);
    });
  }

  List<T> _decodeList<T>(
    dynamic json,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final list = json is List<dynamic> ? json : null;
    return list?.whereType<Map<String, dynamic>>().map(fromJson).toList() ??
        const [];
  }
}
