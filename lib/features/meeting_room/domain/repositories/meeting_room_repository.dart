import '../../../../core/error/app_result.dart';
import '../entities/centre.dart';
import '../entities/city.dart';
import '../entities/meeting_room.dart';
import '../entities/room_availability.dart';
import '../entities/room_pricing.dart';

abstract class MeetingRoomRepository {
  Future<AppResult<List<RoomAvailability>>> getRoomAvailability({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
  });

  Future<AppResult<List<RoomPricing>>> getRoomPricing({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
    required bool isVcBooking,
    String? profileId,
  });

  Future<AppResult<List<MeetingRoom>>> getMeetingRooms({
    String? cityCode,
  });

  Future<AppResult<List<Centre>>> getCentres();

  Future<AppResult<List<City>>> getCities({
    int? pageSize,
    int? pageNumber,
  });
}
