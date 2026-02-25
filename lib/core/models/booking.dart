class BookingResult {
  final String bookingReference;
  final String bookingId;
  final String itemId;
  final double price;
  final String currency;
  final String status;

  BookingResult({
    required this.bookingReference,
    required this.bookingId,
    required this.itemId,
    required this.price,
    required this.currency,
    required this.status,
  });

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    return BookingResult(
      bookingReference: json['bookingReference'] ?? '',
      bookingId: json['bookingId'] ?? '',
      itemId: json['itemId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
      status: json['status'] ?? '',
    );
  }
}

class PreorderResult {
  final String status;
  final String bookingReference;
  final String? redirectUrl;
  final double price;
  final String currency;

  PreorderResult({
    required this.status,
    required this.bookingReference,
    this.redirectUrl,
    required this.price,
    required this.currency,
  });

  factory PreorderResult.fromJson(Map<String, dynamic> json) {
    return PreorderResult(
      status: json['status'] ?? '',
      bookingReference: json['bookingReference'] ?? '',
      redirectUrl: json['redirectUrl'],
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
    );
  }
}

class CouponResult {
  final bool valid;
  final String? message;
  final String? code;
  final double? value;

  CouponResult({
    required this.valid,
    this.message,
    this.code,
    this.value,
  });

  factory CouponResult.fromJson(Map<String, dynamic> json) {
    final coupon = json['coupon'] as Map<String, dynamic>?;
    return CouponResult(
      valid: json['valid'] ?? false,
      message: json['message'],
      code: coupon?['code'],
      value: coupon?['value']?.toDouble(),
    );
  }
}

class StripeIntentResult {
  final String clientSecret;
  final double amount;
  final String currency;

  StripeIntentResult({
    required this.clientSecret,
    required this.amount,
    required this.currency,
  });

  factory StripeIntentResult.fromJson(Map<String, dynamic> json) {
    return StripeIntentResult(
      clientSecret: json['clientSecret'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EUR',
    );
  }
}

class QrPaymentResult {
  final String action;
  final String? codeUrl;
  final String? redirectHtml;

  QrPaymentResult({
    required this.action,
    this.codeUrl,
    this.redirectHtml,
  });

  factory QrPaymentResult.fromJson(Map<String, dynamic> json) {
    return QrPaymentResult(
      action: json['action'] ?? '',
      codeUrl: json['code_url'],
      redirectHtml: json['redirect_html'],
    );
  }
}
