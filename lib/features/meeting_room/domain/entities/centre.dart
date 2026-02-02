class Centre {
  const Centre({
    required this.id,
    required this.country,
    required this.cityId,
    required this.cityCode,
    required this.citySlug,
    required this.displayEmail,
    required this.displayPhone,
    required this.centreCodesForVoCwCheckout,
    required this.amenities,
    required this.centreHighlights,
    required this.centreSchedule,
    required this.displayAddress,
    required this.displayAddressWithLevel,
    required this.localizedName,
    required this.slug,
    required this.status,
    required this.mapboxCoordinates,
    required this.isDeleted,
  });

  final String id;
  final String country;
  final String cityId;
  final String cityCode;
  final String citySlug;
  final String displayEmail;
  final String displayPhone;
  final List<String> centreCodesForVoCwCheckout;
  final Map<String, dynamic> amenities;
  final Map<String, dynamic> centreHighlights;
  final Map<String, dynamic> centreSchedule;
  final Map<String, String?> displayAddress;
  final Map<String, String?> displayAddressWithLevel;
  final LocalizedName localizedName;
  final String slug;
  final String status;
  final CentreMapboxCoordinates? mapboxCoordinates;
  final bool isDeleted;
}

class CentreMapboxCoordinates {
  const CentreMapboxCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class LocalizedName {
  const LocalizedName({
    required this.en,
    required this.jp,
    required this.kr,
    required this.zhHans,
    required this.zhHant,
  });

  final String? en;
  final String? jp;
  final String? kr;
  final String? zhHans;
  final String? zhHant;
}
