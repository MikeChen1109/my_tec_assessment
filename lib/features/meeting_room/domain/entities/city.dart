class City {
  const City({
    required this.cityId,
    required this.countryId,
    required this.code,
    required this.name,
    required this.timeZone,
    required this.isActive,
    required this.accountEmail,
    required this.currencyIsoCode,
    required this.generalEmail,
    required this.generalPhone,
    required this.meEmail,
    required this.nameTranslation,
    required this.paymentGateway,
    required this.paymentMethod,
    required this.sequence,
    required this.voCwEmail,
    required this.bdGroupEmail,
    required this.region,
  });

  final int cityId;
  final int countryId;
  final String code;
  final String name;
  final CityTimeZone timeZone;
  final bool isActive;
  final String accountEmail;
  final String currencyIsoCode;
  final String generalEmail;
  final String generalPhone;
  final String meEmail;
  final Map<String, String?> nameTranslation;
  final String paymentGateway;
  final String paymentMethod;
  final int sequence;
  final String voCwEmail;
  final String bdGroupEmail;
  final CityRegion region;
}

class CityTimeZone {
  const CityTimeZone({
    required this.displayName,
    required this.standardName,
    required this.baseUtcOffset,
  });

  final String displayName;
  final String standardName;
  final String baseUtcOffset;
}

class CityRegion {
  const CityRegion({
    required this.id,
    required this.name,
  });

  final String id;
  final Map<String, String?> name;
}
