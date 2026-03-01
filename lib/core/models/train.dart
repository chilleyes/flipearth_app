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
  final double? originalPrice;
  final String currency;
  final String availability;
  final String? discountSource;
  final String? offerId;

  TrainPriceOption({
    required this.price,
    this.originalPrice,
    required this.currency,
    required this.availability,
    this.discountSource,
    this.offerId,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > 0 && price < originalPrice!;

  factory TrainPriceOption.fromJson(Map<String, dynamic> json) {
    return TrainPriceOption(
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice']).toDouble()
          : null,
      currency: json['currency'] ?? 'EUR',
      availability: json['availability'] ?? 'none',
      discountSource: json['discountSource'],
      offerId: json['offerId'],
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

    final rawPrices = json['prices'] as Map<String, dynamic>? ?? {};
    final rawDiscount = json['discountPrices'] as Map<String, dynamic>? ?? {};
    final rawSources = json['discountSources'] as Map<String, dynamic>? ?? {};
    final rawOfferIds = json['offerIds'] as Map<String, dynamic>? ?? {};

    final allKeys = <String>{...rawPrices.keys, ...rawDiscount.keys};

    for (final key in allKeys) {
      final official = _parseDouble(rawPrices[key]);
      final discount = _parseDouble(rawDiscount[key]);
      final source = rawSources[key]?.toString();
      final ofId = rawOfferIds[key]?.toString();

      if (official == null && discount == null) continue;

      double bestPrice;
      double? origPrice;

      if (discount != null && official != null && discount < official) {
        bestPrice = discount;
        origPrice = official;
      } else {
        bestPrice = official ?? discount ?? 0;
        origPrice = null;
      }

      pricesMap[key] = TrainPriceOption(
        price: bestPrice,
        originalPrice: origPrice,
        currency: 'EUR',
        availability: json['seats']?.toString() ?? 'available',
        discountSource: source,
        offerId: ofId,
      );
    }

    final List<TrainSegment> parsedSegments = (json['segments'] as List?)
            ?.map((s) => TrainSegment.fromJson(s))
            .toList() ??
        [];

    TrainStation? originStation;
    TrainStation? destStation;
    if (json['origin'] is Map<String, dynamic>) {
      originStation = TrainStation.fromJson(json['origin']);
    } else if (parsedSegments.isNotEmpty) {
      originStation = TrainStation(
        name: parsedSegments.first.origin,
        uic: parsedSegments.first.origin,
      );
    } else {
      originStation = TrainStation(name: '', uic: '');
    }

    if (json['destination'] is Map<String, dynamic>) {
      destStation = TrainStation.fromJson(json['destination']);
    } else if (parsedSegments.isNotEmpty) {
      destStation = TrainStation(
        name: parsedSegments.last.destination,
        uic: parsedSegments.last.destination,
      );
    } else {
      destStation = TrainStation(name: '', uic: '');
    }

    return TrainResult(
      trainId: json['id'] ?? json['trainId'] ?? '',
      trainNumber: json['trainNumber'] ?? '',
      departureTime: json['dep'] ?? json['departureTime'] ?? '',
      arrivalTime: json['arr'] ?? json['arrivalTime'] ?? '',
      duration: json['duration']?.toString() ?? '',
      origin: originStation,
      destination: destStation,
      isDirect: json['isDirect'] ?? true,
      legCount: json['legCount'] ?? 1,
      segments: parsedSegments,
      prices: pricesMap,
      offerId: (json['offerIds'] != null && json['offerIds'] is Map)
          ? (json['offerIds']['standard'] ?? json['offerId'] ?? '')
          : (json['offerId'] ?? ''),
      searchId: json['reSearchId'] ?? json['searchId'] ?? '',
    );
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
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
    String extractString(dynamic val) {
      if (val is String) return val;
      if (val is Map) return val['name'] ?? val['city'] ?? val['uic'] ?? '';
      return '';
    }

    return TrainSegment(
      origin: extractString(json['origin']),
      destination: extractString(json['destination']),
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
