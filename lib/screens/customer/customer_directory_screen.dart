import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/constants/colors.dart';
import '../../providers/customer_provider.dart';
import 'customer_detail_screen.dart';

class CustomerDirectoryScreen extends StatefulWidget {
  const CustomerDirectoryScreen({super.key});

  @override
  State<CustomerDirectoryScreen> createState() => _CustomerDirectoryScreenState();
}

class _CustomerDirectoryScreenState extends State<CustomerDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProv = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CUSTOMER DIRECTORY',
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
                              
                              // Staggered slide up animation for each list item
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 400 + (index * 50).clamp(0, 400)),
                                curve: Curves.easeOutCubic,
                                builder: (context, animValue, child) {
                                  return Transform.translate(
                                    offset: Offset(0, (1.0 - animValue) * 35),
                                    child: Opacity(
                                      opacity: animValue.clamp(0.0, 1.0),
                                      child: child,
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
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.01),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => CustomerDetailScreen(customer: customer),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  // Customer Initial Avatar Block (Glassmorphic Initial Circle)
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: KanakColors.primary.withOpacity(0.06),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: KanakColors.primary.withOpacity(0.12),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      customer.name.isNotEmpty 
                                                          ? customer.name.substring(0, 1).toUpperCase()
                                                          : 'C',
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
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.pin_drop_outlined, size: 13, color: KanakColors.textMuted),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              'Route Code: ${customer.routeId}',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 12,
                                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  
                                                  // Payment Term Badge
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: isCredit
                                                          ? KanakColors.primary.withOpacity(0.06)
                                                          : KanakColors.success.withOpacity(0.06),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(
                                                        color: isCredit
                                                            ? KanakColors.primary.withOpacity(0.15)
                                                            : KanakColors.success.withOpacity(0.15),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      customer.paymentTerms.toUpperCase(),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: isCredit
                                                            ? KanakColors.primary
                                                            : KanakColors.success,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
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
