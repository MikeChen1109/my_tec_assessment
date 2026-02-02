import '../entities/centre.dart';
import '../repositories/meeting_room_repository.dart';

class GetCentres {
  const GetCentres(this._repository);

  final MeetingRoomRepository _repository;

  Future<List<Centre>> call() {
    return _repository.getCentres().then(
      (result) => result.when(success: (data) => data, failure: (_) => []),
    );
  }
}
