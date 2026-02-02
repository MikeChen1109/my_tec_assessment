import 'dart:math';

import '../entities/centre.dart';
import '../entities/city.dart';

class CityDiscoveryUseCase {
  const CityDiscoveryUseCase();

  List<Centre> centresForCityCode({
    required List<Centre> centres,
    required String cityCode,
  }) {
    return _centresByCityCode(centres, cityCode);
  }

  City? cityByCode({required List<City> cities, required String cityCode}) {
    return _findCityByCode(cities, cityCode);
  }

  Map<String, List<City>> groupCitiesByRegion({required List<City> cities}) {
    return _groupCitiesByRegion(cities);
  }

  CityDiscoveryResult call({
    required List<City> cities,
    required List<Centre> centres,
    required double userLat,
    required double userLng,
  }) {
    final nearestCentre = _findNearestCentre(centres, userLat, userLng);
    final nearestCity = nearestCentre == null
        ? null
        : _findCityByCode(cities, nearestCentre.cityCode);
    final nearestCityCentres = nearestCity == null
        ? const <Centre>[]
        : _centresByCityCode(centres, nearestCity.code);
    final citiesGroupedByRegion = _groupCitiesByRegion(cities);

    return CityDiscoveryResult(
      nearestCity: nearestCity,
      nearestCityCentres: nearestCityCentres,
      citiesGroupedByRegion: citiesGroupedByRegion,
    );
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    final double aValue = a.toDouble();
    final c = 2 * atan2(sqrt(aValue), sqrt(1 - aValue));
    return earthRadiusKm * c;
  }

  Centre? _findNearestCentre(
    List<Centre> centres,
    double userLat,
    double userLng,
  ) {
    Centre? nearest;
    var nearestDistance = double.infinity;
    for (final centre in centres) {
      if (!_isEligibleCentre(centre)) {
        continue;
      }
      final coords = centre.mapboxCoordinates;
      if (coords == null) {
        continue;
      }
      final distance = _haversineKm(
        userLat,
        userLng,
        coords.latitude,
        coords.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = centre;
      }
    }
    return nearest;
  }

  City? _findCityByCode(List<City> cities, String cityCode) {
    if (cityCode.isEmpty) {
      return null;
    }
    for (final city in cities) {
      if (city.code == cityCode) {
        return city;
      }
    }
    return null;
  }

  Map<String, List<City>> _groupCitiesByRegion(List<City> cities) {
    final grouped = <String, List<City>>{};
    for (final city in cities) {
      final regionName = city.region.name['en'];
      final key = (regionName == null || regionName.isEmpty)
          ? 'Other'
          : regionName;
      grouped.putIfAbsent(key, () => <City>[]).add(city);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        return a.name.compareTo(b.name);
      });
    }

    return grouped;
  }

  List<Centre> _centresByCityCode(List<Centre> centres, String cityCode) {
    if (cityCode.isEmpty) {
      return const [];
    }
    final filtered = centres
        .where((centre) => centre.cityCode == cityCode)
        .where(_isEligibleCentre)
        .toList();

    filtered.sort((a, b) {
      final nameA = a.localizedName.en ?? '';
      final nameB = b.localizedName.en ?? '';
      return nameA.compareTo(nameB);
    });

    return filtered;
  }

  bool _isEligibleCentre(Centre centre) {
    if (centre.isDeleted) {
      return false;
    }
    return true;
  }

  double _toRadians(double degrees) => degrees * (pi / 180.0);
}

class CityDiscoveryResult {
  const CityDiscoveryResult({
    required this.nearestCity,
    required this.nearestCityCentres,
    required this.citiesGroupedByRegion,
  });

  final City? nearestCity;
  final List<Centre> nearestCityCentres;
  final Map<String, List<City>> citiesGroupedByRegion;
}
