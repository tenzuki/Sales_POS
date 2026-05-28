import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../models/invoice.dart';

void showReceiptDialog(BuildContext context, VanSaleInvoice invoice) {
  final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Receipt Header banner
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SalesPOS BILLING SYSTEM',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'VAN SALE TRANSACTION RECEIPT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                const DashedLine(),
                const SizedBox(height: 16),
                
                // Transaction Details
                _buildReceiptDetailRow(context, 'INVOICE NO', invoice.invoiceNo),
                _buildReceiptDetailRow(context, 'DATE & TIME', '${invoice.inDate} | ${invoice.inTime}'),
                _buildReceiptDetailRow(context, 'BILLING MODE', invoice.billMode),
                _buildReceiptDetailRow(context, 'CUSTOMER ID', '#${invoice.customerId}'),
                if (invoice.customerName != null)
                  _buildReceiptDetailRow(context, 'CUSTOMER NAME', invoice.customerName!),
                
                const SizedBox(height: 16),
                const DashedLine(),
                const SizedBox(height: 16),

                // Purchased Items breakdown if details are available
                if (invoice.details.isNotEmpty) ...[
                  Text(
                    'PURCHASED ITEMS',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...invoice.details.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.quantity} ${item.unit} x ${currencyFormat.format(item.mrp)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(item.amount),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  const DashedLine(),
                  const SizedBox(height: 16),
                ],
                
                // Financial Breakdown Table
                _buildReceiptAmountRow(context, 'Subtotal Amount', currencyFormat.format(invoice.total)),
                const SizedBox(height: 8),
                _buildReceiptAmountRow(context, 'VAT Tax tier (5%)', currencyFormat.format(invoice.totalTax)),
                const SizedBox(height: 8),
                _buildReceiptAmountRow(
                  context,
                  'Applied Discounts', 
                  '- ${currencyFormat.format(invoice.discount)}',
                  color: KanakColors.error,
                ),
                
                const SizedBox(height: 16),
                const DashedLine(),
                const SizedBox(height: 16),
                
                // Grand total highlight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GRAND TOTAL',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      currencyFormat.format(invoice.grandTotal),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? KanakColors.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                if (invoice.remarks != null && invoice.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Remarks: ${invoice.remarks}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                ],
                
                const SizedBox(height: 28),
                
                // CTA button to close virtual card
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KanakColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                    ),
                    child: Center(
                      child: Text(
                        'DISMISS RECEIPT',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildReceiptDetailRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}

Widget _buildReceiptAmountRow(BuildContext context, String label, String value, {Color? color}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
      Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
  );
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
