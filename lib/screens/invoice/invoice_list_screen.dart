import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';
import 'receipt_helper.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null && auth.userDetail != null) {
        final detail = auth.userDetail!;
        Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices(
          userId: detail.userId,
          storeId: detail.storeId,
          vanId: detail.vanId,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProv = context.watch<InvoiceProvider>();
    final auth = context.read<AuthProvider>();

    // Client-side search filters
    final filteredInvoices = invoiceProv.invoices.where((inv) {
      final matchesNo = inv.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCustomer = inv.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      return matchesNo || matchesCustomer;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'INVOICES HISTORY',
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
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search invoice no or customer...',
                prefixIcon: const Icon(Icons.search_rounded, color: KanakColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
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
          
          // Historical transactions list
          Expanded(
            child: invoiceProv.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: KanakColors.secondary),
                  )
                : invoiceProv.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: KanakColors.error, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                invoiceProv.errorMessage!,
                                style: GoogleFonts.inter(color: KanakColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (auth.currentUser != null && auth.userDetail != null) {
                                    final detail = auth.userDetail!;
                                    invoiceProv.fetchInvoices(
                                      userId: detail.userId,
                                      storeId: detail.storeId,
                                      vanId: detail.vanId,
                                    );
                                  }
                                },
                                child: const Text('RETRY SYNC'),
                              )
                            ],
                          ),
                        ),
                      )
                    : filteredInvoices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_rounded, color: KanakColors.textMuted, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty 
                                      ? 'No invoices created yet' 
                                      : 'No matching transactions',
                                  style: GoogleFonts.inter(color: KanakColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filteredInvoices.length,
                            itemBuilder: (context, index) {
                              final invoice = filteredInvoices[index];
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => showReceiptDialog(context, invoice),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Card(
                                    elevation: 2,
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Left Document Icon block
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: KanakColors.success.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.assignment_turned_in_rounded,
                                              color: KanakColors.success,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Core Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      invoice.invoiceNo,
                                                      style: GoogleFonts.manrope(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Payment Term badge
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        invoice.billMode,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  invoice.customerName ?? 'Customer #${invoice.customerId}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${invoice.inDate} | ${invoice.inTime}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Price tag subtotal on the right
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                currencyFormat.format(invoice.grandTotal),
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Tax: ',
                                                    style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                                  ),
                                                  Text(
                                                    currencyFormat.format(invoice.totalTax),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
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
    );
  }
}
