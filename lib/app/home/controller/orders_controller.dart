// orders_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';

class OrdersController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// The list of orders from the API
  /// Each order is a Map like:
  /// {
  ///   "id": 73,
  ///   "status": "Completed",
  ///   "total": 3860,
  ///   "created_at": "2025-02-21",
  ///   "items": [
  ///       {
  ///         "id": 1026,
  ///         "title": "...",
  ///         "image": "...",
  ///         "qty": 10,
  ///         "subtotal": "3860",
  ///         ...
  ///       },
  ///       ...
  ///   ]
  /// }
  var orders = <Map<String, dynamic>>[].obs;

  /// Fetch orders from /api/patient/shop/orders
  /// On success, fill [orders] with the data
  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      errorMessage('');

      final bearerToken = await getAccessToken();
      final url = "https://portal.ahmed-hussain.com/api/patient/shop/orders";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {

        final jsonData = json.decode(response.body);
        print(";;;;;;;;;;;;;;;;;;;;");
        print(jsonData);
        if (jsonData["data"] != null) {
          final dataArr = jsonData["data"] as List<dynamic>;
          final parsed = dataArr.map((order) {
            final mapOrder = order as Map<String, dynamic>;
            return {
              "id": mapOrder["id"],
              "qty": mapOrder["qty"] ?? 0,
              "discount": mapOrder["discount"]?.toString() ?? "0.00",
              "subtotal": mapOrder["subtotal"]?.toString() ?? "0.00",
              "total": mapOrder["total"]?.toString() ?? "0.00",
              "status": mapOrder["status"] ?? "Unknown",
              "created_at": mapOrder["created_at"] ?? "",
              // items is a List
              "items": (mapOrder["items"] as List<dynamic>? ?? []).map((item) {
                final mapItem = item as Map<String, dynamic>;
                return {
                  "id": mapItem["id"],
                  "title": mapItem["title"] ?? "",
                  "image": mapItem["image"] ?? "",
                  "qty": mapItem["qty"] ?? 0,
                  "subtotal": mapItem["subtotal"]?.toString() ?? "0.00",
                  "total": mapItem["total"]?.toString() ?? "0.00",
                  "created_at": mapItem["created_at"] ?? "",
                };
              }).toList(),
            };
          }).toList();
          orders.value = parsed;
        } else {
          // No data field? Possibly show an error or an empty list
          orders.clear();
        }
      } else {
        errorMessage.value = "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      errorMessage.value = "Exception: $e";
    } finally {
      isLoading(false);
    }
  }
}
