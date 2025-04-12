class ApiConstants {
  // Base URL - Change this when deploying to production
  static const String baseUrl = 'http://8000-ix1z12det6kgatbqm8i1i-8a678df9.manus.computer/api';
  
  // Endpoints
  static const String patientsEndpoint = 'patients/';
  static const String medicinesEndpoint = 'medicines/';
  static const String recordsEndpoint = 'records/';
  static const String prescribedMedicinesEndpoint = 'prescribed-medicines/';
  
  // Timeouts
  static const int connectionTimeout = 5000; // milliseconds
  static const int receiveTimeout = 3000; // milliseconds
}

class AppConstants {
  // App name
  static const String appName = 'Patient Management';
  
  // Status options
  static const List<String> patientStatusOptions = ['active', 'inactive'];
  
  // Gender options
  static const List<String> genderOptions = ['Male', 'Female', 'Other'];
  
  // Doctor specializations
  static const List<String> doctorSpecializations = [
    'General Practitioner',
    'Pediatrician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedist',
    'Gynecologist',
    'Ophthalmologist',
    'Dentist',
    'Other'
  ];
}
