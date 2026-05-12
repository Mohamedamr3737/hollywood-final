// lib/services/pay_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PayService {
  final String backendBaseUrl;      // e.g. https://api.yourapp.com
  final String paymobPublicKey;     // from Paymob dashboard (public)

  PayService({required this.backendBaseUrl, required this.paymobPublicKey});

  Future<String> createIntentionAndGetClientSecret({
    required double amount,
  }) async {
    final uri = Uri.parse('$backendBaseUrl/patient/online-payment/checkout');//api uri
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,

      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Backend error: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['status'] == true && json['data']?['token'] != null) {
      return json['data']['token'] as String; // client_secret
    }
    // Support alternate shape { ok: true, intention: { client_secret: ... } }
    final ok = json['ok'] == true;
    final alt = ok ? (json['intention']?['client_secret'] as String?) : null;
    if (alt != null) return alt;

    throw Exception('No client secret in response');
  }

  /// Build Unified Checkout URL
  String buildUnifiedCheckoutUrl({required String clientSecret}) {
    // Base Unified Checkout endpoint (public docs show publicKey param;
    // SDK/Elements also require public key + client secret).
    final base = 'https://accept.paymob.com/unifiedcheckout/';
    final params = {
      'publicKey': paymobPublicKey,
      'clientSecret': clientSecret,
    };
    final query = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$base?$query';
  }
}