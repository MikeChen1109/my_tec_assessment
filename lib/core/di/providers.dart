import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/meeting_room/data/datasources/meeting_room_remote_data_source.dart';
import '../../features/meeting_room/data/repositories/meeting_room_repository_impl.dart';
import '../../features/meeting_room/domain/repositories/meeting_room_repository.dart';
import '../../features/meeting_room/domain/usecases/get_centres.dart';
import '../../features/meeting_room/domain/usecases/get_cities.dart';
import '../../features/meeting_room/domain/usecases/get_meeting_rooms.dart';
import '../../features/meeting_room/domain/usecases/get_room_availability.dart';
import '../../features/meeting_room/domain/usecases/get_room_pricing.dart';
import '../../features/meeting_room/presentation/services/user_location_service.dart';
import '../network/api_client.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final networkServiceProvider = Provider<NetworkService>((ref) {
  return DefaultNetworkService(dio: ref.read(dioProvider));
});

final meetingRoomRemoteDataSourceProvider =
    Provider<MeetingRoomRemoteDataSource>((ref) {
  return MeetingRoomRemoteDataSource(ref.read(networkServiceProvider));
});

final meetingRoomRepositoryProvider = Provider<MeetingRoomRepository>((ref) {
  return MeetingRoomRepositoryImpl(
    ref.read(meetingRoomRemoteDataSourceProvider),
  );
});

final getRoomAvailabilityProvider = Provider<GetRoomAvailability>((ref) {
  return GetRoomAvailability(ref.read(meetingRoomRepositoryProvider));
});

final getRoomPricingProvider = Provider<GetRoomPricing>((ref) {
  return GetRoomPricing(ref.read(meetingRoomRepositoryProvider));
});

final getMeetingRoomsProvider = Provider<GetMeetingRooms>((ref) {
  return GetMeetingRooms(ref.read(meetingRoomRepositoryProvider));
});

final getCentresProvider = Provider<GetCentres>((ref) {
  return GetCentres(ref.read(meetingRoomRepositoryProvider));
});

final getCitiesProvider = Provider<GetCities>((ref) {
  return GetCities(ref.read(meetingRoomRepositoryProvider));
});

final userLocationServiceProvider = Provider<UserLocationService>((ref) {
  return UserLocationService();
});
