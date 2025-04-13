import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/blocs/patient/patient_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_event.dart';
import 'package:patient_management_app/blocs/patient/patient_state.dart';
import 'package:patient_management_app/blocs/record/record_bloc.dart';
import 'package:patient_management_app/blocs/record/record_event.dart';
import 'package:patient_management_app/blocs/record/record_state.dart';
import 'package:patient_management_app/models/prescribed_medicine.dart';
import 'package:patient_management_app/models/record.dart';
import 'package:patient_management_app/services/prescribed_medicine_service.dart';

class RecordDetailScreen extends StatefulWidget {
  final int recordId;

  const RecordDetailScreen({super.key, required this.recordId});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  final PrescribedMedicineService _prescribedMedicineService = PrescribedMedicineService();

  List<PrescribedMedicine> _prescribedMedicines = [];
  bool _isLoadingMedicines = true;

  @override
  void initState() {
    super.initState();
    _loadPrescribedMedicines(widget.recordId);
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
      _showErrorSnackBar('خطأ بتحميل الأدوية، يرجى المحاولة مجددًا');
      log('Failed to load prescribed medicines: ${e.toString()}');
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecordBloc()..add(RecordFetchOne(widget.recordId)),
        ),
        BlocProvider(
          create: (context) => PatientBloc(),
        ),
      ],
      child: BlocConsumer<RecordBloc, RecordState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.failure != null) {
            _showErrorSnackBar(state.failure!.message);
          }

          // When record is loaded, fetch the patient details
          if (state.status == Status.success && state.selectedRecord != null) {
            context.read<PatientBloc>().add(PatientFetchOne(state.selectedRecord!.patientId));
          }
        },
        builder: (context, recordState) {
          final isLoading = recordState.status == Status.loading;
          final record = recordState.selectedRecord;

          return Scaffold(
            appBar: AppBar(
              title: Text(isLoading ? 'تفاصيل السجل' : 'السجل: ${record?.issuedDate ?? ""}'),
            ),
            body: isLoading || record == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRecordInfo(record),
                        const Divider(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'الأدوية الموصوفة',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPrescribedMedicinesList(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildRecordInfo(Record record) {
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
                    'تفاصيل السجل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<PatientBloc, PatientState>(
                    builder: (context, patientState) {
                      final patient = patientState.selectedPatient;
                      final patientName = patient?.fullName ?? 'Loading...';
                      return _buildInfoRow('Patient', patientName);
                    },
                  ),
                  _buildInfoRow('الطبيب', record.doctorSpecialization),
                  _buildInfoRow('التاريخ', record.issuedDate),
                  if (record.vitalSigns.isNotEmpty) _buildInfoRow('المؤشرات الحيوية', record.vitalSigns),
                  _buildInfoRow('انشأت بتاريخ', record.createdAt),
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
          child: Text('لا يوجد أدوية موصوفة بهذا السجل'),
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
                      'الكمية: ${medicine.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('الجرعة: ${medicine.dose}'),
                const SizedBox(height: 4),
                Text('السعر: \$${medicine.medicinePrice.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Text(
                  'المجموع: \$${(medicine.medicinePrice * medicine.quantity).toStringAsFixed(2)}',
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
