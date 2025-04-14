import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/services/api_service.dart';

class PatientService {
  final ApiService _apiService = ApiService();
  
  Future<List<Patient>> getAllPatients() async {
    final response = await _apiService.get('patients/');
    final data = response.data['results'] as List<dynamic>;
    return data.map((json) => Patient.fromJson(json)).toList();
  }
  
  Future<Patient> getPatient(int id) async {
    final response = await _apiService.get('patients/$id/');
    return Patient.fromJson(response.data);
  }
  
  Future<List<Patient>> searchPatients(String query) async {
    final response = await _apiService.get('patients/?search=$query');
    final data = response.data['results'] as List<dynamic>;
    return data.map((json) => Patient.fromJson(json)).toList();
  }
  
  Future<Patient> createPatient(Patient patient) async {
    final response = await _apiService.post('patients/', patient.toJson());
    return Patient.fromJson(response.data);
  }
  
  Future<Patient> updatePatient(Patient patient) async {
    final response = await _apiService.put('patients/${patient.id}/', patient.toJson());
    return Patient.fromJson(response.data);
  }
  
  Future<void> deletePatient(int id) async {
    await _apiService.delete('patients/$id/');
  }
}
