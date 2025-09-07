import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: "https://bibliotecabackend.gigalixirapp.com/api",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {"Content-Type": "application/json"},
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Interceptor para adicionar token de autenticação
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  void _handleError(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        throw Exception('Dados inválidos enviados para o servidor');
      case 401:
        throw Exception('Não autorizado. Faça login novamente.');
      case 403:
        throw Exception(
          'Acesso negado. Você não tem permissão para esta ação.',
        );
      case 404:
        throw Exception('Recurso não encontrado');
      case 422:
        final responseData = error.response?.data;
        if (responseData is Map<String, dynamic>) {
          final errors = responseData['errors'] ?? responseData['message'];
          if (errors is Map<String, dynamic>) {
            final errorMessages = errors.values
                .expand((e) => e is List ? e : [e])
                .map((e) => e.toString())
                .join(', ');
            throw Exception('Erro de validação: $errorMessages');
          } else if (errors is String) {
            throw Exception('Erro de validação: $errors');
          }
        }
        throw Exception('Dados inválidos. Verifique os campos obrigatórios.');
      case 500:
        throw Exception(
          'Erro interno do servidor. Tente novamente mais tarde.',
        );
      default:
        throw Exception('Erro de conexão: ${error.message}');
    }
  }

  Future<List<Map<String, dynamic>>> getLivros() async {
    final response = await dio.get('/livros');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getLivroById(String id) async {
    final response = await dio.get('/livros/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addLivro(Map<String, dynamic> livro) async {
    final response = await dio.post('/livros', data: livro);
    return response.data as Map<String, dynamic>;
  }
}
