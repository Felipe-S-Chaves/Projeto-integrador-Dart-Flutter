import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<void> login(String email, String password) async {
    // Validação básica
    if (email.trim().isEmpty) {
      throw Exception('Email é obrigatório');
    }
    if (password.trim().isEmpty) {
      throw Exception('Senha é obrigatória');
    }
    if (!email.contains('@')) {
      throw Exception('Email deve ter um formato válido');
    }

    final res = await _dio.post(
      '/auth/login',
      data: {'email': email.trim(), 'password': password.trim()},
    );
    final data = res.data;
    final token = data['token'] ?? data['access_token'];
    final role = data['user']?['role'] ?? data['role'] ?? 'user';

    if (token == null || token.isEmpty) {
      throw Exception('Token não recebido do servidor');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('email', email.trim());
  }

  Future<void> register(String email, String password, String role) async {
    // Validação básica
    if (email.trim().isEmpty) {
      throw Exception('Email é obrigatório');
    }
    if (password.trim().isEmpty) {
      throw Exception('Senha é obrigatória');
    }
    if (password.trim().length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }
    if (!email.contains('@')) {
      throw Exception('Email deve ter um formato válido');
    }
    if (role.trim().isEmpty) {
      throw Exception('Role é obrigatório');
    }

    await _dio.post(
      '/auth/register',
      data: {
        'email': email.trim(),
        'password': password.trim(),
        'role': role.trim(),
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('email');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}
