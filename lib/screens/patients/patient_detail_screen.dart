import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_event.dart';
import 'package:patient_management_app/blocs/patient/patient_state.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/models/record.dart';
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
  final RecordService _recordService = RecordService();
  
  List<Record> _records = [];
  bool _isLoadingRecords = true;

  @override
  void initState() {
    super.initState();
    // _loadRecords();
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
      _showErrorSnackBar('خطأ بتحميل السجلات، يرجى المحاولة مجددًا');
      log('Failed to load records: ${e.toString()}');
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
    return BlocProvider(
      create: (context) => PatientBloc()..add(PatientFetchOne(widget.patientId)),
      child: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.failure != null) {
            _showErrorSnackBar(state.failure!.message);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;
          final patient = state.selectedPatient;

          return Scaffold(
            appBar: AppBar(
              title: Text(isLoading ? 'بيانات المريض' : patient?.fullName ?? 'بيانات المريض'),
              actions: [
                if (!isLoading && patient != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditPatientScreen(patient: patient),
                        ),
                      ).then((_) {
                        if(context.mounted) context.read<PatientBloc>().add(PatientFetchOne(widget.patientId));
                        _loadRecords();
                      });
                    },
                  ),
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : patient == null
                    ? const Center(child: Text('المريض غير موجود'))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPatientInfo(context, patient),
                            const Divider(height: 32),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'السجلات الطبية',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('إضافة سجل'),
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
        },
      ),
    );
  }

  Widget _buildPatientInfo(BuildContext context, Patient patient) {
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
                        'المعلومات الشخصية',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (patient.status != null) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: patient.status == 'active' ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          patient.status!.toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('العمر', '${patient.age} سنة'),
                  _buildInfoRow('الجنس', patient.gender == 'male' ? 'ذكر' : (patient.gender == 'female' ? 'أنثى' : "")),
                  if (patient.area != null) _buildInfoRow('العنوان', patient.area!),
                  if (patient.mobileNumber != null) _buildInfoRow('رقم الهاتف', patient.mobileNumber!),
                  if (patient.pastIllnesses != null) _buildInfoRow('أمراض سابقة', patient.pastIllnesses!),
                  // _buildInfoRow('Created', patient.createdAt.toString()),
                  // _buildInfoRow('Last Updated', patient.updatedAt.toString()),
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Flexible(
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
          child: Text('لا يوجد سجلات طبية لهذا المريض.'),
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
            title: Text('تاريخ الزيارة: ${record.issuedDate}'),
            subtitle: Text(
              'الطبيب: ${record.doctorSpecialization} • الأدوية: ${record.totalGivenMedicines}',
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
