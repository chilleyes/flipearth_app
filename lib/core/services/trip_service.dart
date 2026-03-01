import 'package:dio/dio.dart';
import '../models/trip.dart';
import 'api_client.dart';

class TripService {
  final ApiClient _api;

  TripService({required ApiClient api}) : _api = api;

  /// GET /trips — paginated trip list
  Future<({List<TripSummary> items, int total, int currentPage, int lastPage})> getTrips({
    int page = 1,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) params['status'] = status;

      final response = await _api.dio.get('/trips', queryParameters: params);
      final data = _api.extractData(response);

      final items = (data['items'] as List)
          .map((e) => TripSummary.fromJson(e))
          .toList();

      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
      return (
        items: items,
        total: pagination['total'] as int? ?? items.length,
        currentPage: pagination['current_page'] as int? ?? page,
        lastPage: pagination['last_page'] as int? ?? 1,
      );
    } on DioException {
      rethrow;
    }
  }

  /// GET /trips/:id — full trip detail with stays + segments
  Future<TripDetail> getTripDetail(int id) async {
    try {
      final response = await _api.dio.get('/trips/$id');
      final data = _api.extractData(response);
      return TripDetail.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// PUT /trips/:id — lightweight trip update (e.g. adjust stay nights)
  Future<TripDetail> updateTrip(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _api.dio.put('/trips/$id', data: payload);
      final data = _api.extractData(response);
      return TripDetail.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// POST /trips/:id/segments/:segmentId/refresh — refresh a single segment suggestion
  Future<TripDetail> refreshSegment(int tripId, int segmentId) async {
    try {
      final response = await _api.dio.post('/trips/$tripId/segments/$segmentId/refresh');
      final data = _api.extractData(response);
      return TripDetail.fromJson(data);
    } on DioException {
      rethrow;
    }
  }
}
