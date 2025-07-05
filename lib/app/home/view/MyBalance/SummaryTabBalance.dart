// summary_tab_balance.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/BalanceController.dart';

/// A private stateful widget that shows a small circle
/// which pulses between 70% and 100% opacity.
class _PulsingCircle extends StatefulWidget {
  final bool isNonZero; // If true -> green circle, else -> red circle

  const _PulsingCircle({Key? key, required this.isNonZero}) : super(key: key);

  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // A 1-second animation that repeats, reversing each time.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Tween from 0.7 to 1.0 for the circle's opacity
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isNonZero ? Colors.green : Colors.red;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // The factor goes from 0.7 -> 1.0 -> 0.7 repeatedly
        final factor = _animation.value;
        // We apply that factor as the circle's opacity
        final color = baseColor.withOpacity(factor);

        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// The main widget that builds your Summary tab.
Widget buildSummaryTab() {
  // Get the existing BalanceController from GetX
  final balanceController = Get.find<BalanceController>();

  return Obx(() {
    // 1) If loading, show spinner
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
              'Unable to load balance',
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
              onPressed: () {
                balanceController.fetchSummary();
                balanceController.fetchPurchases();
                balanceController.fetchPayments();
              },
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

    // 3) Otherwise, show the data
    final totalCost = balanceController.totalCost.value;
    final totalPaid = balanceController.totalPaid.value;
    final totalDiscount = balanceController.totalDiscount.value;
    final totalRefund = balanceController.totalRefund.value;
    final totalUse = balanceController.totalUse.value;
    final totalUnused = balanceController.totalUnused.value;
    final totalUnPaid = balanceController.totalUnPaid.value;
    final totalAfterDiscount = balanceController.totalAfterDiscount.value;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Current Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D8F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF2E7D8F),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _PulsingCircle(isNonZero: totalPaid != 0),
                              const SizedBox(width: 8),
                              Text(
                                "${totalPaid.toStringAsFixed(2)} EGP",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D8F),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Summary Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                buildSummaryCard("Total Cost", "${totalCost.toStringAsFixed(2)} EGP", Icons.receipt_long_outlined),
                buildSummaryCard("Total Discount", "${totalDiscount.toStringAsFixed(2)} EGP", Icons.discount_outlined),
                buildSummaryCard("After Discount", "${totalAfterDiscount.toStringAsFixed(2)} EGP", Icons.calculate_outlined),
                buildSummaryCard("Total Paid", "${totalPaid.toStringAsFixed(2)} EGP", Icons.payment_outlined),
                buildSummaryCard("Total UnPaid", "${totalUnPaid.toStringAsFixed(2)} EGP", Icons.money_off_outlined),
                buildSummaryCard("Total Use", "${totalUse.toStringAsFixed(2)} EGP", Icons.check_circle_outline),
                buildSummaryCard("Total UnUsed", "${totalUnused.toStringAsFixed(2)} EGP", Icons.pending_outlined),
                buildSummaryCard("Refund", "${totalRefund.toStringAsFixed(2)} EGP", Icons.refresh_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

/// A helper function that builds a single summary card in the grid.
Widget buildSummaryCard(String title, String value, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D8F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2E7D8F),
            size: 20,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D8F),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
