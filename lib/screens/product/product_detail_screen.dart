import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../core/constants/colors.dart';
import '../../models/product.dart';
import '../../providers/invoice_provider.dart';
import '../invoice/receipt_helper.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final invoiceProv = context.watch<InvoiceProvider>();
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

    // Calculate total quantity sold, total revenue, and list of sales transactions of this product
    int totalQtySold = 0;
    double totalRevenue = 0.0;
    final List<Map<String, dynamic>> salesOccurrences = [];

    for (var inv in invoiceProv.invoices) {
      for (var item in inv.details) {
        if (item.itemId == product.id) {
          totalQtySold += item.quantity;
          totalRevenue += item.amount;
          salesOccurrences.add({
            'invoice': inv,
            'quantity': item.quantity,
            'rate': item.mrp,
            'amount': item.amount,
            'unit': item.unit,
            'date': inv.inDate,
            'time': inv.inTime,
          });
        }
      }
    }

    // Sort occurrences by date descending
    salesOccurrences.sort((a, b) => (b['invoice'].id as int).compareTo(a['invoice'].id as int));

    // Calculate total revenue of all invoices to show product market contribution
    final totalAppRevenue = invoiceProv.invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
    final revenueContribution = totalAppRevenue == 0 ? 0.0 : (totalRevenue / totalAppRevenue) * 100;

    // Sum total stock across all units
    final totalStock = product.units.fold(0.0, (sum, u) => sum + u.stock);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PRODUCT DETAILS',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HERO PRODUCT DETAIL CARD
            _buildAnimatedBox(
              index: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          KanakColors.secondary.withOpacity(0.12),
                          KanakColors.primary.withOpacity(0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Stylized Box Icon representation
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [KanakColors.secondary, KanakColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: KanakColors.secondary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name & SKU
                        Text(
                          product.name,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SKU CODE: ${product.code ?? "N/A"}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 16),

                        // Grid specifications
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoMetaItem(context, 'TAX TIER', '${product.taxPercentage.toStringAsFixed(0)}% VAT'),
                            const SizedBox(
                              height: 30,
                              child: VerticalDivider(color: Colors.white24, width: 1),
                            ),
                            _buildInfoMetaItem(context, 'BASE PRICE', currencyFormat.format(product.basePrice)),
                            const SizedBox(
                              height: 30,
                              child: VerticalDivider(color: Colors.white24, width: 1),
                            ),
                            _buildInfoMetaItem(context, 'TOTAL STOCK', '${totalStock.toStringAsFixed(0)} units'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // DYNAMIC UNITS & PACKAGING LIST
            Text(
              'PACKAGING UNITS & STOCK LEVELS',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            product.units.isEmpty
                ? _buildAnimatedBox(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No individual units registered.',
                          style: GoogleFonts.inter(color: KanakColors.textSecondary),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: product.units.length,
                    itemBuilder: (context, uIdx) {
                      final unit = product.units[uIdx];
                      
                      // Gauge Color based on threshold
                      Color gaugeColor = KanakColors.success;
                      if (unit.stock == 0) {
                        gaugeColor = KanakColors.error;
                      } else if (unit.stock < 5) {
                        gaugeColor = Colors.orange;
                      }

                      return _buildAnimatedBox(
                        index: 1 + uIdx,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.02)
                                      : KanakColors.primary.withOpacity(0.01),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Stock Indicator Circle
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: gaugeColor.withOpacity(0.06),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: gaugeColor.withOpacity(0.2), width: 1.5),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          unit.stock.toStringAsFixed(0),
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: gaugeColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Unit packing name and pricing specifications
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${unit.name} PACKING',
                                              style: GoogleFonts.manrope(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Standard price: ${currencyFormat.format(unit.price)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                            if (unit.minPrice != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Price floor limit: ${currencyFormat.format(unit.minPrice!)}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: KanakColors.error.withOpacity(0.7),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                      
                                      // Stock alert warning
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: gaugeColor.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          unit.stock == 0 
                                              ? 'EMPTY' 
                                              : (unit.stock < 5 ? 'REPLENISH' : 'AVAILABLE'),
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: gaugeColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            
            const SizedBox(height: 24),
            
            // PRODUCT SALES PERFORMANCE ANALYTICS
            Text(
              'SALES PERFORMANCE & ANALYTICS',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Performance Cards row
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedBox(
                    index: 5,
                    child: _buildGlassPerformanceCard(
                      context,
                      'Revenue contributed',
                      currencyFormat.format(totalRevenue),
                      Icons.insights_rounded,
                      KanakColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnimatedBox(
                    index: 6,
                    child: _buildGlassPerformanceCard(
                      context,
                      'Total Quantity Sold',
                      '$totalQtySold units',
                      Icons.shopping_bag_rounded,
                      KanakColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Market Share gauge block
            _buildAnimatedBox(
              index: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.02)
                          : KanakColors.primary.withOpacity(0.01),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Market Sales Contribution share',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              '${revenueContribution.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: KanakColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Custom stacked horizontal progress gauge
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 8,
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            child: Row(
                              children: [
                                if (revenueContribution > 0)
                                  Expanded(
                                    flex: (revenueContribution * 10).round(),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [KanakColors.primary, KanakColors.secondary],
                                        ),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  flex: ((100.0 - revenueContribution) * 10).round(),
                                  child: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ORDER HISTORY TIMELINE FOR THIS PRODUCT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRODUCT ORDER RECOGNITIONS',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${salesOccurrences.length} orders',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            salesOccurrences.isEmpty
                ? _buildAnimatedBox(
                    index: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.15)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: KanakColors.textMuted, size: 36),
                            const SizedBox(height: 12),
                            Text(
                              'This product hasn\'t been sold yet.',
                              style: GoogleFonts.inter(color: KanakColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: salesOccurrences.length,
                    itemBuilder: (context, idx) {
                      final itemData = salesOccurrences[idx];
                      final inv = itemData['invoice'];

                      return _buildAnimatedBox(
                        index: 8 + idx,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.02)
                                      : KanakColors.primary.withOpacity(0.01),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                                ),
                                child: ListTile(
                                  onTap: () => showReceiptDialog(context, inv),
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: KanakColors.secondary.withOpacity(0.08),
                                    child: const Icon(Icons.shopping_cart_outlined, color: KanakColors.secondary, size: 16),
                                  ),
                                  title: Text(
                                    inv.invoiceNo,
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${itemData['quantity']} ${itemData['unit']}  x  ${currencyFormat.format(itemData['rate'])}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currencyFormat.format(itemData['amount']),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.chevron_right_rounded, color: KanakColors.textMuted),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMetaItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassPerformanceCard(BuildContext context, String label, String value, IconData icon, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.03)
                : KanakColors.primary.withOpacity(0.015),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : KanakColors.primary.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBox({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60).clamp(0, 500)),
      curve: Curves.easeOutBack,
      builder: (context, animValue, childWidget) {
        return Transform.scale(
          scale: 0.9 + (animValue * 0.1),
          child: Transform.translate(
            offset: Offset(0, (1.0 - animValue) * 20),
            child: Opacity(
              opacity: animValue.clamp(0.0, 1.0),
              child: childWidget,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
