import 'package:flutter/material.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/models/record.dart';
import 'package:patient_management_app/services/patient_service.dart';
import 'package:patient_management_app/services/record_service.dart';
import 'package:patient_management_app/screens/patients/add_edit_patient_screen.dart';
import 'package:patient_management_app/screens/records/add_record_screen.dart';
import 'package:patient_management_app/screens/records/record_detail_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final PatientService _patientService = PatientService();
  final RecordService _recordService = RecordService();
  
  Patient? _patient;
  List<Record> _records = [];
  bool _isLoading = true;
  bool _isLoadingRecords = true;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patient = await _patientService.getPatient(widget.patientId);
      setState(() {
        _patient = patient;
        _isLoading = false;
      });
      _loadRecords();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load patient: ${e.toString()}');
    }
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoadingRecords = true;
    });

    try {
      final records = await _recordService.getPatientRecords(widget.patientId);
      setState(() {
        _records = records;
        _isLoadingRecords = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRecords = false;
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
      appBar: AppBar(
        title: Text(_isLoading ? 'Patient Details' : _patient!.fullName),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditPatientScreen(patient: _patient),
                  ),
                ).then((_) => _loadPatient());
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientInfo(),
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medical Records',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Record'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddRecordScreen(patientId: widget.patientId),
                              ),
                            ).then((_) => _loadRecords());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRecordsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildPatientInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Personal Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _patient!.status == 'active' ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _patient!.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Age', '${_patient!.age} years'),
                  _buildInfoRow('Gender', _patient!.gender),
                  _buildInfoRow('Area', _patient!.area),
                  _buildInfoRow('Mobile', _patient!.mobileNumber),
                  if (_patient!.pastIllnesses.isNotEmpty)
                    _buildInfoRow('Past Illnesses', _patient!.pastIllnesses),
                  _buildInfoRow('Created', _patient!.createdAt),
                  _buildInfoRow('Last Updated', _patient!.updatedAt),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_isLoadingRecords) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No medical records found for this patient.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Visit: ${record.issuedDate}'),
            subtitle: Text(
              'Doctor: ${record.doctorSpecialization} • Medicines: ${record.totalGivenMedicines}',
            ),
            trailing: const Icon(Icons.chevron_right),
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
    );
  }
}
