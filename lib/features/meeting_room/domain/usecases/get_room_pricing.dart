import '../entities/room_pricing.dart';
import '../repositories/meeting_room_repository.dart';

class GetRoomPricing {
  const GetRoomPricing(this._repository);

  final MeetingRoomRepository _repository;

  Future<List<RoomPricing>> call({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
    required bool isVcBooking,
    String? profileId,
  }) async {
    final result = await _repository.getRoomPricing(
      startDate: startDate,
      endDate: endDate,
      cityCode: cityCode,
      isVcBooking: isVcBooking,
      profileId: profileId,
    );
    return result.when(success: (data) => data, failure: (_) => const []);
  }
}
