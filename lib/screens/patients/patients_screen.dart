import 'package:flutter/material.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/services/patient_service.dart';
import 'package:patient_management_app/screens/patients/patient_detail_screen.dart';
import 'package:patient_management_app/screens/patients/add_edit_patient_screen.dart';
import 'package:patient_management_app/widgets/patient_card.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _patientService = PatientService();
  List<Patient> _patients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadPatients();
  }
  
  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final patients = await _patientService.getAllPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load patients: ${e.toString()}');
    }
  }
  
  Future<void> _searchPatients(String query) async {
    if (query.isEmpty) {
      _loadPatients();
      return;
    }
    
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    
    try {
      final patients = await _patientService.searchPatients(query);
      setState(() {
        _patients = patients;
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
                labelText: 'Search Patients',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchPatients(value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _patients.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No patients found'
                              : 'No patients match "$_searchQuery"',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPatients,
                        child: ListView.builder(
                          itemCount: _patients.length,
                          itemBuilder: (context, index) {
                            final patient = _patients[index];
                            return PatientCard(
                              patient: patient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailScreen(patientId: patient.id!),
                                  ),
                                ).then((_) => _loadPatients());
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
              builder: (context) => const AddEditPatientScreen(),
            ),
          ).then((_) => _loadPatients());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
