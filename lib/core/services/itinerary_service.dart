import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/itinerary.dart';
import '../models/order.dart';
import 'api_client.dart';

class ItineraryService {
  final ApiClient _api;

  ItineraryService({required ApiClient api}) : _api = api;

  Future<Itinerary> create({
    required String city,
    required String startDate,
    required int days,
    String? country,
    int companionType = 0,
  }) async {
    final response = await _api.dio.post('/itinerary/create', data: {
      'city': city,
      'start_date': startDate,
      'days': days,
      if (country != null) 'country': country,
      'companion_type': companionType,
    });
    final data = _api.extractData(response);
    return Itinerary.fromJson(data);
  }

  Future<Itinerary> getDetail(int id) async {
    final response = await _api.dio.get('/itinerary/$id');
    final data = _api.extractData(response);
    return Itinerary.fromJson(data);
  }

  Future<({List<Itinerary> items, Pagination pagination})> getList({
    int page = 1,
  }) async {
    final response = await _api.dio.get('/itinerary/list', queryParameters: {
      'page': page,
    });
    final data = _api.extractData(response);
    final items =
        (data['items'] as List).map((i) => Itinerary.fromJson(i)).toList();
    final pagination = Pagination.fromJson(data['pagination'] ?? {});
    return (items: items, pagination: pagination);
  }

  Future<Uint8List> downloadPdf(int id) async {
    final response = await _api.dio.get(
      '/itinerary/$id/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data);
  }

  /// Poll itinerary status until completed or error
  Stream<Itinerary> pollUntilReady(
    int id, {
    Duration interval = const Duration(seconds: 4),
    Duration timeout = const Duration(seconds: 120),
  }) {
    final controller = StreamController<Itinerary>();
    final stopwatch = Stopwatch()..start();

    void poll() async {
      try {
        final itinerary = await getDetail(id);
        controller.add(itinerary);
        if (itinerary.isCompleted || itinerary.isError) {
          await controller.close();
          return;
        }
        if (stopwatch.elapsed > timeout) {
          controller.addError('行程生成超时，请稍后查看');
          await controller.close();
          return;
        }
        Future.delayed(interval, poll);
      } catch (e) {
        controller.addError(e);
        controller.close();
      }
    }

    poll();
    return controller.stream;
  }
}
