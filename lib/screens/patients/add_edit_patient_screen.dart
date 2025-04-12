import 'package:flutter/material.dart';
import 'package:patient_management_app/config/constants.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/services/patient_service.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;
  final int? patientId;

  const AddEditPatientScreen({super.key, this.patient, this.patientId});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final PatientService _patientService = PatientService();
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _pastIllnessesController = TextEditingController();
  
  String _gender = 'Male';
  String _status = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _fullNameController.text = widget.patient!.fullName;
      _ageController.text = widget.patient!.age.toString();
      _gender = widget.patient!.gender;
      _areaController.text = widget.patient!.area;
      _mobileNumberController.text = widget.patient!.mobileNumber;
      _pastIllnessesController.text = widget.patient!.pastIllnesses;
      _status = widget.patient!.status;
    } else if (widget.patientId != null) {
      _loadPatient();
    }
  }
  
  Future<void> _loadPatient() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final patient = await _patientService.getPatient(widget.patientId!);
      setState(() {
        _fullNameController.text = patient.fullName;
        _ageController.text = patient.age.toString();
        _gender = patient.gender;
        _areaController.text = patient.area;
        _mobileNumberController.text = patient.mobileNumber;
        _pastIllnessesController.text = patient.pastIllnesses;
        _status = patient.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load patient: ${e.toString()}');
    }
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

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patient = Patient(
        id: widget.patient?.id,
        fullName: _fullNameController.text,
        age: int.parse(_ageController.text),
        gender: _gender,
        area: _areaController.text,
        mobileNumber: _mobileNumberController.text,
        pastIllnesses: _pastIllnessesController.text,
        status: _status,
        createdAt: widget.patient?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      if (widget.patient == null) {
        await _patientService.createPatient(patient);
      } else {
        await _patientService.updatePatient(patient);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to save patient: ${e.toString()}');
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
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
      ),
      body: _isLoading
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
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) < 0 || int.parse(value) > 120) {
                          return 'Please enter a valid age (0-120)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
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
                        labelText: 'Area',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter area';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pastIllnessesController,
                      decoration: const InputDecoration(
                        labelText: 'Past Illnesses (Optional)',
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
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
                      onPressed: _savePatient,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.patient == null ? 'Add Patient' : 'Update Patient',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
