import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static const String _devBaseUrl = 'http://api.flipearth.test:8080';
  static const String _prodBaseUrl = 'https://api.flipearth.com';

  static const bool _isProduction = false;

  late final Dio dio;
  final SecureStorageService _storage;

  bool _isRefreshing = false;

  ApiClient({required SecureStorageService storage}) : _storage = storage {
    dio = Dio(BaseOptions(
      baseUrl: (_isProduction ? _prodBaseUrl : _devBaseUrl) + '/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));
  }

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> && data['code'] != 0) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: data['message'] ?? 'Unknown error',
        ),
      );
      return;
    }
    handler.next(response);
  }

  Future<void> _onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['code'] == 401 && !_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshResponse = await dio.post('/auth/refresh');
          final refreshData = refreshResponse.data['data'];
          if (refreshData != null) {
            await _storage.saveToken(
              refreshData['access_token'],
              refreshData['expires_in'] ?? 604800,
            );
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] =
                'Bearer ${refreshData['access_token']}';
            final retryResponse = await dio.fetch(retryOptions);
            _isRefreshing = false;
            handler.resolve(retryResponse);
            return;
          }
        } catch (_) {
          await _storage.clearToken();
        }
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  /// Extract [data] field from standard API response
  dynamic extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return body['data'];
    }
    return body;
  }

  /// Get the error message from a DioException
  static String getErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'];
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请稍后重试';
      case DioExceptionType.connectionError:
        return '无法连接到服务器';
      default:
        return e.message ?? '请求失败，请稍后重试';
    }
  }
}
