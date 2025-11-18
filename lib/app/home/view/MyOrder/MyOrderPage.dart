// my_orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/orders_controller.dart';
import 'OrderDetailsPage.dart';
import '../../../auth/controller/token_controller.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  // We use OrdersController
  final OrdersController ordersController = Get.put(OrdersController());

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
    // Fetch orders from the server
    ordersController.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // (1) Background image & space for top
          Column(
            children: [
              // Header image
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://t3.ftcdn.net/jpg/03/66/08/34/360_F_366083470_jTuk7ZhaXxlk3paaPIxxPv2jUQhe1tQb.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Extra space for the circular logo
              const SizedBox(height: 60),
            ],
          ),

          // (2) Positioned Circular Logo
          Positioned(
            top: 110, // Adjust as needed
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSEa7ew_3UY_z3gT_InqdQmimzJ6jC3n2WgRpMUN9yekVsUxGIg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )

          ),

          // (3) Custom AppBar on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: const Text(
                "My Orders",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),

          // (4) Content below the circle
          Positioned.fill(
            top: 250, // so it appears below the circle
            child: Obx(() {
              // 1) If loading, show spinner
              if (ordersController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              // 2) If there's an error
              if (ordersController.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    ordersController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              // 3) Otherwise, show the orders
              final orders = ordersController.orders;

              if (orders.isEmpty) {
                return _buildNoOrdersUI();
              } else {
                return _buildOrdersList(orders);

              }
            }),
          ),
        ],
      ),
    );
  }

  // If there are no orders, show "No Orders"
  Widget _buildNoOrdersUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.shopping_cart,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            "No Orders",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You have no orders yet.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // If there are orders, show them in a list
  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final orderId = order['id']?.toString() ?? "";
        final status = order['status'] as String;
        final totalStr = order['total']?.toString() ?? "0.00";
        final dateStr = order['created_at'] as String? ?? "";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.orange[300], // or Colors.orangeAccent
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: "Order Num #..." and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #$orderId",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).withBackground(color: _statusColor(status)),
                ],
              ),
              const SizedBox(height: 8),

              // Row: "Total" on left and "EGP ..." on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    "EGP $totalStr",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Date and "VIEW" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Order Details page, pass the entire order map
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(order: order),
                        ),
                      );
                    },
                    child: const Text(
                      "VIEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Return a color for the status label
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.blue;
      case "canceled":
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// A small extension to wrap a widget in a colored container
extension WidgetBackground on Widget {
  Widget withBackground({Color color = Colors.green}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: this,
    );
  }
}
