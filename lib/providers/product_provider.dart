import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<ProductTypeModel> _productTypes = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  List<ProductTypeModel> get productTypes => _productTypes;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all products under user's store
  Future<void> fetchProducts({required int storeId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch Product Types
      await fetchProductTypes();

      // 2. Fetch Products
      final response = await _apiClient.get('/get_product', body: {
        'store_id': storeId.toString(),
      });

      if (response != null && response['data'] != null) {
        final List list = response['data']['data'] ?? [];
        
        List<ProductModel> tempProducts = [];
        for (var pJson in list) {
          ProductModel product = ProductModel.fromJson(pJson);
          
          // If the product units listed in `/get_product` are empty or require lazy updates,
          // we can request details. Let's make sure we have active units.
          if (product.units.isEmpty) {
            final detailedUnits = await fetchProductDetailUnits(product.id);
            product = ProductModel(
              id: product.id,
              code: product.code,
              name: product.name,
              proImage: product.proImage,
              taxPercentage: product.taxPercentage,
              basePrice: product.basePrice,
              storeId: product.storeId,
              status: product.status,
              units: detailedUnits,
            );
          }
          tempProducts.add(product);
        }
        
        _products = tempProducts;
        _filteredProducts = List.from(_products);
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load products';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch product unit configurations dynamically
  Future<List<ProductUnit>> fetchProductDetailUnits(int productId) async {
    try {
      final response = await _apiClient.get('/get_product_detail', body: {
        'product_id': productId.toString(),
      });

      if (response != null && response['data'] != null) {
        final List list = response['data'] ?? [];
        return list.map((u) => ProductUnit.fromJson(u)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching product detailed units for $productId: $e');
    }
    return [];
  }

  // Fetch product categories / types (Normal, FOC, Sample, etc.)
  Future<void> fetchProductTypes() async {
    try {
      final response = await _apiClient.get('/get_product_type');
      if (response != null && response['success'] == true) {
        final List list = response['data'] ?? [];
        _productTypes = list.map((t) => ProductTypeModel.fromJson(t)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching product types: $e');
      // If server fetch fails, set default fallbacks
      _productTypes = [
        ProductTypeModel(id: 1, name: 'Normal', status: 1),
        ProductTypeModel(id: 2, name: 'FOC', status: 1),
        ProductTypeModel(id: 3, name: 'Change', status: 1),
        ProductTypeModel(id: 4, name: 'Sample', status: 1),
      ];
    }
  }

  // Filter products by search term
  void filterProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()) || 
                       (p.code?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    notifyListeners();
  }
}
