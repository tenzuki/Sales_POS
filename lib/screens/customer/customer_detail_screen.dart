import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../models/customer.dart';
import '../../providers/invoice_provider.dart';
import '../invoice/receipt_helper.dart';

class CustomerDetailScreen extends StatelessWidget {
  final CustomerModel customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final invoiceProv = context.watch<InvoiceProvider>();
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

    // Filter invoices matching this customer id
    final customerInvoices = invoiceProv.invoices
        .where((inv) => inv.customerId == customer.id)
        .toList();

    // Calculations
    final totalBillings = customerInvoices.length;
    final totalSpent = customerInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
    
    final cashBillings = customerInvoices.where((inv) => inv.billMode.toUpperCase() == 'CASH').length;
    final creditBillings = customerInvoices.where((inv) => inv.billMode.toUpperCase() == 'CREDIT').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CUSTOMER DETAILS',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HERO CUSTOMER ID CARD (Glassmorphic Hero Banner)
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
                          KanakColors.primary.withOpacity(0.12),
                          KanakColors.secondary.withOpacity(0.04),
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
                        // Stylized Avatar Initials
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [KanakColors.primary, KanakColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: KanakColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            customer.name.isNotEmpty 
                                ? customer.name.substring(0, 1).toUpperCase()
                                : 'C',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name & Code
                        Text(
                          customer.name,
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CUSTOMER CODE: ${customer.code.isEmpty ? "N/A" : customer.code}',
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

                        // Grid info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoMetaItem(context, 'TERMS', customer.paymentTerms),
                            const SizedBox(
                              height: 30,
                              child: VerticalDivider(color: Colors.white24, width: 1),
                            ),
                            _buildInfoMetaItem(context, 'ROUTE ID', '#${customer.routeId}'),
                            const SizedBox(
                              height: 30,
                              child: VerticalDivider(color: Colors.white24, width: 1),
                            ),
                            _buildInfoMetaItem(context, 'STORE ID', '#${customer.storeId}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ANALYTICS HIGHLIGHTS TITLE
            Text(
              'PURCHASE INSIGHTS',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // DYNAMIC GLASSMORPHIC METRIC CARDS GRID
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedBox(
                    index: 1,
                    child: _buildGlassMetricCard(
                      context,
                      'Total Spendings',
                      currencyFormat.format(totalSpent),
                      Icons.account_balance_wallet_rounded,
                      KanakColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnimatedBox(
                    index: 2,
                    child: _buildGlassMetricCard(
                      context,
                      'Billings count',
                      '$totalBillings invoices',
                      Icons.receipt_long_rounded,
                      KanakColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Cash vs Credit Stacked Indicator
            _buildAnimatedBox(
              index: 3,
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
                              'Billing Mode distribution',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              'CASH: $cashBillings  |  CREDIT: $creditBillings',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Custom dynamic horizontal stacked bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            height: 10,
                            child: totalBillings == 0
                                ? Container(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))
                                : Row(
                                    children: [
                                      if (cashBillings > 0)
                                        Expanded(
                                          flex: cashBillings,
                                          child: Container(color: KanakColors.success),
                                        ),
                                      if (creditBillings > 0)
                                        Expanded(
                                          flex: creditBillings,
                                          child: Container(color: KanakColors.primary),
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
            
            // CONTACT CHANNELS
            Text(
              'CONTACT & COMMUNICATIONS',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildAnimatedBox(
              index: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.02)
                          : KanakColors.primary.withOpacity(0.01),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: KanakColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.phone_iphone_rounded, color: KanakColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PHONE CONTACT',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                customer.contactNumber ?? 'No contact registered',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (customer.contactNumber != null && customer.contactNumber!.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.content_copy_rounded, size: 18, color: KanakColors.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: customer.contactNumber!));
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied contact number: ${customer.contactNumber!}'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: KanakColors.success,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // BILLINGS HISTORY TRANSACTIONS LIST
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRANSACTIONS HISTORY',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${customerInvoices.length} invoices',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            customerInvoices.isEmpty
                ? _buildAnimatedBox(
                    index: 5,
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
                            const Icon(Icons.receipt_long_rounded, color: KanakColors.textMuted, size: 36),
                            const SizedBox(height: 12),
                            Text(
                              'No invoices found for this customer.',
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
                    itemCount: customerInvoices.length,
                    itemBuilder: (context, idx) {
                      final inv = customerInvoices[idx];
                      return _buildAnimatedBox(
                        index: 5 + idx,
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
                                    backgroundColor: KanakColors.success.withOpacity(0.08),
                                    child: const Icon(Icons.check_rounded, color: KanakColors.success, size: 16),
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
                                    '${inv.inDate} | ${inv.inTime}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currencyFormat.format(inv.grandTotal),
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

  Widget _buildGlassMetricCard(BuildContext context, String label, String value, IconData icon, Color accentColor) {
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

  // Premium entry scale & slide-up animation container for boxes
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
