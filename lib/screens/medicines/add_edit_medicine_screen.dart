import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/medicine/medicine_bloc.dart';
import 'package:patient_management_app/blocs/medicine/medicine_event.dart';
import 'package:patient_management_app/blocs/medicine/medicine_state.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/models/medicine.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  final int? medicineId;

  const AddEditMedicineScreen({super.key, this.medicine, this.medicineId});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _scientificNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _initializeFormWithMedicine(widget.medicine!);
      _isInitialized = true;
    }
  }
  
  void _initializeFormWithMedicine(Medicine medicine) {
    _nameController.text = medicine.name;
    _doseController.text = medicine.dose;
    _scientificNameController.text = medicine.scientificName;
    _companyController.text = medicine.company;
    _priceController.text = medicine.price.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _scientificNameController.dispose();
    _companyController.dispose();
    _priceController.dispose();
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
        final bloc = MedicineBloc();
        if (widget.medicineId != null && widget.medicine == null) {
          bloc.add(MedicineFetchOne(widget.medicineId!));
        }
        return bloc;
      },
      child: BlocConsumer<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.failure != null) {
            _showErrorSnackBar(state.failure!.message);
          }
          
          if (state.status == Status.success) {
            // If we're fetching a medicine
            if (state.selectedMedicine != null && !_isInitialized && widget.medicine == null) {
              _initializeFormWithMedicine(state.selectedMedicine!);
              _isInitialized = true;
            }
            
            // If we've successfully created or updated a medicine
            if (state.status == Status.success && 
                (state.selectedMedicine?.id != null) && 
                (widget.medicine != null || _isInitialized)) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;
          final isEditing = widget.medicine != null || 
                           (state.selectedMedicine != null && widget.medicineId != null);
          
          return Scaffold(
            appBar: AppBar(
              title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
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
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Medicine Name',
                              prefixIcon: Icon(Icons.medication),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter medicine name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _doseController,
                            decoration: const InputDecoration(
                              labelText: 'Dose',
                              prefixIcon: Icon(Icons.medical_services),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter dose';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _scientificNameController,
                            decoration: const InputDecoration(
                              labelText: 'Scientific Name (Optional)',
                              prefixIcon: Icon(Icons.science),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _companyController,
                            decoration: const InputDecoration(
                              labelText: 'Company (Optional)',
                              prefixIcon: Icon(Icons.business),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (double.parse(value) < 0) {
                                return 'Price cannot be negative';
                              }
                              return null;
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
                                    
                                    final medicineData = {
                                      'name': _nameController.text,
                                      'dose': _doseController.text,
                                      'scientificName': _scientificNameController.text,
                                      'company': _companyController.text,
                                      'price': double.parse(_priceController.text),
                                    };
                                    
                                    if (isEditing) {
                                      final medicineId = widget.medicine?.id ?? 
                                                       state.selectedMedicine?.id ?? 
                                                       widget.medicineId!;
                                      context.read<MedicineBloc>().add(
                                        MedicineUpdate(medicineId, medicineData),
                                      );
                                    } else {
                                      context.read<MedicineBloc>().add(
                                        MedicineCreate(medicineData),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              isEditing ? 'Update Medicine' : 'Add Medicine',
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
