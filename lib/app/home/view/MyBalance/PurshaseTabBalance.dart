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
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D8F),
        ),
      );
    }

    // If there's an error
    if (balanceController.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load purchases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              balanceController.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => balanceController.fetchPurchases(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D8F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // If we have data
    final purchaseItems = balanceController.purchases;
    if (purchaseItems.isEmpty) {
      // No data, no error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No Purchases Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your purchase history will appear here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Build the ListView of purchases
    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type and price
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D8F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(itemType),
                      color: const Color(0xFF2E7D8F),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          itemTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${price.toStringAsFixed(2)} EGP",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D8F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${(price + discount).toStringAsFixed(2)} EGP",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${net.toStringAsFixed(2)} EGP",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (branch.isNotEmpty) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Branch',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            branch,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    createdAt,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  });
}

IconData _getTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'session':
      return Icons.medical_services_outlined;
    case 'appointment':
      return Icons.calendar_today_outlined;
    case 'treatment':
      return Icons.healing_outlined;
    case 'consultation':
      return Icons.person_outline;
    default:
      return Icons.shopping_cart_outlined;
  }
}
