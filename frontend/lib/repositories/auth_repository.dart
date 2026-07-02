import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const String _userKey = 'logged_in_user';
  static const String _usersDbKey = 'users_database';
  static const String _selectedZoneKey = 'selected_railway_zone';

  // Seed default admin and user for easy testing
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_usersDbKey)) {
      final defaultUsers = [
        UserModel(
          id: 'admin_1',
          name: 'Railway Admin',
          email: 'admin@wr.gov.in',
          role: 'admin',
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: 'user_1',
          name: 'Zainab',
          email: 'user@wr.gov.in',
          role: 'user',
          zone: 'Western Railway',
          createdAt: DateTime.now(),
        ),
      ];

      final usersJson = defaultUsers.map((u) => u.toJson()).toList();
      await prefs.setString(_usersDbKey, jsonEncode(usersJson));
    }
  }

  Future<List<UserModel>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_usersDbKey);
    if (usersStr == null) return [];
    final List<dynamic> decoded = jsonDecode(usersStr);
    return decoded.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<UserModel?> login(String email, String password) async {
    await init();
    final users = await _getUsers();
    
    // Find matching user (mock password matches if it's not empty)
    try {
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );
      
      // Save logged in user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      // If user has a pre-selected zone, save it too
      if (user.zone != null) {
        await saveSelectedZone(user.zone!);
      }
      
      return user;
    } catch (_) {
      return null; // User not found
    }
  }

  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? zone,
  }) async {
    await init();
    final users = await _getUsers();
    
    if (users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase())) {
      throw Exception('Email already registered');
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: role,
      zone: zone,
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersDbKey, jsonEncode(users.map((u) => u.toJson()).toList()));
    
    // Auto-login
    await prefs.setString(_userKey, jsonEncode(newUser.toJson()));
    if (zone != null) {
      await saveSelectedZone(zone);
    }
    
    return newUser;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    return UserModel.fromJson(jsonDecode(userStr));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_selectedZoneKey);
  }

  Future<void> saveSelectedZone(String zone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedZoneKey, zone);
    
    // Also update current logged in user's zone if applicable
    final user = await getCurrentUser();
    if (user != null && user.role == 'user') {
      final updatedUser = user.copyWith(zone: zone);
      await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
      
      // Update in database too
      final users = await _getUsers();
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
        await prefs.setString(_usersDbKey, jsonEncode(users.map((u) => u.toJson()).toList()));
      }
    }
  }

  Future<String?> getSelectedZone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedZoneKey);
  }
}
