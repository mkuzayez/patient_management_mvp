import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/record/record_event.dart';
import 'package:patient_management_app/blocs/record/record_state.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/models/record.dart';
import 'package:patient_management_app/services/record_service.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final RecordService _recordService;

  RecordBloc({RecordService? recordService}) 
      : _recordService = recordService ?? RecordService(),
        super(const RecordState()) {
    on<RecordFetchAll>(_onFetchAll);
    on<RecordFetchByPatient>(_onFetchByPatient);
    on<RecordFetchOne>(_onFetchOne);
    on<RecordCreate>(_onCreate);
    on<RecordUpdate>(_onUpdate);
    on<RecordDelete>(_onDelete);
  }

  Future<void> _onFetchAll(RecordFetchAll event, Emitter<RecordState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      final records = await _recordService.getAllRecords();
      emit(state.copyWith(
        status: Status.success,
        records: records,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onFetchByPatient(RecordFetchByPatient event, Emitter<RecordState> emit) async {
    emit(state.copyWith(
      status: Status.loading,
      patientId: event.patientId,
    ));
    
    try {
      final records = await _recordService.getPatientRecords(event.patientId);
      emit(state.copyWith(
        status: Status.success,
        records: records,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onFetchOne(RecordFetchOne event, Emitter<RecordState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      final record = await _recordService.getRecord(event.recordId);
      emit(state.copyWith(
        status: Status.success,
        selectedRecord: record,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onCreate(RecordCreate event, Emitter<RecordState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      // Convert map to Record object
      final now = DateTime.now().toIso8601String();
      final record = Record(
        patientId: event.recordData['patientId'],
        doctorSpecialization: event.recordData['doctorSpecialization'],
        vitalSigns: event.recordData['vitalSigns'] ?? '',
        issuedDate: event.recordData['issuedDate'] ?? now,
        createdAt: now,
      );
      
      final createdRecord = await _recordService.createRecord(record);
      
      // Update the list with the new record
      final updatedRecords = List<Record>.from(state.records)..add(createdRecord);
      
      emit(state.copyWith(
        status: Status.success,
        records: updatedRecords,
        selectedRecord: createdRecord,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onUpdate(RecordUpdate event, Emitter<RecordState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      // Get current record
      Record? currentRecord;
      if (state.selectedRecord?.id == event.recordId) {
        currentRecord = state.selectedRecord;
      } else {
        currentRecord = await _recordService.getRecord(event.recordId);
      }
      
      if (currentRecord == null) {
        throw Exception('Record not found');
      }
      
      // Create updated record
      final updatedRecord = Record(
        id: currentRecord.id,
        patientId: event.recordData['patientId'] ?? currentRecord.patientId,
        doctorSpecialization: event.recordData['doctorSpecialization'] ?? currentRecord.doctorSpecialization,
        vitalSigns: event.recordData['vitalSigns'] ?? currentRecord.vitalSigns,
        issuedDate: event.recordData['issuedDate'] ?? currentRecord.issuedDate,
        createdAt: currentRecord.createdAt,
        prescribedMedicines: currentRecord.prescribedMedicines,
        totalGivenMedicines: currentRecord.totalGivenMedicines,
      );
      
      final savedRecord = await _recordService.updateRecord(updatedRecord);
      
      // Update the list with the updated record
      final updatedRecords = state.records.map((r) {
        return r.id == savedRecord.id ? savedRecord : r;
      }).toList();
      
      emit(state.copyWith(
        status: Status.success,
        records: updatedRecords,
        selectedRecord: savedRecord,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onDelete(RecordDelete event, Emitter<RecordState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      await _recordService.deleteRecord(event.recordId);
      
      // Remove the deleted record from the list
      final updatedRecords = state.records.where((r) => r.id != event.recordId).toList();
      
      emit(state.copyWith(
        status: Status.success,
        records: updatedRecords,
        clearSelectedRecord: state.selectedRecord?.id == event.recordId,
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
