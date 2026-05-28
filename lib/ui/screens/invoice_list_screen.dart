import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_session.dart';
import '../../data/models.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  bool _loading = true;
  String? _error;
  List<VanSale> _invoices = const [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = widget.session.user;
      final detail = widget.session.userDetail;
      if (user == null || detail == null) throw Exception('Session expired. Please login again.');

      final invoices = await widget.session.api.getVanSales(
        userId: user.id,
        storeId: detail.storeId,
        vanId: detail.vanId,
      );
      setState(() => _invoices = invoices);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice List')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        FilledButton(onPressed: _loadInvoices, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInvoices,
                  child: ListView.separated(
                    itemCount: _invoices.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final invoice = _invoices[index];
                      return ListTile(
                        title: Text(invoice.invoiceNo),
                        subtitle: Text('Customer: ${invoice.customerName}\nDate: ${invoice.date}'),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total ${money.format(invoice.total)}'),
                            Text('Grand ${money.format(invoice.grandTotal)}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
