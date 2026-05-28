import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';
import '../dashboard/dashboard_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _discountController = TextEditingController();
  final _remarksController = TextEditingController();
  final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

  @override
  void initState() {
    super.initState();
    final invoiceProv = Provider.of<InvoiceProvider>(context, listen: false);
    _discountController.text = invoiceProv.discountAmount > 0 
        ? invoiceProv.discountAmount.toStringAsFixed(0) 
        : '';
    _remarksController.text = invoiceProv.remarks;
  }

  @override
  void dispose() {
    _discountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handleSubmitInvoice() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final invoiceProv = Provider.of<InvoiceProvider>(context, listen: false);

    if (auth.currentUser == null || auth.userDetail == null) return;
    final detail = auth.userDetail!;

    // Enforce discount mapping
    final discount = double.tryParse(_discountController.text.trim()) ?? 0.0;
    invoiceProv.setDiscount(discount);
    invoiceProv.setRemarks(_remarksController.text.trim());

    final success = await invoiceProv.createInvoice(
      userId: detail.userId,
      storeId: detail.storeId,
      vanId: detail.vanId,
    );

    if (mounted) {
      if (success) {
        // Success dialog and pop
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle_rounded, color: KanakColors.secondary, size: 56),
            title: Text(
              'Invoice Created!',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Text(
              'Your van sale has been recorded successfully on the server.',
              style: GoogleFonts.inter(),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Redirect to Dashboard and wipe routes stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                child: const Text('BACK TO DASHBOARD'),
              )
            ],
          ),
        );
      } else {
        // Show error feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              invoiceProv.errorMessage ?? 'Failed to create invoice.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: KanakColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProv = context.watch<InvoiceProvider>();
    final customer = invoiceProv.selectedCustomer;
    final cartItems = invoiceProv.cartItems;
    final isLoading = invoiceProv.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'COMPOSE BILL',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 48, color: KanakColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No items in active invoice',
                    style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Customer Quick Banner Details
                      if (customer != null)
                        Card(
                          color: KanakColors.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.person_pin_rounded, color: KanakColors.secondary, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name,
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Payment Mode: ${customer.paymentTerms} | Code: ${customer.code.isEmpty ? "NA" : customer.code}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        'INVOICE PRODUCTS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Cart products list compiler
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, idx) {
                          final item = cartItems[idx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row 1: Product Name & Delete button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.name,
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          invoiceProv.removeFromCart(item);
                                        },
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: KanakColors.error,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Row 2: Price details & compact controllers
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Pricing detail
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${item.selectedUnit.name} x ',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                          ),
                                          Text(
                                            currencyFormat.format(item.customPrice),
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          // Sale Type tag
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: item.productTypeId == 1 
                                                  ? Colors.grey.shade100.withOpacity(0.1)
                                                  : KanakColors.warningBg.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.productTypeName,
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: item.productTypeId == 1 
                                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7) 
                                                    : KanakColors.warning,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      
                                      // Space-optimized Qty adjusters & Subtotals
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Decrement button
                                          GestureDetector(
                                            onTap: () {
                                              invoiceProv.updateQuantity(item, item.quantity - 1);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: KanakColors.outline.withOpacity(0.5)),
                                              ),
                                              child: Icon(
                                                Icons.remove, 
                                                size: 12, 
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${item.quantity}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Increment button
                                          GestureDetector(
                                            onTap: () {
                                              invoiceProv.updateQuantity(item, item.quantity + 1);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              child: const Icon(
                                                Icons.add, 
                                                size: 12, 
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Subtotal
                                          SizedBox(
                                            width: 75,
                                            child: Text(
                                              currencyFormat.format(item.subtotal),
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // VAT and Discount Config layout
                      Text(
                        'BILLING SETTINGS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // VAT switch row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.percent_rounded, color: KanakColors.primary, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Apply 5% VAT Tax',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: invoiceProv.ifVat,
                                    onChanged: (val) {
                                      invoiceProv.toggleVat(val);
                                    },
                                    activeColor: KanakColors.secondary,
                                  )
                                ],
                              ),
                              const Divider(height: 24),
                              
                              // Flat Discount input
                              Row(
                                children: [
                                  const Icon(Icons.local_offer_outlined, color: KanakColors.success, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Flat Discount (INR)',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    height: 45,
                                    child: TextField(
                                      controller: _discountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        final double discount = double.tryParse(val) ?? 0.0;
                                        invoiceProv.setDiscount(discount);
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Remarks box
                      Text(
                        'REMARKS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: KanakColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _remarksController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Enter sale remarks or checkout notes here...',
                          fillColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Detailed Receipt aggregates card
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'RECEIPT SUMMARY',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: KanakColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildReceiptRow('Subtotal', currencyFormat.format(invoiceProv.subtotal)),
                              const SizedBox(height: 8),
                              _buildReceiptRow('VAT Tax Amount (5%)', currencyFormat.format(invoiceProv.totalTax)),
                              const SizedBox(height: 8),
                              _buildReceiptRow(
                                'Discount Deductions', 
                                '- ${currencyFormat.format(invoiceProv.discountAmount)}',
                                textStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                              ),
                              const Divider(height: 24),
                               _buildReceiptRow(
                                  'Grand Total', 
                                  currencyFormat.format(invoiceProv.grandTotal),
                                  labelStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                  textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Fixed Bottom Submission Layout overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                      border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSubmitInvoice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KanakColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SUBMIT VAN SALE INVOICE',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {TextStyle? labelStyle, TextStyle? textStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        Text(
          value,
          style: textStyle ?? GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }
}
