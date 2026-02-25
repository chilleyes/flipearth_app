class Itinerary {
  final int id;
  final String? orderId;
  final String city;
  final String? country;
  final int days;
  final String startDate;
  final String endDate;
  final String status;
  final int? orderStatus;
  final String? createdAt;
  final List<ItineraryDay>? itinerary;

  Itinerary({
    required this.id,
    this.orderId,
    required this.city,
    this.country,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.orderStatus,
    this.createdAt,
    this.itinerary,
  });

  bool get isCompleted => status == 'completed';
  bool get isGenerating => status == 'generating' || status == 'processing';
  bool get isError => status == 'error';

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] ?? 0,
      orderId: json['order_id'],
      city: json['city'] ?? '',
      country: json['country'],
      days: json['days'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? 'unknown',
      orderStatus: json['order_status'],
      createdAt: json['created_at'],
      itinerary: json['itinerary'] != null
          ? (json['itinerary'] as List)
              .map((d) => ItineraryDay.fromJson(d))
              .toList()
          : null,
    );
  }
}

class ItineraryDay {
  final int day;
  final String date;
  final String city;
  final List<ItineraryActivity> activities;

  ItineraryDay({
    required this.day,
    required this.date,
    required this.city,
    required this.activities,
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      day: json['day'] ?? 0,
      date: json['date'] ?? '',
      city: json['city'] ?? '',
      activities: (json['activities'] as List?)
              ?.map((a) => ItineraryActivity.fromJson(a))
              .toList() ??
          [],
    );
  }
}

class ItineraryActivity {
  final String time;
  final String activity;
  final String? details;
  final String? transportation;

  ItineraryActivity({
    required this.time,
    required this.activity,
    this.details,
    this.transportation,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      time: json['time'] ?? '',
      activity: json['activity'] ?? '',
      details: json['details'],
      transportation: json['transportation'],
    );
  }
}
