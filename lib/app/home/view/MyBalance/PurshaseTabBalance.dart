// purchase_tab_balance.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/BalanceController.dart'; // Adjust the import path as needed

/// A helper function to parse ISO date strings (e.g. "2024-03-24T05:24:06.000000Z")
/// into a more readable format, e.g. "2024-03-24 05:24 AM".
String parseDateTime(String isoString) {
  try {
    final dateTime = DateTime.parse(isoString);
    // Convert to local time if you want, then format:
    final localTime = dateTime.toLocal();
    return DateFormat("yyyy-MM-dd hh:mm a").format(localTime);
  } catch (e) {
    // If parsing fails, return the raw string
    return isoString;
  }
}

/// A widget that displays the list of purchases from the BalanceController.
///
/// Make sure [BalanceController] is instantiated and fetchPurchases() is called
/// somewhere (e.g. in your MyBalancePage).
Widget buildPurchaseTab() {
  // Retrieve the existing BalanceController from Get
  final balanceController = Get.find<BalanceController>();

  return Obx(() {
    // If the controller is currently loading data
    if (balanceController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    // If there's an error
    if (balanceController.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          balanceController.errorMessage.value,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    // If we have data
    final purchaseItems = balanceController.purchases;
    if (purchaseItems.isEmpty) {
      // No data, no error
      return const Center(
        child: Text(
          "No Purchases Found",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Build the ListView of purchases
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchaseItems.length,
      itemBuilder: (context, index) {
        final item = purchaseItems[index];

        // Safely parse fields from the API
        final itemTitle = item["title"] ?? "";
        final itemType = item["type"] ?? "";
        final itemPriceStr = item["price"] ?? "0";
        final itemDiscountStr = item["discount"] ?? "0";
        final itemNetStr = item["net"] ?? "0";
        final branch = item["branch"] ?? "";
        final createdAtRaw = item["created_at"] ?? "";

        // Convert numeric strings to doubles
        final price = double.tryParse(itemPriceStr) ?? 0;
        final discount = double.tryParse(itemDiscountStr) ?? 0;
        final net = double.tryParse(itemNetStr) ?? 0;

        // Parse the date/time
        final createdAt = parseDateTime(createdAtRaw);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.orange[300],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // e.g. "Session" or "Appointment"
              Text(
                itemType,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Title + Price + optional discount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    itemTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Price + discount if discount > 0
                  Row(
                    children: [
                      Text(
                        "${price.toStringAsFixed(2)} EGP",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          // Original price might be price + discount, or item["price"] if net was calculated
                          // Let's assume "price + discount" is the original
                          "${(price + discount).toStringAsFixed(2)} EGP",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Net + Branch + Date
              Text(
                "Net: ${net.toStringAsFixed(2)} EGP",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                branch,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                createdAt,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        );
      },
    );
  });
}
