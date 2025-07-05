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
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D8F),
        ),
      );
    }

    // 2) If there's an error
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
              'Unable to load payments',
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
              onPressed: () => balanceController.fetchPayments(),
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

    // 3) If no error, show the data
    final paymentItems = balanceController.payments;
    if (paymentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'No Payments Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment history will appear here',
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

    // 4) Build a Column with an Expanded ListView + total container at bottom
    return Column(
      children: [
        // A) The list of payments
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
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
                    // Header with payment method and amount
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D8F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getPaymentMethodIcon(method),
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
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatPaymentMethod(method),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${value.toStringAsFixed(2)} EGP",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF2E7D8F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Details row
                    Row(
                      children: [
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
          ),
        ),

        // B) The total container at the bottom
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D8F),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Payments',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${balanceController.paymentsTotal.value.toStringAsFixed(2)} EGP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });
}

IconData _getPaymentMethodIcon(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
      return Icons.money_outlined;
    case 'card':
    case 'credit_card':
      return Icons.credit_card_outlined;
    case 'bank_transfer':
    case 'transfer':
      return Icons.account_balance_outlined;
    case 'online':
    case 'digital':
      return Icons.payment_outlined;
    default:
      return Icons.payment_outlined;
  }
}

String _formatPaymentMethod(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
      return 'Cash Payment';
    case 'card':
    case 'credit_card':
      return 'Credit Card';
    case 'bank_transfer':
    case 'transfer':
      return 'Bank Transfer';
    case 'online':
    case 'digital':
      return 'Online Payment';
    default:
      return method.isNotEmpty ? method : 'Payment';
  }
}
