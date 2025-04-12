import 'package:flutter/material.dart';
import 'package:patient_management_app/config/constants.dart';
import 'package:patient_management_app/models/record.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/models/medicine.dart';
import 'package:patient_management_app/models/prescribed_medicine.dart';
import 'package:patient_management_app/services/record_service.dart';
import 'package:patient_management_app/services/patient_service.dart';
import 'package:patient_management_app/services/medicine_service.dart';
import 'package:patient_management_app/services/prescribed_medicine_service.dart';

class AddRecordScreen extends StatefulWidget {
  final int? patientId;

  const AddRecordScreen({super.key, this.patientId});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final RecordService _recordService = RecordService();
  final PatientService _patientService = PatientService();
  final MedicineService _medicineService = MedicineService();
  final PrescribedMedicineService _prescribedMedicineService = PrescribedMedicineService();
  
  List<Patient> _patients = [];
  List<Medicine> _medicines = [];
  List<Map<String, dynamic>> _selectedMedicines = [];
  
  int? _selectedPatientId;
  String _doctorSpecialization = AppConstants.doctorSpecializations[0];
  final TextEditingController _vitalSignsController = TextEditingController();
  final TextEditingController _issuedDateController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _issuedDateController.text = _formatDate(_selectedDate);
    _selectedPatientId = widget.patientId;
    _loadData();
  }

  @override
  void dispose() {
    _vitalSignsController.dispose();
    _issuedDateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patients = await _patientService.getAllPatients();
      final medicines = await _medicineService.getAllMedicines();
      
      setState(() {
        _patients = patients;
        _medicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load data: ${e.toString()}');
    }
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

  void _addMedicine() {
    showDialog(
      context: context,
      builder: (context) {
        Medicine? selectedMedicine;
        String dose = '';
        int quantity = 1;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Medicine'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Medicine>(
                      decoration: const InputDecoration(
                        labelText: 'Select Medicine',
                      ),
                      items: _medicines.map((Medicine medicine) {
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
                        labelText: 'Dose',
                      ),
                      initialValue: dose,
                      onChanged: (value) {
                        dose = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Quantity: '),
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
                  child: const Text('Cancel'),
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
                  child: const Text('Add'),
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

  Future<void> _saveRecord() async {
    if (_selectedPatientId == null) {
      _showErrorSnackBar('Please select a patient');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create record
      final record = Record(
        patientId: _selectedPatientId!,
        doctorSpecialization: _doctorSpecialization,
        vitalSigns: _vitalSignsController.text,
        issuedDate: _issuedDateController.text,
        createdAt: DateTime.now().toIso8601String(),
      );

      final createdRecord = await _recordService.createRecord(record);

      // Create prescribed medicines
      for (var medicineData in _selectedMedicines) {
        final medicine = medicineData['medicine'] as Medicine;
        final prescribedMedicine = PrescribedMedicine(
          recordId: createdRecord.id!,
          medicineId: medicine.id!,
          medicineName: medicine.name,
          medicinePrice: medicine.price,
          dose: medicineData['dose'],
          quantity: medicineData['quantity'],
        );

        await _prescribedMedicineService.createPrescribedMedicine(prescribedMedicine);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar('Failed to save record: ${e.toString()}');
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
        title: const Text('Add Medical Record'),
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
                    DropdownButtonFormField<int>(
                      value: _selectedPatientId,
                      decoration: const InputDecoration(
                        labelText: 'Select Patient',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _patients.map((Patient patient) {
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
                          return 'Please select a patient';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _doctorSpecialization,
                      decoration: const InputDecoration(
                        labelText: 'Doctor Specialization',
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
                        labelText: 'Vital Signs (Optional)',
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
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prescribed Medicines',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ElevatedButton.icon(
                          onPressed: _addMedicine,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Medicine'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _selectedMedicines.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No medicines added yet. Click "Add Medicine" to prescribe medicines.',
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
                                    'Dose: ${medicineData['dose']} • Qty: ${medicineData['quantity']}',
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
                      onPressed: _isSaving ? null : _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Record',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
