import '../../domain/entities/centre.dart';

class CentreModel extends Centre {
  const CentreModel({
    required super.id,
    required super.country,
    required super.cityId,
    required super.cityCode,
    required super.citySlug,
    required super.displayEmail,
    required super.displayPhone,
    required super.centreCodesForVoCwCheckout,
    required super.amenities,
    required super.centreHighlights,
    required super.centreSchedule,
    required super.displayAddress,
    required super.displayAddressWithLevel,
    required super.localizedName,
    required super.slug,
    required super.status,
    required super.mapboxCoordinates,
    required super.isDeleted,
  });

  factory CentreModel.fromJson(Map<String, dynamic> json) {
    final mapboxJson =
        json['mapboxCoordinates'] as Map<String, dynamic>? ?? const {};
    final mapboxLat = mapboxJson['latitude'] as num?;
    final mapboxLng = mapboxJson['longitude'] as num?;
    return CentreModel(
      id: json['id'] as String? ?? '',
      country: json['country'] as String? ?? '',
      cityId: json['cityId'] as String? ?? '',
      cityCode: json['cityCode'] as String? ?? '',
      citySlug: json['citySlug'] as String? ?? '',
      displayEmail: json['displayEmail'] as String? ?? '',
      displayPhone: json['displayPhone'] as String? ?? '',
      centreCodesForVoCwCheckout:
          ((json['newCentreCodesForMtCore'] ??
                      json['centreCodesForVoCwCheckout'])
                  as List<dynamic>? ??
              const [])
          .map((item) => item.toString())
          .toList(),
      amenities: (json['amenities'] as Map<String, dynamic>? ?? const {}),
      centreHighlights:
          (json['centreHighlights'] as Map<String, dynamic>? ?? const {}),
      centreSchedule:
          (json['centreSchedule'] as Map<String, dynamic>? ?? const {}),
      displayAddress: _parseStringMap(json['displayAddress']),
      displayAddressWithLevel: _parseStringMap(json['displayAddressWithLevel']),
      localizedName: LocalizedNameModel.fromJson(
        json['localizedName'] as Map<String, dynamic>? ?? const {},
      ),
      slug: json['slug'] as String? ?? '',
      status: json['status'] as String? ?? '',
      mapboxCoordinates:
          (mapboxJson.isEmpty || mapboxLat == null || mapboxLng == null)
              ? null
              : CentreMapboxCoordinatesModel.fromJson(mapboxJson),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final mapboxJson = mapboxCoordinates is CentreMapboxCoordinatesModel
        ? (mapboxCoordinates as CentreMapboxCoordinatesModel).toJson()
        : mapboxCoordinates == null
            ? null
            : {
                'latitude': mapboxCoordinates?.latitude,
                'longitude': mapboxCoordinates?.longitude,
              };
    return {
      'id': id,
      'country': country,
      'cityId': cityId,
      'cityCode': cityCode,
      'citySlug': citySlug,
      'displayEmail': displayEmail,
      'displayPhone': displayPhone,
      'newCentreCodesForMtCore': centreCodesForVoCwCheckout,
      'amenities': amenities,
      'centreHighlights': centreHighlights,
      'centreSchedule': centreSchedule,
      'displayAddress': displayAddress,
      'displayAddressWithLevel': displayAddressWithLevel,
      'localizedName': LocalizedNameModel.fromEntity(localizedName).toJson(),
      'slug': slug,
      'status': status,
      'mapboxCoordinates': mapboxJson,
      'isDeleted': isDeleted,
    };
  }

  static Map<String, String?> _parseStringMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, entry) => MapEntry(
          key.toString(),
          entry.toString(),
        ),
      );
    }
    return const {};
  }
}

class LocalizedNameModel extends LocalizedName {
  const LocalizedNameModel({
    required super.en,
    required super.jp,
    required super.kr,
    required super.zhHans,
    required super.zhHant,
  });

  factory LocalizedNameModel.fromJson(Map<String, dynamic> json) {
    return LocalizedNameModel(
      en: json['en']?.toString(),
      jp: json['jp']?.toString(),
      kr: json['kr']?.toString(),
      zhHans: json['zhHans']?.toString(),
      zhHant: json['zhHant']?.toString(),
    );
  }

  factory LocalizedNameModel.fromEntity(LocalizedName entity) {
    if (entity is LocalizedNameModel) {
      return entity;
    }
    return LocalizedNameModel(
      en: entity.en,
      jp: entity.jp,
      kr: entity.kr,
      zhHans: entity.zhHans,
      zhHant: entity.zhHant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'jp': jp,
      'kr': kr,
      'zhHans': zhHans,
      'zhHant': zhHant,
    };
  }
}

class CentreMapboxCoordinatesModel extends CentreMapboxCoordinates {
  const CentreMapboxCoordinatesModel({
    required super.latitude,
    required super.longitude,
  });

  factory CentreMapboxCoordinatesModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CentreMapboxCoordinatesModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
