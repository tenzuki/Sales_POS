import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../providers/customer_provider.dart';
import '../../providers/invoice_provider.dart';
import '../product/product_list_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProv = context.watch<CustomerProvider>();
    final invoiceProv = context.read<InvoiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SELECT CUSTOMER',
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
                customerProv.filterCustomers(val);
              },
              decoration: InputDecoration(
                hintText: 'Search customer name or phone...',
                prefixIcon: const Icon(Icons.search_rounded, color: KanakColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          customerProv.filterCustomers('');
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
          
          // Customer registry listing
          Expanded(
            child: customerProv.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: KanakColors.secondary),
                  )
                : customerProv.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: KanakColors.error, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                customerProv.errorMessage!,
                                style: GoogleFonts.inter(color: KanakColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : customerProv.filteredCustomers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_off_outlined, color: KanakColors.textMuted, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No customers found',
                                  style: GoogleFonts.inter(color: KanakColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: customerProv.filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = customerProv.filteredCustomers[index];
                              final isCredit = customer.paymentTerms.toUpperCase() == 'CREDIT';
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    // 1. Select Customer
                                    invoiceProv.selectCustomer(customer);
                                    // 2. Open Product List Screen
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ProductListScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Card(
                                    elevation: 2,
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Left profile icon
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: KanakColors.primary.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              customer.name.substring(0, 1).toUpperCase(),
                                              style: GoogleFonts.manrope(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: KanakColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Profile info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  customer.name,
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                if (customer.contactNumber != null && customer.contactNumber!.isNotEmpty)
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.phone_android_rounded, size: 14, color: KanakColors.textMuted),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        customer.contactNumber!,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 13,
                                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  Text(
                                                    'No contact number',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Right-side payment term badges
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isCredit
                                                  ? KanakColors.primary.withOpacity(0.08)
                                                  : KanakColors.success.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isCredit
                                                    ? KanakColors.primary.withOpacity(0.15)
                                                    : KanakColors.success.withOpacity(0.15),
                                              ),
                                            ),
                                            child: Text(
                                              customer.paymentTerms,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isCredit
                                                    ? KanakColors.primary
                                                    : KanakColors.success,
                                              ),
                                            ),
                                          ),
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
