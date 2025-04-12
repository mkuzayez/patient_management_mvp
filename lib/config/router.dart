import 'package:go_router/go_router.dart';
import 'package:patient_management_app/screens/home/home_screen.dart';
import 'package:patient_management_app/screens/medicines/add_edit_medicine_screen.dart';
import 'package:patient_management_app/screens/medicines/medicines_screen.dart';
import 'package:patient_management_app/screens/patients/add_edit_patient_screen.dart';
import 'package:patient_management_app/screens/patients/patient_detail_screen.dart';
import 'package:patient_management_app/screens/patients/patients_screen.dart';
import 'package:patient_management_app/screens/records/add_record_screen.dart';
import 'package:patient_management_app/screens/records/record_detail_screen.dart';
import 'package:patient_management_app/screens/records/records_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          // Patients routes
          GoRoute(
            path: '/',
            builder: (context, state) => const PatientsScreen(),
            routes: [
              GoRoute(
                path: 'patient/:id',
                builder: (context, state) {
                  final patientId = int.parse(state.pathParameters['id']!);
                  return PatientDetailScreen(patientId: patientId);
                },
              ),
              GoRoute(
                path: 'add-patient',
                builder: (context, state) => const AddEditPatientScreen(),
              ),
              GoRoute(
                path: 'edit-patient/:id',
                builder: (context, state) {
                  final patientId = int.parse(state.pathParameters['id']!);
                  return AddEditPatientScreen(patient: null, patientId: patientId);
                },
              ),
            ],
          ),

          // Medicines routes
          GoRoute(
            path: '/medicines',
            builder: (context, state) => const MedicinesScreen(),
            routes: [
              GoRoute(
                path: 'add-medicine',
                builder: (context, state) => const AddEditMedicineScreen(),
              ),
              GoRoute(
                path: 'edit-medicine/:id',
                builder: (context, state) {
                  final medicineId = int.parse(state.pathParameters['id']!);
                  return AddEditMedicineScreen(medicine: null, medicineId: medicineId);
                },
              ),
            ],
          ),

          // Records routes
          GoRoute(
            path: '/records',
            builder: (context, state) => const RecordsScreen(),
            routes: [
              GoRoute(
                path: 'record/:id',
                builder: (context, state) {
                  final recordId = int.parse(state.pathParameters['id']!);
                  return RecordDetailScreen(recordId: recordId);
                },
              ),
              GoRoute(
                path: 'add-record',
                builder: (context, state) => const AddRecordScreen(),
              ),
              GoRoute(
                path: 'add-record/:patientId',
                builder: (context, state) {
                  final patientId = int.parse(state.pathParameters['patientId']!);
                  return AddRecordScreen(patientId: patientId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
