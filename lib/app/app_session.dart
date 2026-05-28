import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/models.dart';

class AppSession extends ChangeNotifier {
  final ApiClient api = ApiClient();

  AppUser? user;
  UserDetail? userDetail;
  String? token;
  bool get isLoggedIn => user != null && token != null;

  Future<void> login({required String email, required String password}) async {
    final response = await api.login(email: email, password: password);
    final userJson = response['user'] as Map<String, dynamic>?;
    final auth = response['authorisation'] as Map<String, dynamic>?;

    if (userJson == null || auth == null || auth['token'] == null) {
      throw Exception('Invalid login response');
    }

    user = AppUser.fromJson(userJson);
    token = auth['token'] as String;

    api.setToken(token);
    userDetail = await api.getUserDetail(userId: user!.id);

    notifyListeners();
  }

  void logout() {
    user = null;
    userDetail = null;
    token = null;
    api.setToken(null);
    notifyListeners();
  }
}
