import 'package:flutter/material.dart';

import '../../app/app_session.dart';
import '../../data/models.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({
    super.key,
    required this.session,
    this.selectionMode = false,
  });

  final AppSession session;
  final bool selectionMode;

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<Customer> _customers = const [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final detail = widget.session.userDetail;
      if (detail == null) throw Exception('User detail is unavailable');

      final customers = await widget.session.api.getCustomers(
        routeId: detail.routeId,
        storeId: detail.storeId,
      );
      setState(() => _customers = customers);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _customers.where((c) {
      return c.name.toLowerCase().contains(query) || c.contact.toLowerCase().contains(query);
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? 'Select Customer' : 'Customer List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search customer',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorView(message: _error!, onRetry: _loadCustomers)
                    : filtered.isEmpty
                        ? const Center(child: Text('No customers found'))
                        : RefreshIndicator(
                            onRefresh: _loadCustomers,
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final customer = filtered[index];
                                return ListTile(
                                  title: Text(customer.name),
                                  subtitle: Text(
                                    'Contact: ${customer.contact.isEmpty ? '-' : customer.contact}\nTerms: ${customer.paymentTerms}',
                                  ),
                                  isThreeLine: true,
                                  trailing: widget.selectionMode ? const Icon(Icons.check_circle_outline) : null,
                                  onTap: widget.selectionMode
                                      ? () => Navigator.of(context).pop(customer)
                                      : null,
                                );
                              },
                            ),
                          ),
          )
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
