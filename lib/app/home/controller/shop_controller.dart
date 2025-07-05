// shop_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../auth/controller/token_controller.dart';

class ShopController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // The list of products from the API
  var products = <Map<String, dynamic>>[].obs;

  // For pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  // The list of categories from the API
  var categories = <Map<String, dynamic>>[].obs;

  /// Fetch products from the shop API, optionally using page, product_title, category_id
  Future<void> fetchProducts({
    int page = 1,
    String? productTitle,
    int? categoryId,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      final bearerToken = await getAccessToken();

      // Build query parameters
      final params = {
        "page": page.toString(),
      };
      if (productTitle != null && productTitle.isNotEmpty) {
        params["product_title"] = productTitle;
      }
      if (categoryId != null && categoryId != 0) {
        params["category_id"] = categoryId.toString();
      }

      final query = Uri(queryParameters: params).query;
      final url = "https://portal.ahmed-hussain.com/api/patient/shop/products?$query";

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
          final data = jsonData["data"];
          final dataArr = data["data"] as List<dynamic>;

          // Parse each product
          final List<Map<String, dynamic>> parsedProducts = dataArr.map((item) {
            final mapItem = item as Map<String, dynamic>;

            final double netPrice =
                double.tryParse(mapItem["net"]?.toString() ?? "0") ?? 0;
            final double discountVal =
                double.tryParse(mapItem["discount"]?.toString() ?? "0") ?? 0;
            double? oldP;
            if (discountVal != 0) {
              oldP = double.tryParse(mapItem["price"]?.toString() ?? "0") ?? 0;
            }

            return {
              "id": mapItem["id"],
              "title": mapItem["title"] ?? "",
              "image": mapItem["image"] ?? "",
              "price": netPrice,
              "oldPrice": oldP,
              "can_buy": mapItem["can_buy"] ?? false,

              // If your API returns these, keep them, else remove
              "featured": mapItem["featured"] ?? false,
              "hot": mapItem["hot"] ?? false,
              "new": mapItem["new"] ?? false,
            };
          }).toList();

          products.value = parsedProducts;

          currentPage.value = data["current_page"] ?? 1;
          totalPages.value = data["last_page"] ?? 1;
        } else {
          errorMessage.value = jsonData["message"] ?? "Unknown error from API.";
        }
      } else {
        errorMessage.value = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong!";
      print("Exception in fetchProducts: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Fetch categories from /api/patient/shop/categories
  /// Each category is { "id": <int>, "title": <String> }
  Future<void> fetchCategories() async {
    try {
      final bearerToken = await getAccessToken();
      final url = "https://portal.ahmed-hussain.com/api/patient/shop/categories";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["status"] == true && jsonData["data"] != null) {
          final catArr = jsonData["data"] as List<dynamic>;
          categories.value = catArr.map((c) {
            final mapC = c as Map<String, dynamic>;
            return {
              "id": mapC["id"],
              "title": mapC["title"] ?? "",
            };
          }).toList();
        }
      }
    } catch (e) {
      print("Exception in fetchCategories: $e");
    }
  }

  /// Send the cart items to the /api/patient/shop/store endpoint.
  /// cartItems should be a list of maps like:
  ///   [ { "product": <map>, "quantity": <int> }, ... ]
  /// We'll transform them into { "products": [ { "id": x, "qty": y }, ... ] }
  Future<String> storeOrder(List<Map<String, dynamic>> cartItems) async {
    try {
      isLoading(true);
      errorMessage('');

      // 1) Get the bearer token
      final bearerToken = await getAccessToken();

      // 2) Build the "products" array
      final List<Map<String, dynamic>> productList = cartItems.map((item) {
        final product = item["product"] as Map<String, dynamic>;
        final quantity = item["quantity"] as int;
        final productId = product["id"] as int; // Make sure your product has "id"
        return {
          "id": productId,
          "qty": quantity,
        };
      }).toList();

      // 3) Convert to JSON
      final body = json.encode({"products": productList});

      // 4) POST request
      final url = "https://portal.ahmed-hussain.com/api/patient/shop/store";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json",
        },
        body: body,
      );

      // 5) Parse response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final msg = jsonData["message"] ?? "Order Created!";
        return msg; // Return the message
      } else {
        // On error, return something like "Error: 400"
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      return "Exception: $e";
    } finally {
      isLoading(false);
    }
  }
}
