// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AppUser {
  final String id;
  final String name;
  final String phone;
  AppUser({required this.id, required this.name, required this.phone});
}

class AuthController {
  /* 
  static final AuthController instance = AuthController._internal();
  AuthController._internal();

  final DatabaseService _database = DatabaseService.instance;

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  final List<AppUser> mockUsers = [
    AppUser(id: '1', name: 'João Silva', phone: '(11) 98888-1111'),
    AppUser(id: '2', name: 'Maria Souza', phone: '(21) 97777-2222'),
  ];

  
  Future<void> init() async {
    final sessionData = await _database.getSession();
    if (sessionData != null) {
      currentUser.value = getUserById(sessionData['id'] as String);
    }
  }

  Future<void> login(AppUser user) async {
    await _database.saveSession(user.id, user.name);
    currentUser.value = user;
  }

  Future<void> logout() async {
    await _database.clearSession();
    currentUser.value = null;
  }

  AppUser? getUserById(String id) {
    try {
      return mockUsers.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
  */
}
