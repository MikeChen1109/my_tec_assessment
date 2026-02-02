import '../entities/meeting_room.dart';
import '../repositories/meeting_room_repository.dart';

class GetMeetingRooms {
  const GetMeetingRooms(this._repository);

  final MeetingRoomRepository _repository;

  Future<List<MeetingRoom>> call({
    String? cityCode,
  }) async {
    final result = await _repository.getMeetingRooms(
      cityCode: cityCode,
    );
    return result.when(success: (data) => data, failure: (_) => const []);
  }
}
