// order_details_page.dart
import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderId = order['id']?.toString() ?? "";
    final status = order['status']?.toString() ?? "";
    final totalStr = order['total']?.toString() ?? "0.00";
    final dateStr = order['created_at']?.toString() ?? "";

    // The items array
    final List<dynamic> items = order["items"] as List<dynamic>? ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // Top background image
          Column(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRElHzS7DF6u04X-Y0OPLE2YkIIcaI6XjbB5K5atLN_ZCPg_Un9',                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
          // Circle logo (or lotus)
          Positioned(
            top: 110,
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
          // Custom app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                "Order Details #$orderId",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          // Content
          Positioned.fill(
            top: 200,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Status and date in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status,
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Items label
                    Row(
                      children: const [
                        Text(
                          "Items",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Show each item in a ListView or Column
                    // We'll just do a Column of item cards for simplicity
                    ...items.map((item) => _buildOrderItemCard(item as Map<String, dynamic>)).toList(),
                    const SizedBox(height: 16),

                    // Some summary details
                    _buildLabelValueRow("Quantity", order["qty"]?.toString() ?? "0"),
                    const Divider(),
                    _buildLabelValueRow("Subtotal", "EGP ${order["subtotal"]}"),
                    const Divider(),
                    _buildLabelValueRow("Discount", "EGP ${order["discount"]}"),
                    const Divider(),
                    _buildLabelValueRow(
                      "Total",
                      "EGP $totalStr",
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build a single item card
  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    final itemTitle = item["title"]?.toString() ?? "";
    final itemImage = item["image"]?.toString() ?? "";
    final itemQty = item["qty"]?.toString() ?? "1";
    final itemSubtotal = item["subtotal"]?.toString() ?? "0.00";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: (itemImage.isEmpty)
            ? const SizedBox(
          width: 50,
          height: 50,
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
        )
            : Image.network(
          itemImage,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              width: 50,
              height: 50,
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            );
          },
        ),
        title: Text(
          itemTitle.isEmpty ? "." : itemTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$itemQty x EGP $itemSubtotal"),
      ),
    );
  }

  Widget _buildLabelValueRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? Colors.teal : Colors.grey[800],
              )),
          Text(value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? Colors.teal : Colors.black,
              )),
        ],
      ),
    );
  }
}
