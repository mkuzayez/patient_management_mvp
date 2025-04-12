import 'package:patient_management_app/models/record.dart';
import 'package:patient_management_app/services/api_service.dart';

class RecordService {
  final ApiService _apiService = ApiService();
  
  Future<List<Record>> getAllRecords() async {
    final response = await _apiService.get('records/');
    final List<dynamic> data = response.data;
    return data.map((json) => Record.fromJson(json)).toList();
  }
  
  Future<Record> getRecord(int id) async {
    final response = await _apiService.get('records/$id/');
    return Record.fromJson(response.data);
  }
  
  Future<List<Record>> getPatientRecords(int patientId) async {
    final response = await _apiService.get('records/?patient=$patientId');
    final List<dynamic> data = response.data;
    return data.map((json) => Record.fromJson(json)).toList();
  }
  
  Future<Record> createRecord(Record record) async {
    final response = await _apiService.post('records/', record.toJson());
    return Record.fromJson(response.data);
  }
  
  Future<Record> updateRecord(Record record) async {
    final response = await _apiService.put('records/${record.id}/', record.toJson());
    return Record.fromJson(response.data);
  }
  
  Future<void> deleteRecord(int id) async {
    await _apiService.delete('records/$id/');
  }
  
  Future<List<dynamic>> getPrescribedMedicines(int recordId) async {
    final response = await _apiService.get('records/$recordId/prescribed_medicines/');
    return response.data;
  }
}
