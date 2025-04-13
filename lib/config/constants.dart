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
  static const String appName = 'إدارة المرضى';
  
  // Status options
  static const List<String> patientStatusOptions = ['فعال', 'غير فعال'];
  
  // Gender options
  static const List<String> genderOptions = ['ذكر', 'أنثى'];
  
  // Doctor specializations
  static const List<String> doctorSpecializations = [
    'طبيب عام',
    'طبيب الأطفال',
    'أخصائي قلب',
    'أخصائي جلدية',
    'أخصائي أعصاب',
    'أخصائي عظام',
    'أخصائي نساء وولادة',
    'أخصائي عيون',
    'طبيب أسنان',
    'إختصاص آخر'
  ];
}
