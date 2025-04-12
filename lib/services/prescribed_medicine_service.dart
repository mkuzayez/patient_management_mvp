import 'package:patient_management_app/models/prescribed_medicine.dart';
import 'package:patient_management_app/services/api_service.dart';

class PrescribedMedicineService {
  final ApiService _apiService = ApiService();
  
  Future<List<PrescribedMedicine>> getAllPrescribedMedicines() async {
    final response = await _apiService.get('prescribed-medicines/');
    final List<dynamic> data = response.data;
    return data.map((json) => PrescribedMedicine.fromJson(json)).toList();
  }
  
  Future<PrescribedMedicine> getPrescribedMedicine(int id) async {
    final response = await _apiService.get('prescribed-medicines/$id/');
    return PrescribedMedicine.fromJson(response.data);
  }
  
  Future<List<PrescribedMedicine>> getRecordPrescribedMedicines(int recordId) async {
    final response = await _apiService.get('prescribed-medicines/?record=$recordId');
    final List<dynamic> data = response.data;
    return data.map((json) => PrescribedMedicine.fromJson(json)).toList();
  }
  
  Future<PrescribedMedicine> createPrescribedMedicine(PrescribedMedicine prescribedMedicine) async {
    final response = await _apiService.post('prescribed-medicines/', prescribedMedicine.toJson());
    return PrescribedMedicine.fromJson(response.data);
  }
  
  Future<PrescribedMedicine> updatePrescribedMedicine(PrescribedMedicine prescribedMedicine) async {
    final response = await _apiService.put('prescribed-medicines/${prescribedMedicine.id}/', prescribedMedicine.toJson());
    return PrescribedMedicine.fromJson(response.data);
  }
  
  Future<void> deletePrescribedMedicine(int id) async {
    await _apiService.delete('prescribed-medicines/$id/');
  }
}
