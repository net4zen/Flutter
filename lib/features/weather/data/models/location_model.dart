/// Represents a geocoded location result from the Open-Meteo Geocoding API.
class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1; // State / province / region
  final String? countryCode;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
    this.countryCode,
  });

  /// Parses a single result entry from the geocoding API JSON response.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'admin1': admin1,
    'country_code': countryCode,
  };

  /// Human-readable subtitle shown in search results, e.g. "Bavaria, Germany".
  String get subtitle {
    final parts = <String>[];
    if (admin1 != null && admin1!.isNotEmpty) parts.add(admin1!);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocationModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LocationModel(name: $name, country: $country)';
}
