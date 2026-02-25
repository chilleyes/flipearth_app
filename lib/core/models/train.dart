class TrainStation {
  final String name;
  final String uic;

  TrainStation({required this.name, required this.uic});

  factory TrainStation.fromJson(Map<String, dynamic> json) {
    return TrainStation(
      name: json['name'] ?? '',
      uic: json['uic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'uic': uic};
}

class TrainPriceOption {
  final double price;
  final String currency;
  final String availability;

  TrainPriceOption({
    required this.price,
    required this.currency,
    required this.availability,
  });

  factory TrainPriceOption.fromJson(Map<String, dynamic> json) {
    return TrainPriceOption(
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      availability: json['availability'] ?? 'none',
    );
  }
}

class TrainResult {
  final String trainId;
  final String trainNumber;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final TrainStation origin;
  final TrainStation destination;
  final bool isDirect;
  final int legCount;
  final List<TrainSegment> segments;
  final Map<String, TrainPriceOption> prices;
  final String offerId;
  final String searchId;

  TrainResult({
    required this.trainId,
    required this.trainNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.origin,
    required this.destination,
    required this.isDirect,
    required this.legCount,
    required this.segments,
    required this.prices,
    required this.offerId,
    required this.searchId,
  });

  factory TrainResult.fromJson(Map<String, dynamic> json) {
    final pricesMap = <String, TrainPriceOption>{};
    if (json['prices'] is Map) {
      (json['prices'] as Map<String, dynamic>).forEach((key, value) {
        pricesMap[key] = TrainPriceOption.fromJson(value);
      });
    }

    return TrainResult(
      trainId: json['trainId'] ?? '',
      trainNumber: json['trainNumber'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      duration: json['duration'] ?? '',
      origin: TrainStation.fromJson(json['origin'] ?? {}),
      destination: TrainStation.fromJson(json['destination'] ?? {}),
      isDirect: json['isDirect'] ?? true,
      legCount: json['legCount'] ?? 1,
      segments: (json['segments'] as List?)
              ?.map((s) => TrainSegment.fromJson(s))
              .toList() ??
          [],
      prices: pricesMap,
      offerId: json['offerId'] ?? '',
      searchId: json['searchId'] ?? '',
    );
  }

  double? get cheapestPrice {
    if (prices.isEmpty) return null;
    return prices.values.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  String get cheapestCurrency {
    if (prices.isEmpty) return 'EUR';
    return prices.values.first.currency;
  }
}

class TrainSegment {
  final String origin;
  final String destination;
  final String departure;
  final String arrival;
  final String trainNumber;
  final String serviceType;

  TrainSegment({
    required this.origin,
    required this.destination,
    required this.departure,
    required this.arrival,
    required this.trainNumber,
    required this.serviceType,
  });

  factory TrainSegment.fromJson(Map<String, dynamic> json) {
    return TrainSegment(
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
      trainNumber: json['trainNumber'] ?? '',
      serviceType: json['serviceType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'origin': origin,
        'destination': destination,
        'departure': departure,
        'arrival': arrival,
        'trainNumber': trainNumber,
        'serviceType': serviceType,
      };
}
