import '../../domain/entities/city.dart';

class CityModel extends City {
  const CityModel({
    required super.cityId,
    required super.countryId,
    required super.code,
    required super.name,
    required super.timeZone,
    required super.isActive,
    required super.accountEmail,
    required super.currencyIsoCode,
    required super.generalEmail,
    required super.generalPhone,
    required super.meEmail,
    required super.nameTranslation,
    required super.paymentGateway,
    required super.paymentMethod,
    required super.sequence,
    required super.voCwEmail,
    required super.bdGroupEmail,
    required super.region,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final timeZoneJson = json['timeZone'] as Map<String, dynamic>? ?? const {};
    final regionJson = json['region'] as Map<String, dynamic>? ?? const {};

    return CityModel(
      cityId: json['cityId'] as int? ?? 0,
      countryId: json['countryId'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      timeZone: CityTimeZoneModel.fromJson(timeZoneJson),
      isActive: json['isActive'] as bool? ?? false,
      accountEmail: json['accountEmail'] as String? ?? '',
      currencyIsoCode: json['currencyIsoCode'] as String? ?? '',
      generalEmail: json['generalEmail'] as String? ?? '',
      generalPhone: json['generalPhone'] as String? ?? '',
      meEmail: json['meEmail'] as String? ?? '',
      nameTranslation:
          (json['nameTranslation'] as Map<String, dynamic>? ?? const {})
              .map((key, value) => MapEntry(key, value?.toString())),
      paymentGateway: json['paymentGateway'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      sequence: json['sequence'] as int? ?? 0,
      voCwEmail: json['voCwEmail'] as String? ?? '',
      bdGroupEmail: json['bdGroupEmail'] as String? ?? '',
      region: CityRegionModel.fromJson(regionJson),
    );
  }

  Map<String, dynamic> toJson() {
    final timeZoneJson = timeZone is CityTimeZoneModel
        ? (timeZone as CityTimeZoneModel).toJson()
        : {
            'displayName': timeZone.displayName,
            'standardName': timeZone.standardName,
            'baseUtcOffset': timeZone.baseUtcOffset,
          };
    final regionJson = region is CityRegionModel
        ? (region as CityRegionModel).toJson()
        : {
            'id': region.id,
            'name': region.name,
          };
    return {
      'cityId': cityId,
      'countryId': countryId,
      'code': code,
      'name': name,
      'timeZone': timeZoneJson,
      'isActive': isActive,
      'accountEmail': accountEmail,
      'currencyIsoCode': currencyIsoCode,
      'generalEmail': generalEmail,
      'generalPhone': generalPhone,
      'meEmail': meEmail,
      'nameTranslation': nameTranslation,
      'paymentGateway': paymentGateway,
      'paymentMethod': paymentMethod,
      'sequence': sequence,
      'voCwEmail': voCwEmail,
      'bdGroupEmail': bdGroupEmail,
      'region': regionJson,
    };
  }
}

class CityTimeZoneModel extends CityTimeZone {
  const CityTimeZoneModel({
    required super.displayName,
    required super.standardName,
    required super.baseUtcOffset,
  });

  factory CityTimeZoneModel.fromJson(Map<String, dynamic> json) {
    return CityTimeZoneModel(
      displayName: json['displayName'] as String? ?? '',
      standardName: json['standardName'] as String? ?? '',
      baseUtcOffset: json['baseUtcOffset'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'standardName': standardName,
      'baseUtcOffset': baseUtcOffset,
    };
  }
}

class CityRegionModel extends CityRegion {
  const CityRegionModel({
    required super.id,
    required super.name,
  });

  factory CityRegionModel.fromJson(Map<String, dynamic> json) {
    return CityRegionModel(
      id: json['id'] as String? ?? '',
      name: (json['name'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value?.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
