import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerModel> get customers => _customers;
  List<CustomerModel> get filteredCustomers => _filteredCustomers;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch customers matching user's active route
  Future<void> fetchCustomers({required int routeId, required int storeId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/get_customer', body: {
        'route_id': routeId.toString(),
        'store_id': storeId.toString(),
      });

      if (response != null && response['success'] == true) {
        final List list = response['data'] ?? [];
        _customers = list.map((c) => CustomerModel.fromJson(c)).toList();
        _filteredCustomers = List.from(_customers);
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load customers';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter customers by search term
  void filterCustomers(String query) {
    if (query.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()) || 
                       (c.contactNumber?.contains(query) ?? false))
          .toList();
    }
    notifyListeners();
  }

  // Proactive feature: add custom customers locally to provider cache
  void addCustomerLocally(CustomerModel customer) {
    _customers.insert(0, customer);
    _filteredCustomers = List.from(_customers);
    notifyListeners();
  }
}
