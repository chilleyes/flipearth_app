class TripSummary {
  final int id;
  final String title;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double estimatedTotalPrice;
  final String currency;
  final int totalSegments;
  final int bookedSegments;
  final bool? canExportVisa;

  TripSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.estimatedTotalPrice,
    required this.currency,
    required this.totalSegments,
    required this.bookedSegments,
    this.canExportVisa,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) => TripSummary(
        id: json['id'],
        title: json['title'],
        status: json['status'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        totalDays: json['total_days'],
        estimatedTotalPrice: double.parse(json['estimated_total_price']?.toString() ?? '0.0'),
        currency: json['currency'] ?? 'EUR',
        totalSegments: json['total_segments'] ?? 0,
        bookedSegments: json['booked_segments'] ?? 0,
        canExportVisa: json['can_export_visa'],
      );
}

class TripStay {
  final int id;
  final int stayOrder;
  final String city;
  final String? country;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final bool isOptional;
  final String? accommodationName;

  TripStay({
    required this.id,
    required this.stayOrder,
    required this.city,
    this.country,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.isOptional,
    this.accommodationName,
  });

  factory TripStay.fromJson(Map<String, dynamic> json) => TripStay(
        id: json['id'],
        stayOrder: json['stay_order'],
        city: json['city'],
        country: json['country'],
        checkInDate: DateTime.parse(json['check_in_date']),
        checkOutDate: DateTime.parse(json['check_out_date']),
        nights: json['nights'],
        isOptional: json['is_optional'] ?? false,
        accommodationName: json['accommodation_name'],
      );
}

class TripSegment {
  final int id;
  final int segmentOrder;
  final DateTime departureDate;
  final String fromCity;
  final String toCity;
  final String? fromStationName;
  final String? fromStationUic;
  final String? toStationName;
  final String? toStationUic;
  final String? estimatedDuration;
  final double? estimatedPrice;
  final String currency;
  final String? riskLevel;
  final String? riskNote;
  final String status;
  final bool isBookable;
  final String? bookingReference;

  TripSegment({
    required this.id,
    required this.segmentOrder,
    required this.departureDate,
    required this.fromCity,
    required this.toCity,
    this.fromStationName,
    this.fromStationUic,
    this.toStationName,
    this.toStationUic,
    this.estimatedDuration,
    this.estimatedPrice,
    required this.currency,
    this.riskLevel,
    this.riskNote,
    required this.status,
    required this.isBookable,
    this.bookingReference,
  });

  factory TripSegment.fromJson(Map<String, dynamic> json) => TripSegment(
        id: json['id'],
        segmentOrder: json['segment_order'],
        departureDate: DateTime.parse(json['departure_date']),
        fromCity: json['from_city'],
        toCity: json['to_city'],
        fromStationName: json['from_station_name'],
        fromStationUic: json['from_station_uic'],
        toStationName: json['to_station_name'],
        toStationUic: json['to_station_uic'],
        estimatedDuration: json['estimated_duration'],
        estimatedPrice: json['estimated_price'] != null ? double.parse(json['estimated_price'].toString()) : null,
        currency: json['currency'] ?? 'EUR',
        riskLevel: json['risk_level'],
        riskNote: json['risk_note'],
        status: json['status'],
        isBookable: json['is_bookable'] ?? true,
        bookingReference: json['booking_reference'],
      );
}

class TripDetail {
  final int id;
  final String title;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double estimatedTotalPrice;
  final String currency;
  final List<TripStay> stays;
  final List<TripSegment> segments;

  TripDetail({
    required this.id,
    required this.title,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.estimatedTotalPrice,
    required this.currency,
    required this.stays,
    required this.segments,
  });

  factory TripDetail.fromJson(Map<String, dynamic> json) => TripDetail(
        id: json['id'],
        title: json['title'],
        status: json['status'],
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        totalDays: json['total_days'],
        estimatedTotalPrice: double.parse(json['estimated_total_price']?.toString() ?? '0.0'),
        currency: json['currency'] ?? 'EUR',
        stays: (json['stays'] as List?)?.map((e) => TripStay.fromJson(e)).toList() ?? [],
        segments: (json['segments'] as List?)?.map((e) => TripSegment.fromJson(e)).toList() ?? [],
      );
}
