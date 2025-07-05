import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_detail_page.dart';
import '../../controller/shop_controller.dart';
import '../../../widgets/loading_indicator.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  static final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  static void addToCart(Map<String, dynamic> product, int quantity) {
    final index = cartItems.indexWhere((item) => item["product"]["id"] == product["id"]);
    if (index >= 0) {
      cartItems[index]["quantity"] += quantity;
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
  final ShopController shopController = Get.find<ShopController>();

  @override
  Widget build(BuildContext context) {
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
    final finalTotal = subTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D8F),
        title: const Text(
          "Shopping Cart",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (CartPage.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: CartPage.cartItems.length,
                itemBuilder: (context, index) {
                  final item = CartPage.cartItems[index];
                  return _buildCartItem(item, index);
                },
              ),
            ),
            
            // Order Summary
            _buildOrderSummary(subTotal, discountTotal, finalTotal, totalQuantity),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D8F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Color(0xFF2E7D8F),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add some products to get started",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D8F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Continue Shopping",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final product = item["product"] as Map<String, dynamic>;
    final quantity = item["quantity"] as int;
    final title = product["title"] as String;
    final price = product["price"] as double;
    final oldPrice = product["oldPrice"] as double?;
    final imageUrl = product["image"] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isEmpty
                      ? const Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: Color(0xFF9CA3AF),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Color(0xFF9CA3AF),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? "Product" : title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "EGP ${price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D8F),
                          ),
                        ),
                        if (oldPrice != null && oldPrice > price) ...[
                          const SizedBox(width: 8),
                          Text(
                            "EGP ${oldPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Quantity Controls
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: quantity > 1
                              ? () {
                                  item["quantity"] = quantity - 1;
                                  CartPage.cartItems.refresh();
                                }
                              : null,
                          icon: const Icon(Icons.remove, size: 18),
                          color: const Color(0xFF6B7280),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "$quantity",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            item["quantity"] = quantity + 1;
                            CartPage.cartItems.refresh();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          color: const Color(0xFF2E7D8F),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () {
                      CartPage.cartItems.removeAt(index);
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: const Color(0xFFEF4444),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subTotal, double discountTotal, double finalTotal, int totalQuantity) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSummaryRow("Items ($totalQuantity)", "EGP ${subTotal.toStringAsFixed(2)}"),
          if (discountTotal > 0)
            _buildSummaryRow("Discount", "-EGP ${discountTotal.toStringAsFixed(2)}", isDiscount: true),
          _buildSummaryRow("Delivery", "Free", isDelivery: true),
          
          const Divider(height: 24, thickness: 1),
          
          _buildSummaryRow(
            "Total",
            "EGP ${finalTotal.toStringAsFixed(2)}",
            isTotal: true,
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: CartPage.cartItems.isEmpty || _isSending ? null : _sendOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D8F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSending
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Processing...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "Place Order",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isDelivery = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isDiscount
                  ? const Color(0xFF10B981)
                  : isDelivery
                      ? const Color(0xFF10B981)
                      : isTotal
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOrder() async {
    setState(() => _isSending = true);

    try {
      final msg = await shopController.storeOrder(CartPage.cartItems);
      
      if (msg.toLowerCase().contains("error") || msg.toLowerCase().contains("exception")) {
        _showSnackBar(msg, isError: true);
      } else {
        _showSnackBar("Order placed successfully!", isError: false);
        CartPage.cartItems.clear();
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("Failed to place order. Please try again.", isError: true);
    }

    setState(() => _isSending = false);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
