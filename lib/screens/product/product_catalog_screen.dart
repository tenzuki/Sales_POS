import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/constants/colors.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PRODUCT CATALOG',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                productProv.filterProducts(val);
              },
              decoration: InputDecoration(
                hintText: 'Search product name or SKU...',
                prefixIcon: const Icon(Icons.search_rounded, color: KanakColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          productProv.filterProducts('');
                        },
                      )
                    : null,
                fillColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          
          // Product catalog list
          Expanded(
            child: productProv.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: KanakColors.secondary),
                  )
                : productProv.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: KanakColors.error, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                productProv.errorMessage!,
                                style: GoogleFonts.inter(color: KanakColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : productProv.filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.production_quantity_limits_rounded, color: KanakColors.textMuted, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: GoogleFonts.inter(color: KanakColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: productProv.filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = productProv.filteredProducts[index];
                              
                              // Calculate total stock of the product across all packaging units
                              final totalStock = product.units.fold(0.0, (sum, u) => sum + u.stock);
                              
                              // Colors based on stock thresholds
                              Color stockColor = KanakColors.success;
                              String stockStatus = 'IN STOCK';
                              if (totalStock == 0) {
                                stockColor = KanakColors.error;
                                stockStatus = 'OUT OF STOCK';
                              } else if (totalStock < 10) {
                                stockColor = Colors.orange;
                                stockStatus = 'LOW STOCK';
                              }

                              // Staggered slide up animation for each catalog item
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 400 + (index * 50).clamp(0, 400)),
                                curve: Curves.easeOutCubic,
                                builder: (context, animValue, childWidget) {
                                  return Transform.translate(
                                    offset: Offset(0, (1.0 - animValue) * 35),
                                    child: Opacity(
                                      opacity: animValue.clamp(0.0, 1.0),
                                      child: childWidget,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white.withOpacity(0.03)
                                              : KanakColors.primary.withOpacity(0.015),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white.withOpacity(0.06)
                                                : KanakColors.primary.withOpacity(0.08),
                                            width: 1,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => ProductDetailScreen(product: product),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  // Product Box Image Mock / Initial block
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: KanakColors.secondary.withOpacity(0.06),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: KanakColors.secondary.withOpacity(0.12),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.inventory_2_rounded,
                                                      color: KanakColors.secondary,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  
                                                  // Name and Base price info
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          product.name,
                                                          style: GoogleFonts.manrope(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: Theme.of(context).colorScheme.onSurface,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'SKU: ${product.code ?? "N/A"}  |  Base: ₹ ${product.basePrice.toStringAsFixed(2)}',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 11,
                                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  
                                                  // Stock Status Gauge block on the right
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        '${totalStock.toStringAsFixed(0)} units',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w800,
                                                          color: Theme.of(context).colorScheme.onSurface,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: stockColor.withOpacity(0.06),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(
                                                            color: stockColor.withOpacity(0.15),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          stockStatus,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                            color: stockColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: KanakColors.textMuted,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
