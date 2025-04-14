import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/blocs/patient/patient_event.dart';
import 'package:patient_management_app/blocs/patient/patient_state.dart';
import 'package:patient_management_app/config/constants.dart';
import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/services/patient_service.dart';
import 'package:patient_management_app/utils/cache_manager.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientService _patientService;
  final CacheManager cacheManager = CacheManager();

  PatientBloc({PatientService? patientService})
      : _patientService = patientService ?? PatientService(),
        super(const PatientState()) {
    on<PatientFetchAll>(_onFetchAll);
    on<PatientFetchOne>(_onFetchOne);
    on<PatientSearch>(_onSearch);
    on<PatientCreate>(_onCreate);
    on<PatientUpdate>(_onUpdate);
    on<PatientDelete>(_onDelete);
  }

  Future<void> _onFetchAll(PatientFetchAll event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: Status.loading));

    final cachedPatients = cacheManager.getData(key: CacheKeys.patients);

    if (cachedPatients != null && cachedPatients is List<Patient> && cachedPatients.isNotEmpty) {
      emit(state.copyWith(
        status: Status.success,
        patients: cachedPatients,
        clearFailure: true,
      ));

      log("Patients were loaded from cache!");
    }

    try {
      final patients = await _patientService.getAllPatients();
      cacheManager.cacheData(key: CacheKeys.patients, data: patients);
      emit(state.copyWith(
        status: Status.success,
        patients: patients,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onFetchOne(PatientFetchOne event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final patient = await _patientService.getPatient(event.patientId);
      emit(state.copyWith(
        status: Status.success,
        selectedPatient: patient,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onSearch(PatientSearch event, Emitter<PatientState> emit) async {
    emit(state.copyWith(
      status: Status.loading,
      searchQuery: event.query,
    ));

    try {
      // final patients = await _patientService.searchPatients(event.query);
      emit(state.copyWith(
        status: Status.success,
        patients: state.patients.where((element) => element.fullName.contains(event.query)).toList(),
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onCreate(PatientCreate event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: Status.loading));

    try {
      // Convert map to Patient object
      final now = DateTime.now();
      final patient = Patient(
        fullName: event.patientData['fullName'],
        age: event.patientData['age'],
        gender: event.patientData['gender'],
        area: event.patientData['area'],
        mobileNumber: event.patientData['mobileNumber'],
        pastIllnesses: event.patientData['pastIllnesses'] ?? '',
        status: event.patientData['status'] ?? 'active',
        // createdAt: now,
        // updatedAt: now,
      );

      final createdPatient = await _patientService.createPatient(patient);

      // Update the list with the new patient
      final updatedPatients = List<Patient>.from(state.patients)..add(createdPatient);

      emit(state.copyWith(
        status: Status.success,
        patients: updatedPatients,
        selectedPatient: createdPatient,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onUpdate(PatientUpdate event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: Status.loading));

    try {
      // Get current patient
      Patient? currentPatient;
      if (state.selectedPatient?.id == event.patientId) {
        currentPatient = state.selectedPatient;
      } else {
        currentPatient = await _patientService.getPatient(event.patientId);
      }

      if (currentPatient == null) {
        throw Exception('Patient not found');
      }

      // Create updated patient
      final now = DateTime.now();
      final updatedPatient = Patient(
        id: currentPatient.id,
        fullName: event.patientData['fullName'] ?? currentPatient.fullName,
        age: event.patientData['age'] ?? currentPatient.age,
        gender: event.patientData['gender'] ?? currentPatient.gender,
        area: event.patientData['area'] ?? currentPatient.area,
        mobileNumber: event.patientData['mobileNumber'] ?? currentPatient.mobileNumber,
        pastIllnesses: event.patientData['pastIllnesses'] ?? currentPatient.pastIllnesses,
        status: event.patientData['status'] ?? currentPatient.status,
        // createdAt: currentPatient.createdAt,
        // updatedAt: now,
        recordsCount: currentPatient.recordsCount,
        lastVisit: currentPatient.lastVisit,
      );

      final savedPatient = await _patientService.updatePatient(updatedPatient);

      // Update the list with the updated patient
      final updatedPatients = state.patients.map((p) {
        return p.id == savedPatient.id ? savedPatient : p;
      }).toList();

      emit(state.copyWith(
        status: Status.success,
        patients: updatedPatients,
        selectedPatient: savedPatient,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onDelete(PatientDelete event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _patientService.deletePatient(event.patientId);

      // Remove the deleted patient from the list
      final updatedPatients = state.patients.where((p) => p.id != event.patientId).toList();

      emit(state.copyWith(
        status: Status.success,
        patients: updatedPatients,
        clearSelectedPatient: state.selectedPatient?.id == event.patientId,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }
}
