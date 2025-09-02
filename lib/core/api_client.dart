import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: "https://bibliotecabackend.gigalixirapp.com/api",
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {"Content-Type": "application/json"},
        ),
      );

  Future<List<Map<String, dynamic>>> getLivros() async {
    try {
      final response = await dio.get('/livros');
      return (response.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception('Erro ao buscar livros: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getLivroById(String id) async {
    try {
      final response = await dio.get('/livros/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Erro ao buscar livro $id: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addLivro(Map<String, dynamic> livro) async {
    try {
      final response = await dio.post('/livros', data: livro);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Erro ao adicionar livro: ${e.message}');
    }
  }
}
