import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/blocs/medicine/medicine_bloc.dart';
import 'package:patient_management_app/blocs/medicine/medicine_event.dart';
import 'package:patient_management_app/blocs/medicine/medicine_state.dart';
import 'package:patient_management_app/blocs/patient/patient_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_event.dart';
import 'package:patient_management_app/blocs/patient/patient_state.dart';
import 'package:patient_management_app/blocs/record/record_bloc.dart';
import 'package:patient_management_app/blocs/record/record_event.dart';
import 'package:patient_management_app/blocs/record/record_state.dart';
import 'package:patient_management_app/config/constants.dart';
import 'package:patient_management_app/models/medicine.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/models/prescribed_medicine.dart';
import 'package:patient_management_app/services/prescribed_medicine_service.dart';

class AddRecordScreen extends StatefulWidget {
  final int? patientId;

  const AddRecordScreen({super.key, this.patientId});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final PrescribedMedicineService _prescribedMedicineService = PrescribedMedicineService();

  final List<Map<String, dynamic>> _selectedMedicines = [];

  int? _selectedPatientId;
  String _doctorSpecialization = AppConstants.doctorSpecializations[0];
  final TextEditingController _vitalSignsController = TextEditingController();
  final TextEditingController _issuedDateController = TextEditingController();

  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _issuedDateController.text = _formatDate(_selectedDate);
    _selectedPatientId = widget.patientId;
  }

  @override
  void dispose() {
    _vitalSignsController.dispose();
    _issuedDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _issuedDateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _addMedicine(List<Medicine> medicines) {
    showDialog(
      context: context,
      builder: (context) {
        Medicine? selectedMedicine;
        String dose = '';
        int quantity = 1;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة دواء'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Medicine>(
                      decoration: const InputDecoration(
                        labelText: 'اختر دواءً',
                      ),
                      items: medicines.map((Medicine medicine) {
                        return DropdownMenuItem<Medicine>(
                          value: medicine,
                          child: Text('${medicine.name} (${medicine.dose})'),
                        );
                      }).toList(),
                      onChanged: (Medicine? value) {
                        setState(() {
                          selectedMedicine = value;
                          if (value != null) {
                            dose = value.dose;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'الجرعة',
                      ),
                      initialValue: dose,
                      onChanged: (value) {
                        dose = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('الكمية: '),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: quantity > 1
                              ? () {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              : null,
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: selectedMedicine == null
                      ? null
                      : () {
                          setState(() {
                            _selectedMedicines.add({
                              'medicine': selectedMedicine,
                              'dose': dose,
                              'quantity': quantity,
                            });
                          });
                          Navigator.pop(context);
                        },
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeMedicine(int index) {
    setState(() {
      _selectedMedicines.removeAt(index);
    });
  }

  Future<void> _saveRecord(BuildContext context) async {
    if (_selectedPatientId == null) {
      _showErrorSnackBar('يرجى اختيار مريض');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create record data
      final recordData = {
        'patientId': _selectedPatientId!,
        'doctorSpecialization': _doctorSpecialization,
        'vitalSigns': _vitalSignsController.text,
        'issuedDate': _issuedDateController.text,
      };

      // Dispatch event to create record
      context.read<RecordBloc>().add(RecordCreate(recordData));

      // Wait for the record to be created before proceeding
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the created record
      final recordState = context.mounted ? context.read<RecordBloc>().state : const RecordState();
      if (recordState.status == Status.success && recordState.selectedRecord != null) {
        // Create prescribed medicines
        for (var medicineData in _selectedMedicines) {
          final medicine = medicineData['medicine'] as Medicine;
          final prescribedMedicine = PrescribedMedicine(
            recordId: recordState.selectedRecord!.id!,
            medicineId: medicine.id!,
            medicineName: medicine.name,
            medicinePrice: medicine.price,
            dose: medicineData['dose'],
            quantity: medicineData['quantity'],
          );

          await _prescribedMedicineService.createPrescribedMedicine(prescribedMedicine);
        }

        if(context.mounted)  {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to create record');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar("خطأ بإنشاء السجل، حاول مجددًا");
      log('Failed to save record: ${e.toString()}');
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
          create: (context) => PatientBloc()..add(const PatientFetchAll()),
        ),
        BlocProvider(
          create: (context) => MedicineBloc()..add(const MedicineFetchAll()),
        ),
        BlocProvider(
          create: (context) => RecordBloc(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<RecordBloc, RecordState>(
            listener: (context, state) {
              if (state.status == Status.failure && state.failure != null) {
                _showErrorSnackBar(state.failure!.message);
                setState(() {
                  _isSaving = false;
                });
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('إضافة سجل صحي'),
              ),
              body: BlocBuilder<PatientBloc, PatientState>(
                builder: (context, patientState) {
                  return BlocBuilder<MedicineBloc, MedicineState>(
                    builder: (context, medicineState) {
                      final isLoading = patientState.status == Status.loading || medicineState.status == Status.loading;

                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final patients = patientState.patients;
                      final medicines = medicineState.medicines;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<int>(
                                value: _selectedPatientId,
                                decoration: const InputDecoration(
                                  labelText: 'اختر المريض',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                items: patients.map((Patient patient) {
                                  return DropdownMenuItem<int>(
                                    value: patient.id,
                                    child: Text(patient.fullName),
                                  );
                                }).toList(),
                                onChanged: widget.patientId != null
                                    ? null
                                    : (int? value) {
                                        setState(() {
                                          _selectedPatientId = value;
                                        });
                                      },
                                validator: (value) {
                                  if (value == null) {
                                    return 'يرجى اختيار مريض';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _doctorSpecialization,
                                decoration: const InputDecoration(
                                  labelText: 'تخصص الطبيب',
                                  prefixIcon: Icon(Icons.medical_services),
                                ),
                                items: AppConstants.doctorSpecializations.map((String specialization) {
                                  return DropdownMenuItem<String>(
                                    value: specialization,
                                    child: Text(specialization),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _doctorSpecialization = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _vitalSignsController,
                                decoration: const InputDecoration(
                                  labelText: 'المؤشرات الحيوية (اختياري)',
                                  prefixIcon: Icon(Icons.favorite),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _issuedDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى اختيار تاريخ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الأدوية الموصوفة',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _addMedicine(medicines),
                                    icon: const Icon(Icons.add),
                                    label: const Text('إضافة دواء'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _selectedMedicines.isEmpty
                                  ? const Card(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'لا يوجد أدوية حاليًا. اضغط على "إضافة دواء" للاختيار',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _selectedMedicines.length,
                                      itemBuilder: (context, index) {
                                        final medicineData = _selectedMedicines[index];
                                        final medicine = medicineData['medicine'] as Medicine;

                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            title: Text(medicine.name),
                                            subtitle: Text(
                                              'الجرعة: ${medicineData['dose']} • الكمية: ${medicineData['quantity']}',
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _removeMedicine(index),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _isSaving ? null : () => _saveRecord(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isSaving
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'حفظ السجل',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
