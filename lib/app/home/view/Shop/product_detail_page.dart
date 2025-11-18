import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_page.dart';
import 'package:s_medi/general/services/alert_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final String title = product["title"] as String;
    final String imageUrl = product["image"] as String;
    final double price = product["price"] as double;
    final double? oldPrice = product["oldPrice"] as double?;
    final bool canBuy = product["can_buy"] as bool;
    final bool featured = product["featured"] == true;
    final bool hot = product["hot"] == true;
    final bool isNew = product["new"] == true;

    double discountPercentage = 0.0;
    if (oldPrice != null && oldPrice > price) {
      discountPercentage = 100.0 * (oldPrice - price) / oldPrice;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          final screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Hero image section
                _buildHeroImageSection(imageUrl, title, featured, hot, isNew, constraints, screenHeight),

                // Product details content
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(title, price, oldPrice, discountPercentage, isSmallScreen),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      _buildProductDetails(title, isSmallScreen),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      _buildQuantitySection(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 32 : 40),
                      _buildAddToCartSection(product, canBuy, title, isSmallScreen),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        "Product Details",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildCartButton(),
        ),
      ],
    );
  }

  Widget _buildCartButton() {
    return Obx(() {
      int itemCount = CartPage.cartItems.length;
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange.shade50,
          border: Border.all(
            color: Colors.orange.shade200,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.orange.shade700,
                  size: 22,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeroImageSection(String imageUrl, String title, bool featured, bool hot, bool isNew, BoxConstraints constraints, double screenHeight) {
    final isSmallScreen = constraints.maxWidth < 600;
    final imageHeight = screenHeight * (isSmallScreen ? 0.35 : 0.4);
    final imageSize = constraints.maxWidth * (isSmallScreen ? 0.8 : 0.7);

    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Main image
          Center(
            child: Container(
              width: imageSize,
              height: imageSize * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                child: imageUrl.isEmpty
                    ? Icon(
                  Icons.image_not_supported_rounded,
                  size: isSmallScreen ? 60 : 80,
                  color: Colors.grey.shade400,
                )
                    : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported_rounded,
                      size: isSmallScreen ? 60 : 80,
                      color: Colors.grey.shade400,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Badge overlay
          if (featured || hot || isNew)
            Positioned(
              top: 40,
              right: 30,
              child: _buildBadge(featured, hot, isNew, isSmallScreen),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool featured, bool hot, bool isNew, bool isSmallScreen) {
    String text = "";
    Color color = Colors.transparent;

    if (featured) {
      text = "Featured";
      color = Colors.purple;
    } else if (hot) {
      text = "Hot";
      color = Colors.red;
    } else if (isNew) {
      text = "New";
      color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductInfo(String title, double price, double? oldPrice, double discountPercentage, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "EGP ${price.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: isSmallScreen ? 26 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            if (oldPrice != null) ...[
              SizedBox(width: isSmallScreen ? 12 : 16),
              Text(
                "EGP ${oldPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        if (discountPercentage > 0) ...[
          SizedBox(height: isSmallScreen ? 8 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Text(
              "Save ${discountPercentage.toStringAsFixed(0)}%",
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductDetails(String title, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Details",
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Quantity",
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuantityButton(
                icon: Icons.remove_rounded,
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                isSmallScreen: isSmallScreen,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 24 : 32),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  "$_quantity",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add_rounded,
                onPressed: () => setState(() => _quantity++),
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isSmallScreen,
  }) {
    final size = isSmallScreen ? 48.0 : 56.0;
    final iconSize = isSmallScreen ? 24.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: onPressed != null ? Colors.orange.shade300 : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: onPressed != null ? Colors.orange.shade700 : Colors.grey.shade400,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartSection(Map<String, dynamic> product, bool canBuy, String title, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 56 : 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 28 : 32),
        gradient: canBuy
            ? LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
        ),
        boxShadow: canBuy ? [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmallScreen ? 28 : 32),
          onTap: canBuy
              ? () {
            CartPage.addToCart(product, _quantity);
            AlertService.success(context, "$title added to cart (x$_quantity)");
          }
              : null,
          child: Center(
            child: Text(
              canBuy ? "Add to Cart" : "Out of Stock",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildProductInfo(String title, double price, double? oldPrice, double discountPercentage, bool isSmallScreen) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(
  //           fontSize: isSmallScreen ? 24 : 28,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.black87,
  //           height: 1.3,
  //         ),
  //       ),
  //       SizedBox(height: isSmallScreen ? 12 : 16),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.baseline,
  //         textBaseline: TextBaseline.alphabetic,
  //         children: [
  //           Text(
  //             "EGP ${price.toStringAsFixed(2)}",
  //             style: TextStyle(
  //               fontSize: isSmallScreen ? 28 : 34,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.orange.shade700,
  //             ),
  //           ),
  //           if (oldPrice != null) ...[
  //             SizedBox(width: isSmallScreen ? 12 : 16),
  //             Text(
  //               "EGP ${oldPrice.toStringAsFixed(2)}",
  //               style: TextStyle(
  //                 fontSize: isSmallScreen ? 18 : 20,
  //                 color: Colors.grey.shade500,
  //                 decoration: TextDecoration.lineThrough,
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //       if (discountPercentage > 0) ...[
  //         SizedBox(height: isSmallScreen ? 8 : 12),
  //         Container(
  //           padding: EdgeInsets.symmetric(
  //             horizontal: isSmallScreen ? 12 : 16,
  //             vertical: isSmallScreen ? 6 : 8,
  //           ),
  //           decoration: BoxDecoration(
  //             color: Colors.green.shade50,
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(
  //               color: Colors.green.shade200,
  //               width: 1,
  //             ),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(
  //                 Icons.local_offer_rounded,
  //                 color: Colors.green.shade600,
  //                 size: isSmallScreen ? 16 : 18,
  //               ),
  //               SizedBox(width: isSmallScreen ? 4 : 6),
  //               Text(
  //                 "Save ${discountPercentage.toStringAsFixed(0)}%",
  //                 style: TextStyle(
  //                   color: Colors.green.shade700,
  //                   fontSize: isSmallScreen ? 14 : 16,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ],
  //   );
  // }
//
//   Widget _buildProductDetails(String title, bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
//         border: Border.all(
//           color: Colors.grey.shade200,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.info_outline_rounded,
//                 color: Colors.grey.shade600,
//                 size: isSmallScreen ? 20 : 22,
//               ),
//               SizedBox(width: isSmallScreen ? 8 : 10),
//               Text(
//                 "Product Details",
//                 style: TextStyle(
//                   fontSize: isSmallScreen ? 18 : 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: isSmallScreen ? 12 : 16),
//           Container(
//             padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.grey.shade200,
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 14 : 16,
//                 color: Colors.grey.shade700,
//                 height: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
}