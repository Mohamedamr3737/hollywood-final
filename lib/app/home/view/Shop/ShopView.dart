// products_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/shop_controller.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';
import '../../../auth/controller/token_controller.dart';
import '../../../auth/view/login_page.dart';
import 'package:s_medi/general/services/alert_service.dart';
class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final shopController = Get.put(ShopController());
  String localFilter = "all";
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    shopController.fetchProducts(page: 1);
    shopController.fetchCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildSearchSection(),
          const SizedBox(height: 16),
          _buildFilterSection(),
          const SizedBox(height: 16),
          Expanded(child: _buildProductGrid()),
          _buildPaginationSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      title: const Text(
        "PRODUCTS",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.orange.shade50,
          border: Border.all(
            color: Colors.orange.shade200,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
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
                  size: 24,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 12),
          _buildCategoryDropdown(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.grey.shade50,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: "Search products...",
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      final cats = shopController.categories;
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.grey.shade50,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: DropdownButton<int?>(
          value: selectedCategoryId,
          hint: Text(
            "Category",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600,
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                "All Categories",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            ...cats.map((c) {
              final catId = c["id"] as int;
              final catTitle = c["title"] as String;
              return DropdownMenuItem<int?>(
                value: catId,
                child: Text(
                  catTitle,
                  style: const TextStyle(color: Colors.black87),
                ),
              );
            }).toList(),
          ],
          onChanged: (val) {
            setState(() {
              selectedCategoryId = val;
            });
            _fetchFromServer(page: 1);
          },
        ),
      );
    });
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey.shade50,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip("All", "all"),
          _buildFilterChip("Featured", "featured"),
          _buildFilterChip("Hot", "hot"),
          _buildFilterChip("New", "new"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = localFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => localFilter = value);
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected ? Colors.orange : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (shopController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      }

      if (shopController.errorMessage.isNotEmpty) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.red.shade50,
              border: Border.all(
                color: Colors.red.shade200,
                width: 1,
              ),
            ),
            child: Text(
              shopController.errorMessage.value,
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      final products = shopController.products;
      if (products.isEmpty) {
        return const Center(
          child: Text(
            "No products found",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      final filtered = _applyLocalFilter(products);

      return LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive grid parameters
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Determine number of columns based on screen width
          int crossAxisCount = 2;
          if (screenWidth > 600) {
            crossAxisCount = 3;
          } else if (screenWidth > 900) {
            crossAxisCount = 4;
          }

          // Calculate responsive spacing and aspect ratio
          final spacing = screenWidth * 0.04; // 4% of screen width
          final cardWidth = (screenWidth - (spacing * (crossAxisCount + 1))) / crossAxisCount;

          // Dynamic aspect ratio based on screen height and card width
          double aspectRatio;
          if (screenHeight > 800) {
            aspectRatio = cardWidth / (cardWidth * 1.4); // Taller cards on large screens
          } else if (screenHeight > 600) {
            aspectRatio = cardWidth / (cardWidth * 1.3);
          } else {
            aspectRatio = cardWidth / (cardWidth * 1.2); // Shorter cards on small screens
          }

          return GridView.builder(
            padding: EdgeInsets.all(spacing),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildProductCard(filtered[index], constraints);
            },
          );
        },
      );
    });
  }

  Widget _buildProductCard(Map<String, dynamic> product, BoxConstraints constraints) {
    final title = product["title"] as String;
    final imageUrl = product["image"] as String;
    final price = product["price"] as double;
    final oldPrice = product["oldPrice"] as double?;
    final canBuy = product["can_buy"] as bool;
    final featured = product["featured"] == true;
    final hot = product["hot"] == true;
    final isNew = product["new"] == true;

    double discountPercentage = 0.0;
    if (oldPrice != null && oldPrice > price) {
      discountPercentage = 100.0 * (oldPrice - price) / oldPrice;
    }

    // Calculate responsive dimensions
    final screenWidth = constraints.maxWidth;
    final isSmallScreen = screenWidth < 600;
    final cardPadding = isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isSmallScreen ? 12.0 : 14.0;
    final priceFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonHeight = isSmallScreen ? 32.0 : 36.0;
    final buttonFontSize = isSmallScreen ? 10.0 : 12.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image with badges - Flexible height
                Expanded(
                  flex: isSmallScreen ? 3 : 4,
                  child: Stack(
                    children: [
                      _buildProductImage(imageUrl, constraints),
                      if (featured || hot || isNew)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: _buildBadge(featured, hot, isNew, isSmallScreen),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                // Product title - Fixed height
                SizedBox(
                  height: isSmallScreen ? 32 : 40,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: titleFontSize,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                // Price section - Fixed height
                SizedBox(
                  height: isSmallScreen ? 35 : 40,
                  child: _buildPriceSection(price, oldPrice, discountPercentage, priceFontSize, isSmallScreen),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                // Add to cart button - Fixed height
                _buildAddToCartButton(product, canBuy, buttonHeight, buttonFontSize, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String url, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final imageHeight = isSmallScreen ? 80.0 : 120.0;

    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        child: url.isEmpty
            ? Icon(
          Icons.image_not_supported_rounded,
          size: isSmallScreen ? 30 : 40,
          color: Colors.grey.shade400,
        )
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported_rounded,
              size: isSmallScreen ? 30 : 40,
              color: Colors.grey.shade400,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: isSmallScreen ? 20 : 24,
                height: isSmallScreen ? 20 : 24,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
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
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 8 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceSection(double price, double? oldPrice, double discountPercentage, double fontSize, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  "EGP ${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (oldPrice != null) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "EGP ${oldPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (discountPercentage > 0)
          Text(
            "${discountPercentage.toStringAsFixed(0)}% OFF",
            style: TextStyle(
              color: Colors.green,
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildAddToCartButton(Map<String, dynamic> product, bool canBuy, double height, double fontSize, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: canBuy ? Colors.orange : Colors.grey.shade300,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: canBuy
              ? () {
            CartPage.addToCart(product, 1);
            AlertService.success(context, "${product["title"]} added to cart");
          }
              : null,
          child: Center(
            child: FittedBox(
              child: Text(
                canBuy ? "Add to Cart" : "Out of Stock",
                style: TextStyle(
                  color: canBuy ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationSection() {
    return Obx(() {
      final currentPage = shopController.currentPage.value;
      final totalPages = shopController.totalPages.value;

      if (totalPages <= 1) return const SizedBox();

      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade50,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPaginationButton(
              "Previous",
              Icons.chevron_left_rounded,
              currentPage > 1,
                  () => _fetchFromServer(page: currentPage - 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange.shade50,
              ),
              child: Text(
                "$currentPage / $totalPages",
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildPaginationButton(
              "Next",
              Icons.chevron_right_rounded,
              currentPage < totalPages,
                  () => _fetchFromServer(page: currentPage + 1),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationButton(String text, IconData icon, bool enabled, VoidCallback? onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: enabled ? Colors.orange : Colors.grey.shade300,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (text == "Previous") Icon(icon, color: Colors.white, size: 18),
            Text(
              text,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (text == "Next") Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // Helper methods (unchanged functionality)
  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchFromServer(page: 1);
    });
  }

  List<Map<String, dynamic>> _applyLocalFilter(List<Map<String, dynamic>> items) {
    if (localFilter == "all") return items;
    return items.where((p) {
      if (localFilter == "featured") return p["featured"] == true;
      if (localFilter == "hot") return p["hot"] == true;
      if (localFilter == "new") return p["new"] == true;
      return true;
    }).toList();
  }

  void _fetchFromServer({int page = 1}) {
    final searchText = _searchCtrl.text.trim();
    shopController.fetchProducts(
      page: page,
      productTitle: searchText.isEmpty ? null : searchText,
      categoryId: selectedCategoryId,
    );
  }

  // Add missing checkLoginStatus method if not defined elsewhere
  void checkLoginStatus() async {
    String? token = await getAccessToken();
    if (token == null || token.isEmpty) {
      // Navigate to Login Page and remove all previous routes
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      });

  }

// Add your login status check logic here
    // This was called in initState but not defined in the original code
  }
}