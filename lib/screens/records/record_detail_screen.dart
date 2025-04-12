import 'package:flutter/material.dart';
import 'package:patient_management_app/config/constants.dart';
import 'package:patient_management_app/models/record.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/services/record_service.dart';
import 'package:patient_management_app/services/patient_service.dart';
import 'package:patient_management_app/services/prescribed_medicine_service.dart';
import 'package:patient_management_app/models/prescribed_medicine.dart';

class RecordDetailScreen extends StatefulWidget {
  final int recordId;

  const RecordDetailScreen({super.key, required this.recordId});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  final RecordService _recordService = RecordService();
  final PatientService _patientService = PatientService();
  final PrescribedMedicineService _prescribedMedicineService = PrescribedMedicineService();
  
  Record? _record;
  Patient? _patient;
  List<PrescribedMedicine> _prescribedMedicines = [];
  bool _isLoading = true;
  bool _isLoadingMedicines = true;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final record = await _recordService.getRecord(widget.recordId);
      setState(() {
        _record = record;
        _isLoading = false;
      });
      _loadPatient(record.patientId);
      _loadPrescribedMedicines(widget.recordId);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load record: ${e.toString()}');
    }
  }

  Future<void> _loadPatient(int patientId) async {
    try {
      final patient = await _patientService.getPatient(patientId);
      setState(() {
        _patient = patient;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load patient: ${e.toString()}');
    }
  }

  Future<void> _loadPrescribedMedicines(int recordId) async {
    setState(() {
      _isLoadingMedicines = true;
    });

    try {
      final medicines = await _prescribedMedicineService.getRecordPrescribedMedicines(recordId);
      setState(() {
        _prescribedMedicines = medicines;
        _isLoadingMedicines = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicines = false;
      });
      _showErrorSnackBar('Failed to load prescribed medicines: ${e.toString()}');
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
        title: Text(_isLoading ? 'Record Details' : 'Record: ${_record!.issuedDate}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecordInfo(),
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Prescribed Medicines',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPrescribedMedicinesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildRecordInfo() {
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
                  Text(
                    'Record Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Patient', _patient?.fullName ?? 'Loading...'),
                  _buildInfoRow('Doctor', _record!.doctorSpecialization),
                  _buildInfoRow('Date', _record!.issuedDate),
                  if (_record!.vitalSigns.isNotEmpty)
                    _buildInfoRow('Vital Signs', _record!.vitalSigns),
                  _buildInfoRow('Created', _record!.createdAt),
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

  Widget _buildPrescribedMedicinesList() {
    if (_isLoadingMedicines) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_prescribedMedicines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No medicines prescribed in this record.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prescribedMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _prescribedMedicines[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        medicine.medicineName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Qty: ${medicine.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Dose: ${medicine.dose}'),
                const SizedBox(height: 4),
                Text('Price: \$${medicine.medicinePrice.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Text(
                  'Total: \$${(medicine.medicinePrice * medicine.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
