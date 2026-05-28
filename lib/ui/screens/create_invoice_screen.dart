import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_session.dart';
import '../../data/models.dart';
import 'customer_list_screen.dart';
import 'product_list_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  bool _saving = false;
  bool _loadingTypes = true;
  String? _error;

  Customer? _selectedCustomer;
  List<ProductType> _productTypes = const [];
  final List<CartItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadProductTypes();
  }

  Future<void> _loadProductTypes() async {
    setState(() {
      _loadingTypes = true;
      _error = null;
    });

    try {
      final types = await widget.session.api.getProductTypes();
      setState(() => _productTypes = types);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingTypes = false);
    }
  }

  Future<void> _selectCustomer() async {
    final customer = await Navigator.of(context).push<Customer>(
      MaterialPageRoute(
        builder: (_) => CustomerListScreen(
          session: widget.session,
          selectionMode: true,
        ),
      ),
    );

    if (customer != null) {
      setState(() => _selectedCustomer = customer);
    }
  }

  Future<void> _selectProduct() async {
    if (_productTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product types not loaded yet')),
      );
      return;
    }

    final item = await Navigator.of(context).push<CartItem>(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          session: widget.session,
          title: 'Select Product',
          allowSelection: true,
          productTypes: _productTypes,
        ),
      ),
    );

    if (item != null) {
      final existingIndex = _items.indexWhere(
        (entry) => entry.product.id == item.product.id && entry.unit.id == item.unit.id,
      );

      setState(() {
        if (existingIndex >= 0) {
          _items[existingIndex].quantity += item.quantity;
        } else {
          _items.add(item);
        }
      });
    }
  }

  double get _subTotal => _items.fold(0, (sum, item) => sum + item.lineTotal);
  double get _totalTax => _items.fold(0, (sum, item) => sum + item.lineTax);
  double get _grandTotal => _subTotal + _totalTax;

  Future<void> _submit() async {
    final customer = _selectedCustomer;
    final user = widget.session.user;
    final detail = widget.session.userDetail;

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product')),
      );
      return;
    }
    if (user == null || detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final response = await widget.session.api.createVanSale(
        customerId: customer.id,
        storeId: detail.storeId,
        userId: user.id,
        vanId: detail.vanId,
        discount: 0,
        total: _subTotal,
        totalTax: _totalTax,
        grandTotal: _grandTotal,
        itemIds: _items.map((e) => e.product.id).toList(growable: false),
        quantities: _items.map((e) => e.quantity).toList(growable: false),
        mrp: _items.map((e) => e.unit.price).toList(growable: false),
        productTypes: _items.map((e) => e.productType.id).toList(growable: false),
        unitIds: _items.map((e) => e.unit.id).toList(growable: false),
      );

      final data = response['data'] as Map<String, dynamic>?;
      final invoiceNo = (data?['invoice_no'] ?? 'Created').toString();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice $invoiceNo created successfully')),
      );
      setState(() {
        _items.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _submit,
        icon: _saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: const Text('Submit Invoice'),
      ),
      body: _loadingTypes
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
                        FilledButton(onPressed: _loadProductTypes, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Card(
                      child: ListTile(
                        title: Text(_selectedCustomer?.name ?? 'No customer selected'),
                        subtitle: Text(_selectedCustomer?.contact ?? 'Tap to choose customer'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _selectCustomer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _selectProduct,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add Product'),
                    ),
                    const SizedBox(height: 10),
                    Text('Items', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    if (_items.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No products selected yet'),
                        ),
                      )
                    else
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Card(
                          child: ListTile(
                            title: Text(item.product.name),
                            subtitle: Text(
                              '${item.unit.name} x ${item.quantity} | Type: ${item.productType.name}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currency.format(item.lineTotal)),
                                Text('Tax ${currency.format(item.lineTax)}'),
                              ],
                            ),
                            onLongPress: () {
                              setState(() => _items.removeAt(index));
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TotalRow(label: 'Subtotal', value: currency.format(_subTotal)),
                            _TotalRow(label: 'Tax', value: currency.format(_totalTax)),
                            const Divider(),
                            _TotalRow(
                              label: 'Grand Total',
                              value: currency.format(_grandTotal),
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.w700) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
