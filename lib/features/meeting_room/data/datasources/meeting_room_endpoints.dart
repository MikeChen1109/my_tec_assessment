import '../../../../core/constants/api_config.dart';
import '../../../../core/network/api_client.dart';

class GetRoomAvailabilityEndpoint implements ApiEndpoint {
  GetRoomAvailabilityEndpoint({
    required this.startDate,
    required this.endDate,
    required this.cityCode,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String cityCode;

  @override
  String get baseUrl => ApiConfig.baseUrl;

  @override
  String get path => '/core-api-me/api/v1/meetingrooms/availabilities';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters => {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'cityCode': cityCode,
      };

  @override
  dynamic get body => null;
}

class GetRoomPricingEndpoint implements ApiEndpoint {
  GetRoomPricingEndpoint({
    required this.startDate,
    required this.endDate,
    required this.cityCode,
    required this.isVcBooking,
    required this.profileId,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String cityCode;
  final bool isVcBooking;
  final String? profileId;

  @override
  String get baseUrl => ApiConfig.baseUrl;

  @override
  String get path => '/core-api-me/api/v1/meetingrooms/pricings';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters {
    final params = <String, dynamic>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'cityCode': cityCode,
      'isVcBooking': isVcBooking,
    };
    final trimmedProfileId = profileId?.trim();
    if (trimmedProfileId != null && trimmedProfileId.isNotEmpty) {
      params['profileId'] = trimmedProfileId;
    }
    return params;
  }

  @override
  dynamic get body => null;
}

class GetMeetingRoomsEndpoint implements ApiEndpoint {
  GetMeetingRoomsEndpoint({
    required this.cityCode,
  });

  final String? cityCode;

  @override
  String get baseUrl => ApiConfig.baseUrl;

  @override
  String get path => '/core-api-me/api/v1/meetingrooms';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters {
    final params = <String, dynamic>{};
    final trimmedCityCode = cityCode?.trim();
    if (trimmedCityCode != null && trimmedCityCode.isNotEmpty) {
      params['cityCode'] = trimmedCityCode;
    }
    return params.isEmpty ? null : params;
  }

  @override
  dynamic get body => null;
}

class GetCentresEndpoint implements ApiEndpoint {
  @override
  String get baseUrl => ApiConfig.baseUrl;

  @override
  String get path => '/core-api-me/api/v1/centregroups';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get body => null;
}

class GetCitiesEndpoint implements ApiEndpoint {
  GetCitiesEndpoint({
    this.pageSize,
    this.pageNumber,
  });

  final int? pageSize;
  final int? pageNumber;

  @override
  String get baseUrl => ApiConfig.baseUrl;

  @override
  String get path => '/core-api/api/v1/cities';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  Map<String, String>? get headers => null;

  @override
  Map<String, dynamic>? get queryParameters {
    final params = <String, dynamic>{};
    if (pageSize != null) {
      params['pageSize'] = pageSize;
    }
    if (pageNumber != null) {
      params['pageNumber'] = pageNumber;
    }
    return params.isEmpty ? null : params;
  }

  @override
  dynamic get body => null;
}
