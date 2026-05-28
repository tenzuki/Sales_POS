import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  static const String _baseUrl = 'http://142.93.214.133:3641/api';
  final http.Client _httpClient;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{'Accept': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _decode(response);
    _assertSuccess(response, data);
    return data;
  }

  Future<UserDetail> getUserDetail({required int userId}) async {
    final data = await _get('get_user_detail', {'user_id': '$userId'});
    final records = (data['data'] as List<dynamic>? ?? const []);
    if (records.isEmpty) {
      throw Exception('No user detail found');
    }
    return UserDetail.fromJson(records.first as Map<String, dynamic>);
  }

  Future<List<Customer>> getCustomers({
    required int routeId,
    required int storeId,
  }) async {
    final data = await _get('get_customer', {
      'route_id': '$routeId',
      'store_id': '$storeId',
    });
    final records = (data['data'] as List<dynamic>? ?? const []);
    return records
        .whereType<Map<String, dynamic>>()
        .map(Customer.fromJson)
        .toList(growable: false);
  }

  Future<List<Product>> getProducts({required int storeId}) async {
    final data = await _get('get_product', {'store_id': '$storeId'});
    final payload = data['data'];
    final records = payload is Map<String, dynamic>
        ? (payload['data'] as List<dynamic>? ?? const [])
        : const <dynamic>[];
    return records
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList(growable: false);
  }

  Future<List<ProductType>> getProductTypes() async {
    final data = await _get('get_product_type', const {});
    final records = (data['data'] as List<dynamic>? ?? const []);
    return records
        .whereType<Map<String, dynamic>>()
        .map(ProductType.fromJson)
        .toList(growable: false);
  }

  Future<List<ProductUnit>> getProductDetail({required int productId}) async {
    final data = await _get('get_product_detail', {'product_id': '$productId'});
    final records = (data['data'] as List<dynamic>? ?? const []);

    return records.whereType<Map<String, dynamic>>().map((entry) {
      final units = (entry['units'] as List<dynamic>? ?? const []);
      final firstUnit = units.isNotEmpty && units.first is Map<String, dynamic>
          ? units.first as Map<String, dynamic>
          : <String, dynamic>{};
      return ProductUnit(
        id: (entry['unit'] ?? firstUnit['id'] ?? 0) as int,
        name: (firstUnit['name'] ?? '') as String,
        price: double.tryParse((entry['price'] ?? '0').toString()) ?? 0,
      );
    }).toList(growable: false);
  }

  Future<Map<String, dynamic>> createVanSale({
    required int customerId,
    required int storeId,
    required int userId,
    required int vanId,
    required double discount,
    required double total,
    required double totalTax,
    required double grandTotal,
    required List<int> itemIds,
    required List<int> quantities,
    required List<double> mrp,
    required List<int> productTypes,
    required List<int> unitIds,
    String remarks = 'POS Sale from Flutter app',
  }) async {
    final body = {
      'customer_id': customerId,
      'store_id': storeId,
      'user_id': userId,
      'van_id': vanId,
      'save_mode': 'normal',
      'order_type': 1,
      'discount': discount,
      'total': total,
      'total_tax': totalTax,
      'grand_total': grandTotal,
      'round_off': 0,
      'if_vat': 1,
      'remarks': remarks,
      'item_id': itemIds,
      'quantity': quantities,
      'mrp': mrp,
      'product_type': productTypes,
      'unit': unitIds,
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/vansale.store'),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final data = _decode(response);
    _assertSuccess(response, data);
    return data;
  }

  Future<List<VanSale>> getVanSales({
    required int userId,
    required int storeId,
    required int vanId,
  }) async {
    final data = await _get('vansale.index', {
      'user_id': '$userId',
      'store_id': '$storeId',
      'van_id': '$vanId',
    });

    final payload = data['data'];
    final records = payload is Map<String, dynamic>
        ? (payload['data'] as List<dynamic>? ?? const [])
        : const <dynamic>[];

    return records
        .whereType<Map<String, dynamic>>()
        .map(VanSale.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _get(String path, Map<String, String> params) async {
    final uri = Uri.parse('$_baseUrl/$path').replace(queryParameters: params.isEmpty ? null : params);
    final response = await _httpClient.get(uri, headers: _headers);
    final data = _decode(response);
    _assertSuccess(response, data);
    return data;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final dynamic json = jsonDecode(response.body);
    if (json is Map<String, dynamic>) {
      return json;
    }
    throw Exception('Unexpected response format');
  }

  void _assertSuccess(http.Response response, Map<String, dynamic> data) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['message'] ?? 'Request failed (${response.statusCode})');
    }

    final success = data['success'];
    final status = data['status'];
    final isSuccess = (success is bool && success) || status == 'success' || status == true;

    if (!isSuccess && data['data'] == null) {
      throw Exception(data['message'] ?? (data['messages']?.toString() ?? 'API call failed'));
    }
  }
}
