import 'package:flutter/material.dart';
import 'package:patient_management_app/models/medicine.dart';
import 'package:patient_management_app/services/medicine_service.dart';
import 'package:patient_management_app/screens/medicines/add_edit_medicine_screen.dart';
import 'package:patient_management_app/widgets/medicine_card.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final MedicineService _medicineService = MedicineService();
  List<Medicine> _medicines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }
  
  Future<void> _loadMedicines() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final medicines = await _medicineService.getAllMedicines();
      setState(() {
        _medicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load medicines: ${e.toString()}');
    }
  }
  
  Future<void> _searchMedicines(String query) async {
    if (query.isEmpty) {
      _loadMedicines();
      return;
    }
    
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    
    try {
      final medicines = await _medicineService.searchMedicines(query);
      setState(() {
        _medicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Search failed: ${e.toString()}');
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Medicines',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchMedicines(value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _medicines.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No medicines found'
                              : 'No medicines match "$_searchQuery"',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMedicines,
                        child: ListView.builder(
                          itemCount: _medicines.length,
                          itemBuilder: (context, index) {
                            final medicine = _medicines[index];
                            return MedicineCard(
                              medicine: medicine,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditMedicineScreen(medicine: medicine),
                                  ),
                                ).then((_) => _loadMedicines());
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditMedicineScreen(),
            ),
          ).then((_) => _loadMedicines());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
