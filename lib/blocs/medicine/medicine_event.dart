import 'package:equatable/equatable.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class MedicineFetchAll extends MedicineEvent {
  const MedicineFetchAll();
}

class MedicineFetchOne extends MedicineEvent {
  final int medicineId;
  
  const MedicineFetchOne(this.medicineId);
  
  @override
  List<Object?> get props => [medicineId];
}

class MedicineSearch extends MedicineEvent {
  final String query;
  
  const MedicineSearch(this.query);
  
  @override
  List<Object?> get props => [query];
}

class MedicineCreate extends MedicineEvent {
  final Map<String, dynamic> medicineData;
  
  const MedicineCreate(this.medicineData);
  
  @override
  List<Object?> get props => [medicineData];
}

class MedicineUpdate extends MedicineEvent {
  final int medicineId;
  final Map<String, dynamic> medicineData;
  
  const MedicineUpdate(this.medicineId, this.medicineData);
  
  @override
  List<Object?> get props => [medicineId, medicineData];
}

class MedicineDelete extends MedicineEvent {
  final int medicineId;
  
  const MedicineDelete(this.medicineId);
  
  @override
  List<Object?> get props => [medicineId];
}
