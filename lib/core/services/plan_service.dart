import 'package:dio/dio.dart';
import '../models/plan.dart';
import 'api_client.dart';

class PlanService {
  final ApiClient _api;

  PlanService({required ApiClient api}) : _api = api;

  /// POST /plan/create — create an AI travel plan
  Future<PlanResult> createPlan(Map<String, dynamic> input) async {
    try {
      final response = await _api.dio.post('/plan/create', data: input);
      final data = _api.extractData(response);
      return PlanResult.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// GET /plan/:id — fetch plan with options
  Future<PlanResult> getPlan(int id) async {
    try {
      final response = await _api.dio.get('/plan/$id');
      final data = _api.extractData(response);
      return PlanResult.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// POST /plan/:planId/select — select an option, returns the created trip_id
  Future<int> selectPlanOption(int planId, int optionId) async {
    try {
      final response = await _api.dio.post(
        '/plan/$planId/select',
        data: {'option_id': optionId},
      );
      final data = _api.extractData(response);
      return data['trip_id'] as int;
    } on DioException {
      rethrow;
    }
  }
}
