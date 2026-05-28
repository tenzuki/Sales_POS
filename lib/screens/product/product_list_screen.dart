import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/invoice_provider.dart';
import '../invoice/create_invoice_screen.dart';
import '../../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductConfigSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductConfigBottomSheet(product: product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final invoiceProv = context.watch<InvoiceProvider>();
    final customer = invoiceProv.selectedCustomer;

    final cartItemsCount = invoiceProv.cartItems.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'SELECT PRODUCT',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (customer != null)
              Text(
                'Customer: ${customer.name}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        actions: [
          // Dynamic Badge Cart Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  if (cartItemsCount > 0) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Your invoice cart is currently empty!'),
                        backgroundColor: KanakColors.warning,
                      ),
                    );
                  }
                },
              ),
              if (cartItemsCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: KanakColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 8),
        ],
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
                hintText: 'Search products by name or code...',
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
          
          // Products Inventory Listing
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
                                const Icon(Icons.grid_off_rounded, color: KanakColors.textMuted, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found in store',
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
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => _showProductConfigSheet(context, product),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Card(
                                    elevation: 2,
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Product Thumbnail Icon
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: KanakColors.primary.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.fastfood_rounded,
                                              color: KanakColors.primary,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Product description & price tag
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tax Rate: ${product.taxPercentage.toStringAsFixed(0)}% VAT',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                // Packaging unit chips list
                                                Row(
                                                  children: product.units.map((unit) {
                                                    return Container(
                                                      margin: const EdgeInsets.only(right: 6),
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                                      ),
                                                      child: Text(
                                                        '${unit.name}: ${unit.price.toStringAsFixed(0)}',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                )
                                              ],
                                            ),
                                          ),
                                          
                                          // Add CTA Button
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: KanakColors.primary,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.add_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          )
                                        ],
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
      // Float Button directly routes to compilation
      floatingActionButton: cartItemsCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
                );
              },
              backgroundColor: KanakColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                'COMPOSE INVOICE ($cartItemsCount)',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}

// Sleek select product bottom sheet (combining Select Product flow)
class ProductConfigBottomSheet extends StatefulWidget {
  final ProductModel product;

  const ProductConfigBottomSheet({super.key, required this.product});

  @override
  State<ProductConfigBottomSheet> createState() => _ProductConfigBottomSheetState();
}

class _ProductConfigBottomSheetState extends State<ProductConfigBottomSheet> {
  late ProductUnit _selectedUnit;
  late ProductTypeModel _selectedType;
  int _quantity = 1;
  final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

  @override
  void initState() {
    super.initState();
    // Default select first available unit
    _selectedUnit = widget.product.units.isNotEmpty
        ? widget.product.units.first
        : ProductUnit(id: 0, name: 'UNIT', price: widget.product.basePrice, stock: 0);

    // Default select first product type (e.g. Normal)
    final types = Provider.of<ProductProvider>(context, listen: false).productTypes;
    _selectedType = types.isNotEmpty
        ? types.first
        : ProductTypeModel(id: 1, name: 'Normal', status: 1);
  }

  @override
  Widget build(BuildContext context) {
    final types = context.read<ProductProvider>().productTypes;
    final invoiceProv = context.read<InvoiceProvider>();

    final subtotal = _selectedUnit.price * _quantity;
    final taxRate = widget.product.taxPercentage;
    final taxAmount = subtotal * (taxRate / 100);
    final total = subtotal + taxAmount;

    final surfaceColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outlineColor = Theme.of(context).colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle Indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: outlineColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header details
          Text(
            'Configure Product Sale',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.name,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Packaging unit grid selector
          Text(
            'SELECT PACKAGING UNIT',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: onSurface.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: widget.product.units.map((unit) {
              final isSelected = _selectedUnit.id == unit.id;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedUnit = unit;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? KanakColors.primary : surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? KanakColors.primary : outlineColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            unit.name,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? Colors.white : onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹ ${unit.price.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white.withOpacity(0.8) : onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Sale category dropdown (Normal, FOC, Sample, etc.)
          Text(
            'SALE TYPE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: onSurface.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: outlineColor.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ProductTypeModel>(
                value: _selectedType,
                isExpanded: true,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
                items: types.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(
                      t.name,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Row of Qty compilation selector and Subtotals preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUANTITY',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildQtyButton(Icons.remove_rounded, () {
                        if (_quantity > 1) {
                          setState(() {
                            _quantity--;
                          });
                        }
                      }),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ),
                      _buildQtyButton(Icons.add_rounded, () {
                        setState(() {
                          _quantity++;
                        });
                      }),
                    ],
                  )
                ],
              ),
              
              // Totals summary panel
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ITEM TOTAL (+${taxRate.toStringAsFixed(0)}% VAT)',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(total),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Confirm submission CTA
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                invoiceProv.addToCart(
                  widget.product,
                  _selectedUnit,
                  _selectedType.id,
                  _selectedType.name,
                  _quantity,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added ${widget.product.name} ($_quantity $_selectedUnit) to invoice!',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: KanakColors.success,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KanakColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'ADD TO CART INVOICE',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        child: Icon(icon, size: 18, color: onSurface),
      ),
    );
  }
}
