import 'package:patient_management_app/models/medicine.dart';
import 'package:patient_management_app/services/api_service.dart';

class MedicineService {
  final ApiService _apiService = ApiService();
  
  Future<List<Medicine>> getAllMedicines() async {
    final response = await _apiService.get('medicines/');
    final List<dynamic> data = response.data;
    return data.map((json) => Medicine.fromJson(json)).toList();
  }
  
  Future<Medicine> getMedicine(int id) async {
    final response = await _apiService.get('medicines/$id/');
    return Medicine.fromJson(response.data);
  }
  
  Future<List<Medicine>> searchMedicines(String query) async {
    final response = await _apiService.get('medicines/?search=$query');
    final List<dynamic> data = response.data;
    return data.map((json) => Medicine.fromJson(json)).toList();
  }
  
  Future<Medicine> createMedicine(Medicine medicine) async {
    final response = await _apiService.post('medicines/', medicine.toJson());
    return Medicine.fromJson(response.data);
  }
  
  Future<Medicine> updateMedicine(Medicine medicine) async {
    final response = await _apiService.put('medicines/${medicine.id}/', medicine.toJson());
    return Medicine.fromJson(response.data);
  }
  
  Future<void> deleteMedicine(int id) async {
    await _apiService.delete('medicines/$id/');
  }
}
