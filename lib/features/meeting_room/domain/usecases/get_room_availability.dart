import '../../../../core/error/app_result.dart';
import '../entities/room_availability.dart';
import '../repositories/meeting_room_repository.dart';

class GetRoomAvailability {
  const GetRoomAvailability(this._repository);

  final MeetingRoomRepository _repository;

  Future<AppResult<List<RoomAvailability>>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
  }) {
    return _repository.getRoomAvailability(
      startDate: startDate,
      endDate: endDate,
      cityCode: cityCode,
    );
  }
}
