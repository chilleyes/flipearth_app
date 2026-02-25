class Station {
  final String uicCode;
  final String name;
  final String? displayName;
  final String? city;
  final String? countryCode;
  final String? beuropeCode;
  final String? raileuropeCode;
  final bool? isEurostarDirect;
  final bool? isDirect;
  final String? routeType;

  Station({
    required this.uicCode,
    required this.name,
    this.displayName,
    this.city,
    this.countryCode,
    this.beuropeCode,
    this.raileuropeCode,
    this.isEurostarDirect,
    this.isDirect,
    this.routeType,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      uicCode: json['uic_code'] ?? json['uic'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'],
      city: json['city'],
      countryCode: json['country_code'] ?? json['country'],
      beuropeCode: json['beurope_code'],
      raileuropeCode: json['raileurope_code'],
      isEurostarDirect: json['is_eurostar_direct'],
      isDirect: json['is_direct'],
      routeType: json['route_type'],
    );
  }

  String get flag {
    final code = countryCode?.toUpperCase() ?? '';
    if (code.length != 2) return '🌍';
    final base = 0x1F1E6;
    final first = code.codeUnitAt(0) - 0x41 + base;
    final second = code.codeUnitAt(1) - 0x41 + base;
    return String.fromCharCodes([first, second]);
  }
}

class RouteCheckResult {
  final bool valid;
  final String? message;
  final String? origin;
  final String? destination;
  final bool? isDirect;
  final String? routeType;
  final String? duration;

  RouteCheckResult({
    required this.valid,
    this.message,
    this.origin,
    this.destination,
    this.isDirect,
    this.routeType,
    this.duration,
  });

  factory RouteCheckResult.fromJson(Map<String, dynamic> json) {
    final route = json['route'] as Map<String, dynamic>?;
    return RouteCheckResult(
      valid: json['valid'] ?? false,
      message: json['message'],
      origin: route?['origin'],
      destination: route?['destination'],
      isDirect: route?['is_direct'],
      routeType: route?['route_type'],
      duration: route?['duration'],
    );
  }
}
