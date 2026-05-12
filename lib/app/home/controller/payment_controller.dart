import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:s_medi/general/consts/consts.dart';
import 'package:s_medi/app/auth/controller/token_controller.dart';
import 'package:get/get.dart';
import '../view/payment/paymob_checkout_screen.dart';

class PaymentController extends GetxController {
  var isLoading = false.obs;

  // IMPORTANT: Since your backend uses the V1 API, we MUST use your Iframe ID.
  // Go to your Paymob Dashboard -> Developers -> iframes, and get the ID.
  // Replace this with your actual iframe ID number!
  final String iframeId = "167095";

  Future<void> initiateCheckout(BuildContext context, double amount) async {
    try {
      isLoading(true);
      final bearerToken = await getAccessToken();

      // Call your backend checkout API
      final uri =
          Uri.parse('${ApiConfig.baseUrl}/api/patient/online-payment/checkout');
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Backend error: ${res.body}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;

      if (json['status'] == true && json['data']?['token'] != null) {
        // This is a V1 Payment Token, NOT a Unified Checkout token!
        final String paymentToken = json['data']['token'] as String;

        if (iframeId == "YOUR_IFRAME_ID_HERE") {
          Get.snackbar("Missing Iframe ID",
              "Please put your Iframe ID in PaymentController",
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // Build the V1 Iframe URL
        final String checkoutUrl =
            'https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentToken';

        // Navigate to the WebView
        Get.to(() => PaymobCheckoutScreen(
              checkoutUrl: checkoutUrl,
            ))?.then((isSuccess) {
          if (isSuccess == true) {
            Get.snackbar(
              "Success",
              "Payment was completed successfully!",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else if (isSuccess == false) {
            Get.snackbar(
              "Failed",
              "Payment failed or was cancelled.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
      } else {
        throw Exception('No valid token in response');
      }
    } catch (e) {
      Get.snackbar("Payment Error", e.toString(),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}
