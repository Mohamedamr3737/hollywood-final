import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/BalanceController.dart'; // Adjust import as needed

/// Helper to parse the ISO date string (e.g. "2023-10-06T14:50:50.000000Z")
/// into a more readable format like "2023-10-06 02:50 PM"
String parseDateTime(String isoString) {
  try {
    final dateTime = DateTime.parse(isoString);
    // Convert to local time, then format
    final localTime = dateTime.toLocal();
    return DateFormat("yyyy-MM-dd hh:mm a").format(localTime);
  } catch (e) {
    return isoString; // fallback if parsing fails
  }
}

/// Builds the Payments tab, which shows a list of payments + a total at the bottom.
Widget buildPaymentsTab() {
  final balanceController = Get.find<BalanceController>();

  return Obx(() {
    // 1) If loading, show a spinner
    if (balanceController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2) If there's an error
    if (balanceController.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          balanceController.errorMessage.value,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    // 3) If no error, show the data
    final paymentItems = balanceController.payments;
    if (paymentItems.isEmpty) {
      return const Center(
        child: Text("No Payments Found", style: TextStyle(fontSize: 16)),
      );
    }

    // 4) Build a Column with an Expanded ListView + total container at bottom
    return Column(
      children: [
        // A) The list of payments
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: paymentItems.length,
            itemBuilder: (context, index) {
              final payItem = paymentItems[index];
              final method = payItem["method"] ?? "";
              final valueStr = payItem["value"]?.toString() ?? "0";
              final branch = payItem["branch"] ?? "";
              final createdAtRaw = payItem["created_at"] ?? "";

              // parse numeric value
              final value = double.tryParse(valueStr) ?? 0.0;
              // parse date/time
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
                    // Payment method (e.g. "cash")
                    Text(
                      method,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // cost + branch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${value.toStringAsFixed(2)} EGP",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          branch,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // date/time
                    Text(
                      createdAt,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // B) The total container at the bottom
        Container(
          color: Colors.black87,
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Text(
            "Total: ${balanceController.paymentsTotal.value.toStringAsFixed(2)} EGP",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  });
}
