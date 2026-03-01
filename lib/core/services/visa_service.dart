import 'package:dio/dio.dart';
import '../models/visa_export.dart';
import 'api_client.dart';

class VisaService {
  final ApiClient _api;

  VisaService({required ApiClient api}) : _api = api;

  /// POST /trips/:tripId/visa-export — create a visa export request
  Future<VisaExportResult> createExport(int tripId, Map<String, dynamic> input) async {
    try {
      final response = await _api.dio.post('/trips/$tripId/visa-export', data: input);
      final data = _api.extractData(response);
      return VisaExportResult.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// GET /visa-exports/:id — fetch export status and download info
  Future<VisaExportResult> getExport(int exportId) async {
    try {
      final response = await _api.dio.get('/visa-exports/$exportId');
      final data = _api.extractData(response);
      return VisaExportResult.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Build the full download URL for a given export id.
  /// The caller can open this URL with url_launcher or download via Dio.
  String getDownloadUrl(int exportId) {
    return '${_api.dio.options.baseUrl}/visa-exports/$exportId/download';
  }
}
