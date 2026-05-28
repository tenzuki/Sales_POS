import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/invoice.dart';
import '../login/login_screen.dart';
import '../customer/customer_list_screen.dart';
import '../invoice/invoice_list_screen.dart';
import '../analytics/analytics_screen.dart';
import '../customer/customer_directory_screen.dart';
import '../product/product_catalog_screen.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');

  @override
  void initState() {
    super.initState();
    // Clear any lingering snackbars from the login screen immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      _reloadData();
    });
  }

  Future<void> _reloadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null && auth.userDetail != null) {
      final userDetail = auth.userDetail!;
      
      // Load products, customers, and invoices simultaneously
      Provider.of<ProductProvider>(context, listen: false)
          .fetchProducts(storeId: userDetail.storeId);
      Provider.of<CustomerProvider>(context, listen: false)
          .fetchCustomers(routeId: userDetail.routeId, storeId: userDetail.storeId);
      Provider.of<InvoiceProvider>(context, listen: false)
          .fetchInvoices(
            userId: userDetail.userId,
            storeId: userDetail.storeId,
            vanId: userDetail.vanId,
          );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of SalesPOS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('LOGOUT', style: TextStyle(color: KanakColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final invoiceProv = context.watch<InvoiceProvider>();
    final customerProv = context.watch<CustomerProvider>();
    final productProv = context.watch<ProductProvider>();

    final user = auth.currentUser;
    final detail = auth.userDetail;

    // Calculations for today's summary
    final totalSalesCount = invoiceProv.invoices.length;
    final totalSalesVolume = invoiceProv.invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.point_of_sale_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SalesPOS Hub',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: KanakColors.error),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadData,
        color: KanakColors.secondary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Greeting Banner Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [KanakColors.primary, Color(0xFF1E2855)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: KanakColors.primary.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.name ?? 'Sales Representative',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Active Van indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: KanakColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: KanakColors.secondary.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined, color: KanakColors.secondary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'VAN ${detail?.vanId ?? 0}',
                                  style: GoogleFonts.inter(
                                    color: KanakColors.secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      const SizedBox(height: 16),
                      // Meta details footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetaItem('STORE', '${detail?.storeId ?? 112}'),
                          _buildMetaItem('ROUTE', '${detail?.routeId ?? 84}'),
                          _buildMetaItem('ROLE', user?.isStaff == "1" ? 'Staff' : 'Rep'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Today's Live performance headers
              Text(
                'TODAY\'S ACTIVITY SUMMARY',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              
              // Statistics blocks
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Sales Volume',
                      currencyFormat.format(totalSalesVolume),
                      Icons.payments_outlined,
                      KanakColors.success,
                      invoiceProv.isLoading,
                      () => _showSalesVolumeSheet(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Invoices Count',
                      '$totalSalesCount Sales',
                      Icons.receipt_long_outlined,
                      KanakColors.primary,
                      invoiceProv.isLoading,
                      () => _showInvoicesCountSheet(context),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Primary Action Buttons
              Text(
                'QUICK ACTIONS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              
              // Large CTA Card
              _buildBigActionButton(
                'Create Invoice',
                'Select a customer to compose and submit a new van sale.',
                Icons.add_shopping_cart_rounded,
                KanakColors.secondary,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Row of secondary action triggers
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryActionButton(
                      'Invoices History',
                      Icons.history_toggle_off_rounded,
                      KanakColors.primary,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSecondaryActionButton(
                      'Refresh Catalog',
                      Icons.sync_rounded,
                      KanakColors.success,
                      () async {
                        await _reloadData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Successfully synchronized customers & products catalog.',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: KanakColors.success,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildBigActionButton(
                'Sales Analytics',
                'Visualize sales trends, collections, and catalog breakdowns.',
                Icons.analytics_outlined,
                KanakColors.primary,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Explorer Title
              Row(
                children: [
                  Text(
                    'EXPLORE DIRECTORIES',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Glassmorphic directory action grid
              Row(
                children: [
                  Expanded(
                    child: _buildGlassDirectoryButton(
                      'Customer Directory',
                      'Registry & Metrics',
                      Icons.people_alt_rounded,
                      KanakColors.primary,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CustomerDirectoryScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGlassDirectoryButton(
                      'Product Catalog',
                      'Inventory & Analytics',
                      Icons.inventory_2_rounded,
                      KanakColors.success,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProductCatalogScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Dynamic syncing state warnings if offline or api fails
              if (invoiceProv.errorMessage != null || productProv.errorMessage != null || customerProv.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KanakColors.errorBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: KanakColors.error.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: KanakColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          invoiceProv.errorMessage ?? productProv.errorMessage ?? customerProv.errorMessage ?? 'Catalog synchronization error.',
                          style: GoogleFonts.inter(color: KanakColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool loading, VoidCallback onTap) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: onSurface.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(icon, color: color.withOpacity(0.7), size: 20),
                ],
              ),
              const SizedBox(height: 12),
              loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigActionButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final surfaceColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outlineColor = Theme.of(context).colorScheme.outline;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outlineColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: onSurface.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: onSurface.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    final surfaceColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outlineColor = Theme.of(context).colorScheme.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outlineColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: onSurface.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSalesVolumeSheet(BuildContext context) {
    final invoiceProv = Provider.of<InvoiceProvider>(context, listen: false);
    
    double cashVolume = 0.0;
    double creditVolume = 0.0;
    for (var inv in invoiceProv.invoices) {
      if (inv.billMode.toUpperCase() == 'CREDIT') {
        creditVolume += inv.grandTotal;
      } else {
        cashVolume += inv.grandTotal;
      }
    }
    
    double totalVol = cashVolume + creditVolume;
    double cashPercent = totalVol > 0 ? cashVolume / totalVol : 0.0;
    double creditPercent = totalVol > 0 ? creditVolume / totalVol : 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final surfaceColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
        final onSurface = Theme.of(context).colorScheme.onSurface;
        
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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sales Volume Breakdown',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Analysis of Cash & Credit collections',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              
              // Total sales box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KanakColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KanakColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL SALES VOLUME',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: KanakColors.primary,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalVol),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: KanakColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Progress bars Cash
              _buildVolumeProgressBar(
                'CASH COLLECTIONS',
                cashVolume,
                cashPercent,
                KanakColors.success,
              ),
              const SizedBox(height: 16),
              
              // Progress bars Credit
              _buildVolumeProgressBar(
                'CREDIT BALANCES',
                creditVolume,
                creditPercent,
                KanakColors.primary,
              ),
              const SizedBox(height: 28),
              
              // Recent Money Transactions
              Text(
                'RECENT MONEY TRANSACTIONS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 10),
              
              Expanded(
                child: invoiceProv.invoices.isEmpty
                    ? Center(
                        child: Text(
                          'No completed sales volume transactions.',
                          style: GoogleFonts.inter(color: onSurface.withOpacity(0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: invoiceProv.invoices.length > 5 ? 5 : invoiceProv.invoices.length,
                        itemBuilder: (context, idx) {
                          final inv = invoiceProv.invoices[idx];
                          final isCredit = inv.billMode.toUpperCase() == 'CREDIT';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isCredit ? KanakColors.primary : KanakColors.success).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCredit ? Icons.credit_card_rounded : Icons.arrow_upward_rounded,
                                    size: 16,
                                    color: isCredit ? KanakColors.primary : KanakColors.success,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inv.customerName ?? 'Customer #${inv.customerId}',
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Invoice: ${inv.invoiceNo} | ${inv.inDate}',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '+ ₹ ${inv.grandTotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isCredit ? KanakColors.primary : KanakColors.success,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVolumeProgressBar(String title, double amount, double percentage, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.6)),
            ),
            Text(
              '₹ ${amount.toStringAsFixed(2)} (${(percentage * 100).toStringAsFixed(1)}%)',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        )
      ],
    );
  }

  Widget _buildTotalInvoicesProgressBar(int total, int cash, int credit) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cashPercent = total > 0 ? cash / total : 0.0;
    final creditPercent = total > 0 ? credit / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL INVOICES COUNT',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.6)),
            ),
            Text(
              '$total Bills ($cash Cash, $credit Credit)',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: KanakColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
            child: Row(
              children: [
                if (cash > 0)
                  Expanded(
                    flex: cash,
                    child: Container(
                      color: KanakColors.success,
                    ),
                  ),
                if (credit > 0)
                  Expanded(
                    flex: credit,
                    child: Container(
                      color: KanakColors.primary,
                    ),
                  ),
                if (total == 0)
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, color: KanakColors.success),
                const SizedBox(width: 4),
                Text('Cash (${(cashPercent * 100).toStringAsFixed(0)}%)', style: GoogleFonts.inter(fontSize: 10, color: onSurface.withOpacity(0.5))),
              ],
            ),
            Row(
              children: [
                Container(width: 8, height: 8, color: KanakColors.primary),
                const SizedBox(width: 4),
                Text('Credit (${(creditPercent * 100).toStringAsFixed(0)}%)', style: GoogleFonts.inter(fontSize: 10, color: onSurface.withOpacity(0.5))),
              ],
            ),
          ],
        )
      ],
    );
  }

  void _showCustomerInvoicesDialog(BuildContext context, String customerName, List<VanSaleInvoice> invoices) {
    final filtered = invoices.where((inv) => (inv.customerName ?? 'Customer #${inv.customerId}') == customerName).toList();
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: '₹ ');
    
    showDialog(
      context: context,
      builder: (context) {
        final surfaceColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
        final onSurface = Theme.of(context).colorScheme.onSurface;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: surfaceColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: KanakColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Customer Invoices',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                customerName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KanakColors.secondary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No invoices found for this customer.',
                      style: GoogleFonts.inter(color: onSurface.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final inv = filtered[idx];
                      final isCredit = inv.billMode.toUpperCase() == 'CREDIT';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isCredit ? KanakColors.primary : KanakColors.success).withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isCredit ? KanakColors.primary : KanakColors.success).withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv.invoiceNo,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${inv.inDate} | ${inv.inTime}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: onSurface.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isCredit ? KanakColors.primary : KanakColors.success).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    inv.billMode,
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isCredit ? KanakColors.primary : KanakColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currencyFormat.format(inv.grandTotal),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isCredit ? KanakColors.primary : KanakColors.success,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CLOSE',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: KanakColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInvoicesCountSheet(BuildContext context) {
    final invoiceProv = Provider.of<InvoiceProvider>(context, listen: false);
    
    int cashCount = 0;
    int creditCount = 0;
    for (var inv in invoiceProv.invoices) {
      if (inv.billMode.toUpperCase() == 'CREDIT') {
        creditCount++;
      } else {
        cashCount++;
      }
    }
    
    final totalCount = invoiceProv.invoices.length;
    double cashPercent = totalCount > 0 ? cashCount / totalCount : 0.0;
    double creditPercent = totalCount > 0 ? creditCount / totalCount : 0.0;
    
    final totalSalesVolume = invoiceProv.invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
    double avgValue = totalCount > 0 ? (totalSalesVolume / totalCount) : 0.0;
    
    Map<String, int> customerCounts = {};
    for (var inv in invoiceProv.invoices) {
      final name = inv.customerName ?? 'Customer #${inv.customerId}';
      customerCounts[name] = (customerCounts[name] ?? 0) + 1;
    }
    var sortedCustomers = customerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final surfaceColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
        final onSurface = Theme.of(context).colorScheme.onSurface;
        
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
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Invoice Volume Breakdown',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Invoice distribution and average billing metrics',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              
              // Double Summary cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KanakColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KanakColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL SALES',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: KanakColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalCount Bills',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: KanakColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KanakColors.success.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KanakColors.success.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVG BILL VALUE',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: KanakColors.success),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹ ${avgValue.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: KanakColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Total invoices stacked progress bar
              _buildTotalInvoicesProgressBar(totalCount, cashCount, creditCount),
              const SizedBox(height: 28),
              
              // Billed Customers Distribution
              Text(
                'BILLED CUSTOMERS DISTRIBUTION',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 10),
              
              Expanded(
                child: sortedCustomers.isEmpty
                    ? Center(
                        child: Text(
                          'No customer sales distribution found.',
                          style: GoogleFonts.inter(color: onSurface.withOpacity(0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedCustomers.length,
                        itemBuilder: (context, idx) {
                          final entry = sortedCustomers[idx];
                          return InkWell(
                            onTap: () => _showCustomerInvoicesDialog(context, entry.key, invoiceProv.invoices),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: KanakColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        entry.key,
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${entry.value} Invoice${entry.value > 1 ? "s" : ""}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassDirectoryButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, val, child) {
        return Transform.scale(
          scale: 0.95 + (val * 0.05),
          child: Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
