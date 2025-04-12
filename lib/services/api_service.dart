import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://8000-ix1z12det6kgatbqm8i1i-8a678df9.manus.computer/api';

  ApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Response> get(String endpoint) async {
    try {
      final response = await _dio.get('$baseUrl/$endpoint');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post('$baseUrl/$endpoint', data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put('$baseUrl/$endpoint', data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete('$baseUrl/$endpoint');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    String errorMessage = 'An error occurred';
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.badResponse) {
      errorMessage = 'Server error: ${error.response?.statusCode}';
      if (error.response?.data != null && error.response?.data is Map) {
        final data = error.response?.data as Map;
        if (data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      }
    } else {
      errorMessage = 'Network error: ${error.message}';
    }
    
    return Exception(errorMessage);
  }
}
