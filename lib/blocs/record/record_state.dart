import 'package:equatable/equatable.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/models/record.dart';

class RecordState extends Equatable {
  final Status status;
  final List<Record> records;
  final Record? selectedRecord;
  final int? patientId;
  final Failure? failure;

  const RecordState({
    this.status = Status.initial,
    this.records = const [],
    this.selectedRecord,
    this.patientId,
    this.failure,
  });

  @override
  List<Object?> get props => [
        status,
        records,
        selectedRecord,
        patientId,
        failure,
      ];

  // Custom copyWith method to create a new instance with updated values
  RecordState copyWith({
    Status? status,
    List<Record>? records,
    Record? selectedRecord,
    int? patientId,
    Failure? failure,
    // Use this to explicitly set nullable fields to null
    bool clearSelectedRecord = false,
    bool clearPatientId = false,
    bool clearFailure = false,
  }) {
    return RecordState(
      status: status ?? this.status,
      records: records ?? this.records,
      selectedRecord: clearSelectedRecord ? null : selectedRecord ?? this.selectedRecord,
      patientId: clearPatientId ? null : patientId ?? this.patientId,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
