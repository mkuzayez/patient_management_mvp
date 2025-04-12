import 'package:equatable/equatable.dart';

abstract class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

class RecordFetchAll extends RecordEvent {
  const RecordFetchAll();
}

class RecordFetchByPatient extends RecordEvent {
  final int patientId;
  
  const RecordFetchByPatient(this.patientId);
  
  @override
  List<Object?> get props => [patientId];
}

class RecordFetchOne extends RecordEvent {
  final int recordId;
  
  const RecordFetchOne(this.recordId);
  
  @override
  List<Object?> get props => [recordId];
}

class RecordCreate extends RecordEvent {
  final Map<String, dynamic> recordData;
  
  const RecordCreate(this.recordData);
  
  @override
  List<Object?> get props => [recordData];
}

class RecordUpdate extends RecordEvent {
  final int recordId;
  final Map<String, dynamic> recordData;
  
  const RecordUpdate(this.recordId, this.recordData);
  
  @override
  List<Object?> get props => [recordId, recordData];
}

class RecordDelete extends RecordEvent {
  final int recordId;
  
  const RecordDelete(this.recordId);
  
  @override
  List<Object?> get props => [recordId];
}
