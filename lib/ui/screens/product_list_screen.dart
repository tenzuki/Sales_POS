import 'package:flutter/material.dart';

import '../../app/app_session.dart';
import '../../data/models.dart';
import 'select_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    required this.session,
    required this.title,
    this.allowSelection = false,
    this.productTypes = const [],
  });

  final AppSession session;
  final String title;
  final bool allowSelection;
  final List<ProductType> productTypes;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = widget.session.user;
      if (user == null) throw Exception('User not available');

      final products = await widget.session.api.getProducts(storeId: user.storeId);
      setState(() => _products = products);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onProductTap(Product product) async {
    if (!widget.allowSelection) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Base Price: ${product.price.toStringAsFixed(2)}'),
              Text('Tax: ${product.taxPercentage.toStringAsFixed(2)}%'),
              const SizedBox(height: 8),
              Text('Available Units: ${product.units.map((e) => e.name).join(', ')}'),
            ],
          ),
        ),
      );
      return;
    }

    final item = await Navigator.of(context).push<CartItem>(
      MaterialPageRoute(
        builder: (_) => SelectProductScreen(
          session: widget.session,
          product: product,
          productTypes: widget.productTypes,
        ),
      ),
    );

    if (!mounted) return;
    if (item != null) {
      Navigator.of(context).pop(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _products
        .where((p) => p.name.toLowerCase().contains(query) || p.id.toString().contains(query))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search product',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
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
                              FilledButton(onPressed: _loadProducts, child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(child: Text('No products found'))
                        : RefreshIndicator(
                            onRefresh: _loadProducts,
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                return ListTile(
                                  onTap: () => _onProductTap(product),
                                  title: Text(product.name),
                                  subtitle: Text(
                                    'Tax ${product.taxPercentage.toStringAsFixed(2)}% | Units: ${product.units.length}',
                                  ),
                                  trailing: Text(product.price.toStringAsFixed(2)),
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
