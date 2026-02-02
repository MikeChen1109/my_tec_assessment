import '../../../../core/error/app_failure.dart';
import '../../../../core/error/app_result.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/centre.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/meeting_room.dart';
import '../../domain/entities/room_availability.dart';
import '../../domain/entities/room_pricing.dart';
import '../../domain/repositories/meeting_room_repository.dart';
import '../datasources/meeting_room_remote_data_source.dart';

class MeetingRoomRepositoryImpl implements MeetingRoomRepository {
  MeetingRoomRepositoryImpl(this._remoteDataSource);

  final MeetingRoomRemoteDataSource _remoteDataSource;

  @override
  Future<AppResult<List<RoomAvailability>>> getRoomAvailability({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
  }) {
    return _wrap(() {
      return _remoteDataSource.getRoomAvailability(
        startDate: startDate,
        endDate: endDate,
        cityCode: cityCode,
      );
    });
  }

  @override
  Future<AppResult<List<RoomPricing>>> getRoomPricing({
    required DateTime startDate,
    required DateTime endDate,
    required String cityCode,
    required bool isVcBooking,
    String? profileId,
  }) {
    final resolvedProfileId = profileId?.trim();
    return _wrap(() {
      return _remoteDataSource.getRoomPricing(
        startDate: startDate,
        endDate: endDate,
        cityCode: cityCode,
        isVcBooking: isVcBooking,
        profileId: resolvedProfileId,
      );
    });
  }

  @override
  Future<AppResult<List<MeetingRoom>>> getMeetingRooms({
    String? cityCode,
  }) {
    return _wrap(() {
      return _remoteDataSource.getMeetingRooms(
        cityCode: cityCode,
      );
    });
  }

  @override
  Future<AppResult<List<Centre>>> getCentres() {
    return _wrap(_remoteDataSource.getCentres);
  }

  @override
  Future<AppResult<List<City>>> getCities({
    int? pageSize,
    int? pageNumber,
  }) {
    return _wrap(() {
      return _remoteDataSource.getCities(
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
    });
  }

  Future<AppResult<List<T>>> _wrap<T>(Future<List<T>> Function() action) async {
    try {
      final data = await action();
      return AppResult.success(data);
    } on ApiException catch (error) {
      return AppResult.failure(
        AppFailure.server(
          statusCode: error.statusCode,
          message: error.message,
        ),
      );
    } on DioException catch (error) {
      return AppResult.failure(
        AppFailure.network(message: _describeDioError(error)),
      );
    } on FormatException catch (error) {
      return AppResult.failure(
        AppFailure.decoding(message: error.message),
      );
    } on TypeError catch (error) {
      return AppResult.failure(
        AppFailure.decoding(message: error.toString()),
      );
    } catch (error) {
      return AppResult.failure(
        AppFailure.unknown(message: error.toString()),
      );
    }
  }

  String _describeDioError(DioException error) {
    final status = error.response?.statusCode;
    final path = error.requestOptions.path;
    final type = error.type;
    final message = error.message ?? 'Dio error';
    final root = error.error;
    return 'type=$type status=$status path=$path message=$message root=$root';
  }

  static MeetingRoomRepositoryImpl createDefault() {
    final networkService = DefaultNetworkService();
    final dataSource = MeetingRoomRemoteDataSource(networkService);
    return MeetingRoomRepositoryImpl(dataSource);
  }
}
