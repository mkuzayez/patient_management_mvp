import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_bloc.dart';
import 'package:patient_management_app/blocs/patient/patient_event.dart';
import 'package:patient_management_app/blocs/patient/patient_state.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/config/constants.dart';
import 'package:patient_management_app/models/patient.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;
  final int? patientId;

  const AddEditPatientScreen({super.key, this.patient, this.patientId});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _pastIllnessesController = TextEditingController();
  
  String _gender = 'ذكر';
  String _status = 'فعال';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _initializeFormWithPatient(widget.patient!);
      _isInitialized = true;
    }
  }
  
  void _initializeFormWithPatient(Patient patient) {
    _fullNameController.text = patient.fullName;
    _ageController.text = patient.age.toString();
    _gender = patient.gender ?? "";
    _areaController.text = patient.area ?? "";
    _mobileNumberController.text = patient.mobileNumber ?? "";
    _pastIllnessesController.text = patient.pastIllnesses ?? "";
    _status = patient.status ?? "";
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _areaController.dispose();
    _mobileNumberController.dispose();
    _pastIllnessesController.dispose();
    super.dispose();
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
      create: (context) {
        final bloc = PatientBloc();
        if (widget.patientId != null && widget.patient == null) {
          bloc.add(PatientFetchOne(widget.patientId!));
        }
        return bloc;
      },
      child: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.failure != null) {
            _showErrorSnackBar(state.failure!.message);
          }
          
          if (state.status == Status.success) {
            // If we're fetching a patient
            if (state.selectedPatient != null && !_isInitialized && widget.patient == null) {
              _initializeFormWithPatient(state.selectedPatient!);
              _isInitialized = true;
            }
            
            // If we've successfully created or updated a patient
            if (state.status == Status.success && 
                (state.selectedPatient?.id != null) && 
                (widget.patient != null || _isInitialized)) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;
          final isEditing = widget.patient != null || 
                           (state.selectedPatient != null && widget.patientId != null);
          
          return Scaffold(
            appBar: AppBar(
              title: Text(isEditing ? 'تعديل بيانات المريض' : 'إضافة مريض'),
            ),
            body: isLoading && !_isInitialized
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'الاسم الكامل',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال اسم المريض';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'العمر',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال العمر';
                              }
                              if (int.tryParse(value) == null) {
                                return 'يرجى إدخال عمر صالح';
                              }
                              if (int.parse(value) < 0 || int.parse(value) > 120) {
                                return 'يرجى إدخال عمر صالح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                              labelText: 'الجنس',
                              prefixIcon: Icon(Icons.people),
                            ),
                            items: AppConstants.genderOptions.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _gender = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _areaController,
                            decoration: const InputDecoration(
                              labelText: 'العنوان',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال العنوان';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mobileNumberController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الهاتف',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _pastIllnessesController,
                            decoration: const InputDecoration(
                              labelText: 'أمراض سابقة (اختياري)',
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'الحالة الإجتماعية',
                              prefixIcon: Icon(Icons.check_circle),
                            ),
                            items: AppConstants.patientStatusOptions.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _status = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: isLoading 
                                ? null 
                                : () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    
                                    final patientData = {
                                      'fullName': _fullNameController.text,
                                      'age': int.parse(_ageController.text),
                                      'gender': _gender,
                                      'area': _areaController.text,
                                      'mobileNumber': _mobileNumberController.text,
                                      'pastIllnesses': _pastIllnessesController.text,
                                      'status': _status,
                                    };
                                    
                                    if (isEditing) {
                                      final patientId = widget.patient?.id ?? 
                                                       state.selectedPatient?.id ?? 
                                                       widget.patientId!;
                                      context.read<PatientBloc>().add(
                                        PatientUpdate(patientId, patientData),
                                      );
                                    } else {
                                      context.read<PatientBloc>().add(
                                        PatientCreate(patientData),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              isEditing ? 'تحديث بيانات المريض' : 'إضافة مريض',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
