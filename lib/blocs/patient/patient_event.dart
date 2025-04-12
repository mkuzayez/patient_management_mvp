import 'package:equatable/equatable.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class PatientFetchAll extends PatientEvent {
  const PatientFetchAll();
}

class PatientFetchOne extends PatientEvent {
  final int patientId;
  
  const PatientFetchOne(this.patientId);
  
  @override
  List<Object?> get props => [patientId];
}

class PatientSearch extends PatientEvent {
  final String query;
  
  const PatientSearch(this.query);
  
  @override
  List<Object?> get props => [query];
}

class PatientCreate extends PatientEvent {
  final Map<String, dynamic> patientData;
  
  const PatientCreate(this.patientData);
  
  @override
  List<Object?> get props => [patientData];
}

class PatientUpdate extends PatientEvent {
  final int patientId;
  final Map<String, dynamic> patientData;
  
  const PatientUpdate(this.patientId, this.patientData);
  
  @override
  List<Object?> get props => [patientId, patientData];
}

class PatientDelete extends PatientEvent {
  final int patientId;
  
  const PatientDelete(this.patientId);
  
  @override
  List<Object?> get props => [patientId];
}
