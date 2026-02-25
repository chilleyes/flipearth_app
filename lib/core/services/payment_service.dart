import 'dart:async';
import '../models/booking.dart';
import 'api_client.dart';

class PaymentService {
  final ApiClient _api;

  PaymentService({required ApiClient api}) : _api = api;

  Future<StripeIntentResult> createStripeIntent(String ref) async {
    final response = await _api.dio.post('/payment/create-stripe-intent', data: {
      'ref': ref,
    });
    final data = _api.extractData(response);
    return StripeIntentResult.fromJson(data);
  }

  Future<QrPaymentResult> generateQr({
    required String ref,
    required String paymentMethod,
  }) async {
    final response = await _api.dio.post('/payment/generate-qr', data: {
      'ref': ref,
      'payment_method': paymentMethod,
    });
    final data = _api.extractData(response);
    return QrPaymentResult.fromJson(data);
  }

  Future<String> checkStatus(String ref) async {
    final response = await _api.dio.get('/payment/check-status', queryParameters: {
      'ref': ref,
    });
    final data = _api.extractData(response);
    return data['payment_status'] ?? 'unknown';
  }

  /// Poll payment status every [interval] until paid, completed, or [timeout]
  Stream<String> pollStatus(
    String ref, {
    Duration interval = const Duration(seconds: 3),
    Duration timeout = const Duration(seconds: 60),
  }) {
    final controller = StreamController<String>();
    final stopwatch = Stopwatch()..start();

    void poll() async {
      try {
        final status = await checkStatus(ref);
        controller.add(status);
        if (status == 'paid' || status == '4' || status == 'completed') {
          await controller.close();
          return;
        }
        if (stopwatch.elapsed > timeout) {
          controller.addError('支付状态查询超时');
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
