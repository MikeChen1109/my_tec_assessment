import '../entities/city.dart';
import '../repositories/meeting_room_repository.dart';

class GetCities {
  const GetCities(this._repository);

  final MeetingRoomRepository _repository;

  Future<List<City>> call({int? pageSize, int? pageNumber}) {
    return _repository
        .getCities(pageSize: pageSize, pageNumber: pageNumber)
        .then(
          (result) => result.when(success: (data) => data, failure: (_) => []),
        );
  }
}
