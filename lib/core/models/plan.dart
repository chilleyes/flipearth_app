class PlanInput {
  final String departureCity;
  final String? departureStationUic;
  final DateTime startDate;
  final int days;
  final int passengers;
  final List<String>? targetCities;
  final String budgetLevel;
  final String pace;
  final List<String>? tags;
  final bool needVisaItinerary;

  PlanInput({
    required this.departureCity,
    this.departureStationUic,
    required this.startDate,
    required this.days,
    required this.passengers,
    this.targetCities,
    required this.budgetLevel,
    required this.pace,
    this.tags,
    required this.needVisaItinerary,
  });

  Map<String, dynamic> toJson() => {
        'departure_city': departureCity,
        'departure_station_uic': departureStationUic,
        'start_date': "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        'days': days,
        'passengers': passengers,
        'target_cities': targetCities,
        'budget_level': budgetLevel,
        'pace': pace,
        'tags': tags,
        'need_visa_itinerary': needVisaItinerary,
      };
}

class PlanOption {
  final int id;
  final String optionKey;
  final String labelText;
  final int totalDays;
  final double estimatedTotalPrice;
  final String currency;
  final String? riskLevel;
  final String? reason;
  // TODO: Add detailed option JSON model later
  // final List<dynamic> optionJson;

  PlanOption({
    required this.id,
    required this.optionKey,
    required this.labelText,
    required this.totalDays,
    required this.estimatedTotalPrice,
    required this.currency,
    this.riskLevel,
    this.reason,
  });

  factory PlanOption.fromJson(Map<String, dynamic> json) => PlanOption(
        id: json['id'],
        optionKey: json['option_key'],
        labelText: json['label_text'],
        totalDays: json['total_days'],
        estimatedTotalPrice: double.parse(json['estimated_total_price']?.toString() ?? '0.0'),
        currency: json['currency'] ?? 'EUR',
        riskLevel: json['risk_level'],
        reason: json['reason'],
      );
}

class PlanResult {
  final int id;
  final String status;
  final List<PlanOption> options;

  PlanResult({
    required this.id,
    required this.status,
    required this.options,
  });

  factory PlanResult.fromJson(Map<String, dynamic> json) => PlanResult(
        id: json['id'],
        status: json['status'],
        options: (json['options'] as List?)?.map((e) => PlanOption.fromJson(e)).toList() ?? [],
      );
}
