import 'package:equatable/equatable.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/models/patient.dart';

class PatientState extends Equatable {
  final Status status;
  final List<Patient> patients;
  final Patient? selectedPatient;
  final String? searchQuery;
  final Failure? failure;

  const PatientState({
    this.status = Status.initial,
    this.patients = const [],
    this.selectedPatient,
    this.searchQuery,
    this.failure,
  });

  @override
  List<Object?> get props => [
        status,
        patients,
        selectedPatient,
        searchQuery,
        failure,
      ];

  // Custom copyWith method to create a new instance with updated values
  PatientState copyWith({
    Status? status,
    List<Patient>? patients,
    Patient? selectedPatient,
    String? searchQuery,
    Failure? failure,
    // Use this to explicitly set nullable fields to null
    bool clearSelectedPatient = false,
    bool clearSearchQuery = false,
    bool clearFailure = false,
  }) {
    return PatientState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      selectedPatient: clearSelectedPatient ? null : selectedPatient ?? this.selectedPatient,
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
