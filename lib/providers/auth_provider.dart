import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userToken;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  String? get userName => _userName;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userToken = prefs.getString('userToken');
    _userName = prefs.getString('userName');
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    // Mock login logic
    if (username == 'admin' && password == 'password') {
      _isAuthenticated = true;
      _userToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _userName = username;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userToken', _userToken!);
      await prefs.setString('userName', _userName!);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userToken = null;
    _userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
