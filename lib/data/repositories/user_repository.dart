import 'package:dio/dio.dart';
import '../models/user.dart';
import 'package:flutter_application_1/core/api_client.dart';

class UserRepository {
  final Dio _dio;

  UserRepository({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<List<AppUser>> list() async {
    final res = await _dio.get('/users');
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(AppUser.fromJson).toList();
  }

  Future<AppUser> getById(String id) async {
    final res = await _dio.get('/users/$id');
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AppUser> update(
    String id, {
    required String email,
    required String role,
  }) async {
    // Validação básica
    if (email.trim().isEmpty) {
      throw Exception('Email é obrigatório');
    }
    if (!email.contains('@')) {
      throw Exception('Email deve ter um formato válido');
    }
    if (role.trim().isEmpty) {
      throw Exception('Role é obrigatório');
    }

    final res = await _dio.put(
      '/users/$id',
      data: {
        'user': {'email': email.trim(), 'role': role.trim()},
      },
    );
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/users/$id');
  }
}
