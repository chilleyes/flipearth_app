class AccommodationInfo {
  final int stayId;
  final String name;
  final String address;

  AccommodationInfo({
    required this.stayId,
    required this.name,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'stay_id': stayId,
        'name': name,
        'address': address,
      };

  factory AccommodationInfo.fromJson(Map<String, dynamic> json) => AccommodationInfo(
        stayId: json['stay_id'],
        name: json['name'],
        address: json['address'],
      );
}

class VisaExportDraft {
  final String travelerName;
  final String passportNo;
  final String applicationCountry;
  final List<AccommodationInfo>? accommodations;
  final String? notes;

  VisaExportDraft({
    required this.travelerName,
    required this.passportNo,
    required this.applicationCountry,
    this.accommodations,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'traveler_name': travelerName,
        'passport_no': passportNo,
        'application_country': applicationCountry,
        'accommodations': accommodations?.map((e) => e.toJson()).toList(),
        'notes': notes,
      };
}

class VisaExportResult {
  final int id;
  final int tripId;
  final String status;
  final String travelerName;
  final String passportNo;
  final String applicationCountry;
  final String? pdfPath;
  // TODO: define a detailed representation of export json if needed for preview
  // final Map<String, dynamic> exportJson;

  VisaExportResult({
    required this.id,
    required this.tripId,
    required this.status,
    required this.travelerName,
    required this.passportNo,
    required this.applicationCountry,
    this.pdfPath,
  });

  factory VisaExportResult.fromJson(Map<String, dynamic> json) => VisaExportResult(
        id: json['id'],
        tripId: json['trip_id'],
        status: json['status'],
        travelerName: json['traveler_name'],
        passportNo: json['passport_no'],
        applicationCountry: json['application_country'],
        pdfPath: json['pdf_path'],
      );
}
