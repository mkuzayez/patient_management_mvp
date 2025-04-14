import 'package:dio/dio.dart';
import 'package:patient_management_app/models/medicine.dart';
import 'package:patient_management_app/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Response> login({required String username, required String password}) async {
    final response = await _apiService.post('login/', {"username": username, "password": password});
    return response;
  }

}
