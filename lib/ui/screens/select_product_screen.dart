import 'package:flutter/material.dart';

import '../../app/app_session.dart';
import '../../data/models.dart';

class SelectProductScreen extends StatefulWidget {
  const SelectProductScreen({
    super.key,
    required this.session,
    required this.product,
    required this.productTypes,
  });

  final AppSession session;
  final Product product;
  final List<ProductType> productTypes;

  @override
  State<SelectProductScreen> createState() => _SelectProductScreenState();
}

class _SelectProductScreenState extends State<SelectProductScreen> {
  bool _loading = true;
  String? _error;

  List<ProductUnit> _units = const [];
  ProductUnit? _selectedUnit;
  ProductType? _selectedType;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.productTypes.isNotEmpty ? widget.productTypes.first : null;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final details = await widget.session.api.getProductDetail(productId: widget.product.id);
      final fallbackUnits = widget.product.units;
      final units = details.isNotEmpty ? details : fallbackUnits;
      if (units.isEmpty) throw Exception('No unit found for this product');

      setState(() {
        _units = units;
        _selectedUnit = units.first;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addToInvoice() {
    final unit = _selectedUnit;
    final type = _selectedType;
    if (unit == null || type == null) return;

    final item = CartItem(
      product: widget.product,
      unit: unit,
      productType: type,
      quantity: _quantity,
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Product')),
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
                        FilledButton(onPressed: _loadDetails, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(widget.product.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Tax: ${widget.product.taxPercentage.toStringAsFixed(2)}%'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProductUnit>(
                      initialValue: _selectedUnit,
                      items: _units
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text('${unit.name} - ${unit.price.toStringAsFixed(2)}'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setState(() => _selectedUnit = value),
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ProductType>(
                      initialValue: _selectedType,
                      items: widget.productTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setState(() => _selectedType = value),
                      decoration: const InputDecoration(
                        labelText: 'Product Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _quantity <= 1 ? null : () => setState(() => _quantity--),
                            icon: const Icon(Icons.remove),
                            label: const Text('Decrease'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_quantity',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _quantity++),
                            icon: const Icon(Icons.add),
                            label: const Text('Increase'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _addToInvoice,
                      child: const Text('Add To Invoice'),
                    )
                  ],
                ),
    );
  }
}
