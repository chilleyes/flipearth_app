import '../models/traveler.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _api;

  UserService({required ApiClient api}) : _api = api;

  Future<List<Traveler>> getTravelers() async {
    final response = await _api.dio.get('/user/travelers');
    final data = _api.extractData(response) as List;
    return data.map((t) => Traveler.fromJson(t)).toList();
  }

  Future<Traveler> addTraveler(Map<String, dynamic> travelerData) async {
    final response = await _api.dio.post('/user/travelers', data: travelerData);
    final data = _api.extractData(response);
    return Traveler.fromJson(data);
  }

  Future<Traveler> updateTraveler(int id, Map<String, dynamic> travelerData) async {
    final response = await _api.dio.put('/user/travelers/$id', data: travelerData);
    final data = _api.extractData(response);
    return Traveler.fromJson(data);
  }

  Future<void> deleteTraveler(int id) async {
    await _api.dio.delete('/user/travelers/$id');
  }
}
