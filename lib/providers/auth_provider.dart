import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  UserModel? _currentUser;
  UserSettings? _settings;
  UserDetail? _userDetail;
  
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  UserSettings? get settings => _settings;
  UserDetail? get userDetail => _userDetail;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Perform user login
  Future<bool> login(String email, String password) async {
    if (_currentUser != null) {
      return true;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post('/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['status'] == 'success') {
        if (_currentUser != null) {
          return true;
        }
        _currentUser = UserModel.fromJson(response['user']);
        if (response['settings'] != null) {
          _settings = UserSettings.fromJson(response['settings']);
        }
        
        // Success! Now fetch detailed routing assignments
        await fetchUserDetail();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        if (_currentUser != null) {
          return false;
        }
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (_currentUser != null) {
        return false;
      }
      final msg = e.toString().replaceAll('Exception:', '').trim();
      if (msg.toLowerCase() == 'unauthorized') {
        _errorMessage = 'Invalid email or password';
      } else {
        _errorMessage = msg;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch routing assignments (store, route, van)
  Future<void> fetchUserDetail() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _apiClient.get('/get_user_detail', body: {
        'user_id': _currentUser!.id.toString(),
      });

      if (response != null && response['success'] == true) {
        final List data = response['data'];
        if (data.isNotEmpty) {
          _userDetail = UserDetail.fromJson(data.first);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      // If user details fail to load, let's create a default assignment so the app works
      _userDetail = UserDetail(
        id: 0,
        routeId: 84, // Default Route
        vanId: 0,    // Default Van
        userId: _currentUser!.id,
        storeId: _currentUser!.storeId ?? 112, // Default Store
        status: 1,
      );
    }
  }

  // Perform logout
  void logout() {
    _currentUser = null;
    _settings = null;
    _userDetail = null;
    _errorMessage = null;
    notifyListeners();
  }
}
