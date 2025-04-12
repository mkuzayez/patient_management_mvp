import 'package:flutter/material.dart';
import 'package:patient_management_app/models/record.dart';
import 'package:patient_management_app/services/record_service.dart';
import 'package:patient_management_app/screens/records/add_record_screen.dart';
import 'package:patient_management_app/screens/records/record_detail_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final RecordService _recordService = RecordService();
  List<Record> _records = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }
  
  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final records = await _recordService.getAllRecords();
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load records: ${e.toString()}');
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No medical records found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddRecordScreen(),
                            ),
                          ).then((_) => _loadRecords());
                        },
                        child: const Text('Add New Record'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecords,
                  child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text('Patient ID: ${record.patientId}'),
                          subtitle: Text(
                            'Date: ${record.issuedDate} • Doctor: ${record.doctorSpecialization}',
                          ),
                          trailing: Text('Medicines: ${record.totalGivenMedicines}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecordDetailScreen(recordId: record.id!),
                              ),
                            ).then((_) => _loadRecords());
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecordScreen(),
            ),
          ).then((_) => _loadRecords());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
