import '../models/station.dart';
import 'api_client.dart';

class StationService {
  final ApiClient _api;

  StationService({required ApiClient api}) : _api = api;

  Future<List<Station>> autocomplete(String query, {int limit = 10}) async {
    if (query.length < 2) return [];
    final response = await _api.dio.get('/stations/autocomplete', queryParameters: {
      'q': query,
      'limit': limit,
    });
    final data = _api.extractData(response) as List;
    return data.map((s) => Station.fromJson(s)).toList();
  }

  Future<List<Station>> getPopular({int limit = 22}) async {
    final response = await _api.dio.get('/stations/popular', queryParameters: {
      'limit': limit,
    });
    final data = _api.extractData(response) as List;
    return data.map((s) => Station.fromJson(s)).toList();
  }

  Future<List<Station>> getDestinations(String originUic) async {
    final response = await _api.dio.get('/stations/destinations', queryParameters: {
      'origin': originUic,
    });
    final data = _api.extractData(response) as List;
    return data.map((s) => Station.fromJson(s)).toList();
  }

  Future<RouteCheckResult> checkRoute(String originUic, String destinationUic) async {
    final response = await _api.dio.get('/stations/check-route', queryParameters: {
      'origin': originUic,
      'destination': destinationUic,
    });
    final data = _api.extractData(response);
    return RouteCheckResult.fromJson(data);
  }

  Future<List<Station>> getDirectStations() async {
    final response = await _api.dio.get('/stations/direct');
    final data = _api.extractData(response) as List;
    return data.map((s) => Station.fromJson(s)).toList();
  }
}
