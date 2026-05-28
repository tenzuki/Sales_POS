import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/product.dart';

class InvoiceProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  CustomerModel? _selectedCustomer;
  final List<CartItem> _cartItems = [];
  
  double _discountAmount = 0.0; // Flat discount
  bool _ifVat = true;           // True = 5% VAT included, False = 0%
  String _remarks = '';
  
  // Historical Invoices
  List<VanSaleInvoice> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  CustomerModel? get selectedCustomer => _selectedCustomer;
  List<CartItem> get cartItems => _cartItems;
  double get discountAmount => _discountAmount;
  bool get ifVat => _ifVat;
  String get remarks => _remarks;
  
  List<VanSaleInvoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Set active customer for the invoice
  void selectCustomer(CustomerModel customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // Clear active customer
  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  // Add item to cart or increment quantity
  void addToCart(ProductModel product, ProductUnit unit, int productTypeId, String productTypeName, int qty) {
    // Check if item already exists in cart with same unit and type
    final index = _cartItems.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedUnit.id == unit.id &&
        item.productTypeId == productTypeId);

    if (index >= 0) {
      _cartItems[index].quantity += qty;
    } else {
      _cartItems.add(CartItem(
        product: product,
        selectedUnit: unit,
        productTypeId: productTypeId,
        productTypeName: productTypeName,
        quantity: qty,
        customPrice: unit.price,
      ));
    }
    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeFromCart(item);
    } else {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  // Update item custom unit price
  void updateCustomPrice(CartItem item, double price) {
    item.customPrice = price;
    notifyListeners();
  }

  // Set invoice flat discount
  void setDiscount(double amount) {
    _discountAmount = amount;
    notifyListeners();
  }

  // Toggle VAT status
  void toggleVat(bool val) {
    _ifVat = val;
    notifyListeners();
  }

  // Set custom invoice remarks
  void setRemarks(String val) {
    _remarks = val;
  }

  // Cart Subtotals
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get totalTax {
    if (!_ifVat) return 0.0;
    return _cartItems.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double get grandTotal {
    double total = subtotal + totalTax - _discountAmount;
    return total < 0 ? 0.0 : total;
  }

  // Clear active cart & compose session
  void clearCart() {
    _cartItems.clear();
    _discountAmount = 0.0;
    _ifVat = true;
    _remarks = '';
    notifyListeners();
  }

  // Submit Invoice to Server (POST `/vansale.store`)
  Future<bool> createInvoice({required int userId, required int storeId, required int vanId}) async {
    if (_selectedCustomer == null || _cartItems.isEmpty) {
      _errorMessage = 'Customer or Invoice items are empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Structure item arrays for API payload
      final List<int> itemIds = [];
      final List<int> quantities = [];
      final List<double> mrps = [];
      final List<int> productTypes = [];
      final List<int> units = [];

      for (var item in _cartItems) {
        itemIds.add(item.product.id);
        quantities.add(item.quantity);
        mrps.add(item.customPrice);
        productTypes.add(item.productTypeId);
        units.add(item.selectedUnit.id);
      }

      final payload = {
        'customer_id': _selectedCustomer!.id,
        'store_id': storeId,
        'user_id': userId,
        'van_id': vanId,
        'save_mode': 'normal',
        'order_type': 1,
        'discount': _discountAmount,
        'total': subtotal,
        'total_tax': totalTax,
        'grand_total': grandTotal,
        'round_off': 0,
        'if_vat': _ifVat ? 1 : 0,
        'remarks': _remarks.isEmpty ? 'Van Sale Mobile App' : _remarks,
        'item_id': itemIds,
        'quantity': quantities,
        'mrp': mrps,
        'product_type': productTypes,
        'unit': units,
      };

      final response = await _apiClient.post('/vansale.store', payload);
      
      // Handle response - verify if invoice was created
      if (response != null && (response['success'] == true || response['status'] == 'success')) {
        clearCart();
        clearSelectedCustomer();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to submit sale to server';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch past invoices list (GET `/vansale.index`)
  Future<void> fetchInvoices({required int userId, required int storeId, required int vanId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/vansale.index', body: {
        'user_id': userId.toString(),
        'store_id': storeId.toString(),
        'van_id': vanId.toString(),
      });

      if (response != null && response['data'] != null) {
        final List list = response['data']['data'] ?? [];
        _invoices = list.map((inv) => VanSaleInvoice.fromJson(inv)).toList();
        
        // Sort by id descending so newest is on top
        _invoices.sort((a, b) => b.id.compareTo(a.id));
        
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load invoices';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
    }
  }
}
