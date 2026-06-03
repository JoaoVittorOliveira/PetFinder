// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? phone;

  AppUser({required this.id, required this.email, this.name, this.phone});

  factory AppUser.fromSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      phone: user.userMetadata?['phone'] as String?,
    );
  }
}

class AuthController {
  static final AuthController instance = AuthController._internal();
  AuthController._internal();

  late final SupabaseClient _supabase;

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  void initialize(SupabaseClient supabase) {
    _supabase = supabase;
  }

  Future<void> init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final user = session.user;
      currentUser.value = AppUser.fromSupabaseUser(user);
    }
  }

  Future<bool> signUp(String email, String password, String? name) async {
    try {
      isLoadingNotifier.value = true;
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name ?? email.split('@')[0]},
      );

      if (response.user != null) {
        currentUser.value = AppUser.fromSupabaseUser(response.user!);
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no cadastro: $e');
      return false;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      isLoadingNotifier.value = true;
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        currentUser.value = AppUser.fromSupabaseUser(response.user!);
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      return false;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      currentUser.value = null;
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }
}
