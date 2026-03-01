import 'package:flutter/foundation.dart';
import '../models/train.dart';
import '../models/booking.dart';
import '../models/order.dart';
import 'api_client.dart';

class EurostarService {
  final ApiClient _api;

  EurostarService({required ApiClient api}) : _api = api;

  Future<List<TrainResult>> search({
    String? date,
    String origin = '7015400',
    String destination = '8727100',
    int adults = 1,
    int youth = 0,
    int children = 0,
    int seniors = 0,
    String? couponCode,
  }) async {
    final params = <String, dynamic>{
      'origin': origin,
      'destination': destination,
      'adults': adults,
      'youth': youth,
      'children': children,
      'seniors': seniors,
    };
    if (date != null) params['date'] = date;
    if (couponCode != null && couponCode.isNotEmpty) {
      params['couponCode'] = couponCode;
    }

    final response = await _api.dio.get('/eurostar/search', queryParameters: params);
    final data = _api.extractData(response);
    if (data is List) {
      if (data.isNotEmpty) {
        final first = data.first;
        debugPrint('[Search] first train raw keys: ${(first as Map).keys.toList()}');
        debugPrint('[Search] offerId=${first['offerId']}, offerIds=${first['offerIds']}, searchId=${first['searchId']}, reSearchId=${first['reSearchId']}');
      }
      return data.map((t) => TrainResult.fromJson(t)).toList();
    }
    return [];
  }

  Future<BookingResult> createBooking({
    required String offerId,
    required String searchId,
    required String trainId,
    String? source,
    String travelClass = 'standard',
    String? date,
    int adults = 1,
    int youth = 0,
    int children = 0,
    int seniors = 0,
    String? origin,
    String? destination,
    String? originUic,
    String? destinationUic,
    String? trainNumber,
    String? departureTime,
    String? arrivalTime,
    bool isDirect = true,
    int legCount = 1,
    List<Map<String, dynamic>>? segments,
    String? couponCode,
  }) async {
    final response = await _api.dio.post('/eurostar/booking', data: {
      'offerId': offerId,
      'searchId': searchId,
      'trainId': trainId,
      if (source != null) 'source': source,
      'travelClass': travelClass,
      if (date != null) 'date': date,
      'adults': adults,
      'youth': youth,
      'children': children,
      'seniors': seniors,
      if (origin != null) 'origin': origin,
      if (destination != null) 'destination': destination,
      if (originUic != null) 'originUic': originUic,
      if (destinationUic != null) 'destinationUic': destinationUic,
      if (trainNumber != null) 'trainNumber': trainNumber,
      if (departureTime != null) 'departureTime': departureTime,
      if (arrivalTime != null) 'arrivalTime': arrivalTime,
      'isDirect': isDirect,
      'legCount': legCount,
      'segments': segments ?? [],
      'couponCode': couponCode ?? '',
    });
    final data = _api.extractData(response);
    return BookingResult.fromJson(data);
  }

  Future<PreorderResult> preorder({
    String? bookingId,
    String? itemId,
    required String offerId,
    required String searchId,
    String paymentMethod = 'stripe',
    String? couponCode,
    required List<TravelerInfo> travelers,
  }) async {
    final response = await _api.dio.post('/eurostar/preorder', data: {
      if (bookingId != null) 'bookingId': bookingId,
      if (itemId != null) 'itemId': itemId,
      'offerId': offerId,
      'searchId': searchId,
      'payment_method': paymentMethod,
      'couponCode': couponCode ?? '',
      'travelers': travelers.map((t) => t.toJson()).toList(),
    });
    final data = _api.extractData(response);
    return PreorderResult.fromJson(data);
  }

  Future<CouponResult> validateCoupon(String code) async {
    final response = await _api.dio.post('/eurostar/validate-coupon', data: {
      'code': code,
    });
    final data = _api.extractData(response);
    return CouponResult.fromJson(data);
  }
}
