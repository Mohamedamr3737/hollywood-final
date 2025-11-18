// cart_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'product_detail_page.dart';
import '../../controller/shop_controller.dart';
import 'package:s_medi/general/services/alert_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  // Use a reactive list instead of a plain list
  static final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  // Add to cart method
  static void addToCart(Map<String, dynamic> product, int quantity) {
    final index = cartItems.indexWhere((item) => item["product"]["id"] == product["id"]);
    if (index >= 0) {
      // Increase quantity
      cartItems[index]["quantity"] += quantity;
      // Manually refresh the RxList to update observers
      cartItems.refresh();
    } else {
      cartItems.add({
        "product": product,
        "quantity": quantity,
      });
    }
  }

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isSending = false;

  // Get the same ShopController instance
  final ShopController shopController = Get.find<ShopController>();

  // Method to calculate totals reactively
  Map<String, dynamic> _calculateTotals() {
    double subTotal = 0.0;
    double discountTotal = 0.0;
    int totalQuantity = 0;

    for (var item in CartPage.cartItems) {
      final product = item["product"] as Map<String, dynamic>;
      final quantity = item["quantity"] as int;
      final price = product["price"] as double;
      final oldPrice = product["oldPrice"] as double?;

      subTotal += price * quantity;
      if (oldPrice != null && oldPrice > price) {
        discountTotal += (oldPrice - price) * quantity;
      }
      totalQuantity += quantity;
    }

    return {
      'subTotal': subTotal,
      'discountTotal': discountTotal,
      'totalQuantity': totalQuantity,
      'finalTotal': subTotal,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.8),
              elevation: 0,
              title: const Text(
                "Checkout",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 40), // Account for transparent AppBar
          // Cart list
          Expanded(
            child: Obx(() {
              if (CartPage.cartItems.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Your cart is empty",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Add some products to get started",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: CartPage.cartItems.length,
                itemBuilder: (context, index) {
                  final item = CartPage.cartItems[index];
                  return _buildCartItem(item);
                },
              );
            }),
          ),
          // Summary - Now wrapped in Obx to be reactive
          Obx(() {
            if (CartPage.cartItems.isEmpty) return const SizedBox.shrink();

            final totals = _calculateTotals();
            final subTotal = totals['subTotal'] as double;
            final discountTotal = totals['discountTotal'] as double;
            final totalQuantity = totals['totalQuantity'] as int;
            final finalTotal = totals['finalTotal'] as double;

            return ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow("Quantity", "$totalQuantity"),
                            const SizedBox(height: 8),
                            _buildSummaryRow("SubTotal", "${subTotal.toStringAsFixed(1)} EGP"),
                            const SizedBox(height: 8),
                            _buildSummaryRow("Discount", "${discountTotal.toStringAsFixed(1)} EGP"),
                            const SizedBox(height: 12),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.withOpacity(0.2),
                                    Colors.grey.withOpacity(0.4),
                                    Colors.grey.withOpacity(0.2),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              "Total",
                              "${finalTotal.toStringAsFixed(1)} EGP",
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          onPressed: CartPage.cartItems.isEmpty || _isSending
                              ? null
                              : () {
                            _sendOrder();
                          },
                          child: _isSending
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Sending...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                              : const Text(
                            "Send to Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontSize: isTotal ? 16 : 14,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontSize: isTotal ? 16 : 14,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final product = item["product"] as Map<String, dynamic>;
    final quantity = item["quantity"] as int;

    final title = product["title"] as String;
    final price = product["price"] as double;
    final oldPrice = product["oldPrice"] as double?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
              ).then((_) => setState(() {}));
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange[500]!.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Title + price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? "." : title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "${price.toStringAsFixed(2)} EGP",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                            if (oldPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                "${oldPrice.toStringAsFixed(2)} EGP",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Stepper with glass effect
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildStepperButton(
                          icon: Icons.remove,
                          onPressed: quantity > 1 ? () {
                            item["quantity"] = quantity - 1;
                            CartPage.cartItems.refresh();
                          } : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildStepperButton(
                          icon: Icons.add,
                          onPressed: () {
                            item["quantity"] = quantity + 1;
                            CartPage.cartItems.refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Remove item with glass effect
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        CartPage.cartItems.remove(item);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
          color: onPressed != null ? Colors.black87 : Colors.black38,
        ),
      ),
    );
  }

  Future<void> _sendOrder() async {
    setState(() => _isSending = true);

    final msg = await shopController.storeOrder(CartPage.cartItems);
    if (msg.toLowerCase().contains("error") || msg.toLowerCase().contains("exception")) {
      AlertService.error(context, msg);
    } else {
      AlertService.success(context, msg);
      setState(() {
        CartPage.cartItems.clear();
      });
    }

    setState(() => _isSending = false);
  }
}