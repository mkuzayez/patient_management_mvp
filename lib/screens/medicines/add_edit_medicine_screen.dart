import 'package:flutter/material.dart';
import 'package:patient_management_app/models/medicine.dart';
import 'package:patient_management_app/services/medicine_service.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  final int? medicineId;

  const AddEditMedicineScreen({super.key, this.medicine, this.medicineId});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final MedicineService _medicineService = MedicineService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _scientificNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _doseController.text = widget.medicine!.dose;
      _scientificNameController.text = widget.medicine!.scientificName;
      _companyController.text = widget.medicine!.company;
      _priceController.text = widget.medicine!.price.toString();
    } else if (widget.medicineId != null) {
      _loadMedicine();
    }
  }
  
  Future<void> _loadMedicine() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final medicine = await _medicineService.getMedicine(widget.medicineId!);
      setState(() {
        _nameController.text = medicine.name;
        _doseController.text = medicine.dose;
        _scientificNameController.text = medicine.scientificName;
        _companyController.text = medicine.company;
        _priceController.text = medicine.price.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load medicine: ${e.toString()}');
    }
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

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final medicine = Medicine(
        id: widget.medicine?.id,
        name: _nameController.text,
        dose: _doseController.text,
        scientificName: _scientificNameController.text,
        company: _companyController.text,
        price: double.parse(_priceController.text),
      );

      if (widget.medicine == null) {
        await _medicineService.createMedicine(medicine);
      } else {
        await _medicineService.updateMedicine(medicine);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to save medicine: ${e.toString()}');
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
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
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
                      onPressed: _saveMedicine,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.medicine == null ? 'Add Medicine' : 'Update Medicine',
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
