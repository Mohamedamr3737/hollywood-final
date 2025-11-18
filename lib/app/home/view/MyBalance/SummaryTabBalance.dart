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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // A) Current Balance Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Balance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Circle + number
                Row(
                  children: [
                    _PulsingCircle(isNonZero: totalPaid != 0),
                    const SizedBox(width: 8),
                    Text(
                      "${totalPaid.toStringAsFixed(2)} EGP",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // B) GridView with summary items
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: [
                buildSummaryCard("Total Cost", "${totalCost.toStringAsFixed(2)} EGP"),
                buildSummaryCard("Total Discount", "${totalDiscount.toStringAsFixed(2)} EGP"),
                buildSummaryCard("After Discount", "${totalAfterDiscount.toStringAsFixed(2)} EGP"),
                buildSummaryCard("Total Paid", "${totalPaid.toStringAsFixed(2)} EGP"),
                buildSummaryCard("Total UnPaid", "${totalUnPaid.toStringAsFixed(2)} EGP"),
                buildSummaryCard("Total Use", "${totalUse.toStringAsFixed(2)} EGP"),
                buildSummaryCard("Total UnUsed", "${totalUnused.toStringAsFixed(2)} EGP"),
                buildSummaryCard("Refund", "${totalRefund.toStringAsFixed(2)} EGP"),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

/// A helper function that builds a single summary card in the grid.
Widget buildSummaryCard(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
