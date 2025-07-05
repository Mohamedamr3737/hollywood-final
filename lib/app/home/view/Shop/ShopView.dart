import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/shop_controller.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';
import '../../../auth/controller/token_controller.dart';

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
    checkLoginStatus();
    super.initState();
    shopController.fetchProducts(page: 1);
    shopController.fetchCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D8F),
        title: const Text(
          "Shop",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            int itemCount = CartPage.cartItems.length;
            return Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: "Search products...",
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Category Dropdown
                Obx(() {
                  final cats = shopController.categories;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int?>(
                      value: selectedCategoryId,
                      hint: const Text(
                        "All Categories",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text("All Categories"),
                        ),
                        ...cats.map((c) {
                          final catId = c["id"] as int;
                          final catTitle = c["title"] as String;
                          return DropdownMenuItem<int?>(
                            value: catId,
                            child: Text(catTitle),
                          );
                        }).toList(),
                      ],
                      onChanged: (val) {
                        setState(() => selectedCategoryId = val);
                        _fetchFromServer(page: 1);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip("All", "all"),
                  _buildFilterChip("Featured", "featured"),
                  _buildFilterChip("Hot", "hot"),
                  _buildFilterChip("New", "new"),
                ],
              ),
            ),
          ),

          // Products List
          Expanded(
            child: Obx(() {
              if (shopController.isLoading.value) {
                return _buildLoadingState();
              }
              
              if (shopController.errorMessage.isNotEmpty) {
                return _buildErrorState();
              }

              final products = shopController.products;
              if (products.isEmpty) {
                return _buildEmptyState();
              }

              final filtered = _applyLocalFilter(products);
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  return _buildProductCard(product);
                },
              );
            }),
          ),

          // Pagination
          _buildPaginationRow(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = localFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => localFilter = value);
        },
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: const Color(0xFF2E7D8F),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2E7D8F),
          ),
          SizedBox(height: 16),
          Text(
            "Loading products...",
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            shopController.errorMessage.value,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetchFromServer(page: 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D8F),
              foregroundColor: Colors.white,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: const Color(0xFF6B7280).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "No products found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try adjusting your search or filters",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final title = product["title"] as String;
    final imageUrl = product["image"] as String;
    final price = product["price"] as double;
    final oldPrice = product["oldPrice"] as double?;
    final canBuy = product["can_buy"] as bool;

    double discountPercentage = 0.0;
    if (oldPrice != null && oldPrice > price) {
      discountPercentage = ((oldPrice - price) / oldPrice) * 100;
    }

    final featured = product["featured"] == true;
    final hot = product["hot"] == true;
    final isNew = product["new"] == true;

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
                      title,
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
                    
                    if (discountPercentage > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        "${discountPercentage.toStringAsFixed(0)}% OFF",
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Tags
                    Wrap(
                      spacing: 4,
                      children: [
                        if (featured) _buildTag("Featured", const Color(0xFF8B5CF6)),
                        if (hot) _buildTag("Hot", const Color(0xFFEF4444)),
                        if (isNew) _buildTag("New", const Color(0xFF3B82F6)),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Column
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: canBuy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      canBuy ? "In Stock" : "Out of Stock",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ElevatedButton(
                    onPressed: canBuy
                        ? () {
                            CartPage.addToCart(product, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$title added to cart"),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBuy ? const Color(0xFF2E7D8F) : const Color(0xFF9CA3AF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaginationRow() {
    return Obx(() {
      final currentPage = shopController.currentPage.value;
      final totalPages = shopController.totalPages.value;
      
      if (totalPages <= 1) return const SizedBox.shrink();
      
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: currentPage > 1
                  ? () => _fetchFromServer(page: currentPage - 1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D8F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Previous"),
            ),
            
            Text(
              "Page $currentPage of $totalPages",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            
            ElevatedButton(
              onPressed: currentPage < totalPages
                  ? () => _fetchFromServer(page: currentPage + 1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D8F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      );
    });
  }

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
}
