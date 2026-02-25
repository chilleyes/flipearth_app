class Order {
  final String type;
  final String? bookingReference;
  final String status;
  final String? statusLabel;
  final double? price;
  final String? currency;
  final String? origin;
  final String? destination;
  final String? departureTime;
  final String? arrivalTime;
  final String? trainNumber;
  final String? travelClass;
  final bool? isDirect;
  final String? createdAt;

  // Itinerary fields
  final int? id;
  final String? orderId;
  final String? city;
  final int? days;
  final String? startDate;
  final String? endDate;
  final int? orderStatus;

  Order({
    required this.type,
    this.bookingReference,
    required this.status,
    this.statusLabel,
    this.price,
    this.currency,
    this.origin,
    this.destination,
    this.departureTime,
    this.arrivalTime,
    this.trainNumber,
    this.travelClass,
    this.isDirect,
    this.createdAt,
    this.id,
    this.orderId,
    this.city,
    this.days,
    this.startDate,
    this.endDate,
    this.orderStatus,
  });

  bool get isTrain => type == 'train';
  bool get isItinerary => type == 'itinerary';

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      type: json['type'] ?? 'train',
      bookingReference: json['booking_reference'],
      status: (json['status'] ?? '').toString(),
      statusLabel: json['status_label'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      origin: json['origin'],
      destination: json['destination'],
      departureTime: json['departure_time'],
      arrivalTime: json['arrival_time'],
      trainNumber: json['train_number'],
      travelClass: json['travel_class'],
      isDirect: json['is_direct'],
      createdAt: json['created_at'],
      id: json['id'],
      orderId: json['order_id'],
      city: json['city'],
      days: json['days'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      orderStatus: json['order_status'],
    );
  }
}

class TrainOrderDetail {
  final String bookingReference;
  final String status;
  final String? statusLabel;
  final double price;
  final String currency;
  final double? cnyAmount;
  final String? paymentMethod;
  final JourneyDetail journey;
  final List<TravelerInfo> travelers;
  final bool canRefund;
  final RefundData? refundData;
  final String? createdAt;
  final String? paidAt;

  TrainOrderDetail({
    required this.bookingReference,
    required this.status,
    this.statusLabel,
    required this.price,
    required this.currency,
    this.cnyAmount,
    this.paymentMethod,
    required this.journey,
    required this.travelers,
    required this.canRefund,
    this.refundData,
    this.createdAt,
    this.paidAt,
  });

  factory TrainOrderDetail.fromJson(Map<String, dynamic> json) {
    return TrainOrderDetail(
      bookingReference: json['booking_reference'] ?? '',
      status: (json['status'] ?? '').toString(),
      statusLabel: json['status_label'],
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      cnyAmount: json['cny_amount']?.toDouble(),
      paymentMethod: json['payment_method'],
      journey: JourneyDetail.fromJson(json['journey'] ?? {}),
      travelers: (json['travelers'] as List?)
              ?.map((t) => TravelerInfo.fromJson(t))
              .toList() ??
          [],
      canRefund: json['canRefund'] ?? false,
      refundData: json['refundData'] != null
          ? RefundData.fromJson(json['refundData'])
          : null,
      createdAt: json['created_at'],
      paidAt: json['paid_at'],
    );
  }
}

class JourneyDetail {
  final String origin;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final String trainNumber;
  final String travelClass;
  final bool isDirect;
  final int legCount;
  final String? pnr;
  final String? coach;
  final String? seat;
  final List<dynamic> segments;

  JourneyDetail({
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.trainNumber,
    required this.travelClass,
    required this.isDirect,
    required this.legCount,
    this.pnr,
    this.coach,
    this.seat,
    required this.segments,
  });

  factory JourneyDetail.fromJson(Map<String, dynamic> json) {
    return JourneyDetail(
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      trainNumber: json['trainNumber'] ?? '',
      travelClass: json['travelClass'] ?? '',
      isDirect: json['isDirect'] ?? true,
      legCount: json['legCount'] ?? 1,
      pnr: json['pnr'],
      coach: json['coach'],
      seat: json['seat'],
      segments: json['segments'] ?? [],
    );
  }
}

class TravelerInfo {
  final String firstName;
  final String lastName;
  final String type;
  final String title;
  final String? dateOfBirth;
  final bool leadTraveler;
  final String? emailAddress;
  final String? phoneNumber;

  TravelerInfo({
    required this.firstName,
    required this.lastName,
    required this.type,
    required this.title,
    this.dateOfBirth,
    this.leadTraveler = false,
    this.emailAddress,
    this.phoneNumber,
  });

  factory TravelerInfo.fromJson(Map<String, dynamic> json) {
    return TravelerInfo(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      type: json['type'] ?? 'ADULT',
      title: json['title'] ?? 'MR',
      dateOfBirth: json['dateOfBirth'],
      leadTraveler: json['leadTraveler'] ?? false,
      emailAddress: json['emailAddress'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'type': type,
        'title': title,
        'dateOfBirth': dateOfBirth,
        'leadTraveler': leadTraveler,
        'emailAddress': emailAddress,
        'phoneNumber': phoneNumber,
      };
}

class RefundData {
  final double fee;
  final double amount;

  RefundData({required this.fee, required this.amount});

  factory RefundData.fromJson(Map<String, dynamic> json) {
    return RefundData(
      fee: (json['fee'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int totalCount;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasMore => page < totalPages;
}
