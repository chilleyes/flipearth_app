import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _api;

  OrderService({required ApiClient api}) : _api = api;

  Future<({List<Order> items, Pagination pagination})> getOrders({
    String? type,
    String? status,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _api.dio.get('/orders', queryParameters: params);
    final data = _api.extractData(response);
    final items =
        (data['items'] as List).map((o) => Order.fromJson(o)).toList();
    final pagination = Pagination.fromJson(data['pagination'] ?? {});
    return (items: items, pagination: pagination);
  }

  Future<TrainOrderDetail> getTrainOrderDetail(String ref) async {
    final response = await _api.dio.get('/orders/train/$ref');
    final data = _api.extractData(response);
    return TrainOrderDetail.fromJson(data);
  }

  Future<void> requestRefund(String ref) async {
    await _api.dio.post('/orders/train/$ref/refund');
  }
}
