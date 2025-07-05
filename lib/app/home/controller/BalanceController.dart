import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart'; // For refreshAccessToken()

class BalanceController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // The list of purchases from the API.
  // Each purchase is a Map<String,dynamic> with fields:
  // "id", "title", "price", "discount", "net", "type", "branch", "branch_id", "created_at"
  var purchases = <Map<String, dynamic>>[].obs;

  /// Fetch purchases from the API.
  /// On success, we fill [purchases] with the data from the "data->data" array.
  Future<void> fetchPurchases() async {
    try {
      isLoading(true);
      errorMessage('');

      // 1) Get bearer token from your token controller
      String? bearerToken = await getAccessToken();

      // 2) Build the request
      final url = "https://portal.ahmed-hussain.com/api/patient/payment/purchases";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      // 3) Parse the response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true) {
          // The array of purchases is in jsonData["data"]["data"]
          final dataArray = jsonData["data"]["data"] as List<dynamic>;
          purchases.value = dataArray.map((item) {
            return item as Map<String, dynamic>;
          }).toList();
        } else {
          // The API returned a JSON with "status" == false
          errorMessage.value = jsonData["message"] ?? "Unknown error from API.";
        }
      } else {
        // Non-200 status code
        errorMessage.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      print("Exception in fetchPurchases: $e");
    } finally {
      isLoading(false);
    }
  }

  var payments = <Map<String, dynamic>>[].obs;
  var paymentsTotal = 0.0.obs;
  /// Fetch payments from the "patient/payment/paid" API
  Future<void> fetchPayments() async {
    try {
      isLoading(true);
      errorMessage('');
      var bearerToken = await getAccessToken();

      final url = "https://portal.ahmed-hussain.com/api/patient/payment/paid";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true) {
          // The array of payments is in jsonData["data"]["data"]
          final dataArray = jsonData["data"]["data"] as List<dynamic>;
          payments.value = dataArray.map((item) {
            return item as Map<String, dynamic>;
          }).toList();

          // The total is in jsonData["data"]["total"], which might be a string or number
          final totalStr = jsonData["data"]["total"]?.toString() ?? "0";
          final totalVal = double.tryParse(totalStr) ?? 0.0;
          paymentsTotal.value = totalVal;
        } else {
          errorMessage.value = jsonData["message"] ?? "Unknown error from API";
        }
      } else {
        errorMessage.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      print("Exception in fetchPayments: $e");
    } finally {
      isLoading(false);
    }
  }

  // The fields from the /my-account API
  var totalCost = 0.0.obs;
  var totalPaid = 0.0.obs;
  var totalDiscount = 0.0.obs;
  var totalRefund = 0.0.obs;
  var totalUse = 0.0.obs;
  var totalUnused = 0.0.obs;
  var totalUnPaid = 0.0.obs;
  var totalAfterDiscount = 0.0.obs;

  /// Fetch summary info from "https://portal.ahmed-hussain.com/api/patient/profile/my-account"
  /// and store it in the above fields.
  Future<void> fetchSummary() async {
    try {
      isLoading(true);
      errorMessage('');
      final bearerToken = await getAccessToken();

      final url = "https://portal.ahmed-hussain.com/api/patient/profile/my-account";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true) {
          final data = jsonData["data"];
          // Convert to double safely
          totalCost.value = (data["TotalCost"] ?? 0).toDouble();
          totalPaid.value = (data["TotalPaid"] ?? 0).toDouble();
          totalDiscount.value = (data["TotalDiscount"] ?? 0).toDouble();
          totalRefund.value = (data["TotalRefund"] ?? 0).toDouble();
          totalUse.value = (data["TotalUse"] ?? 0).toDouble();
          totalUnused.value = (data["TotalUnused"] ?? 0).toDouble();
          totalUnPaid.value = (data["TotalUnPaid"] ?? 0).toDouble();
          totalAfterDiscount.value = (data["TotalAfterDiscount"] ?? 0).toDouble();
        } else {
          errorMessage.value = jsonData["message"] ?? "Unknown error from API";
        }
      } else {
        errorMessage.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      print("Exception in fetchSummary: $e");
    } finally {
      isLoading(false);
    }
  }
}
