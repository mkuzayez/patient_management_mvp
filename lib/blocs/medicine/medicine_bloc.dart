import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/medicine/medicine_event.dart';
import 'package:patient_management_app/blocs/medicine/medicine_state.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/models/medicine.dart';
import 'package:patient_management_app/services/medicine_service.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineService _medicineService;

  MedicineBloc({MedicineService? medicineService}) 
      : _medicineService = medicineService ?? MedicineService(),
        super(const MedicineState()) {
    on<MedicineFetchAll>(_onFetchAll);
    on<MedicineFetchOne>(_onFetchOne);
    on<MedicineSearch>(_onSearch);
    on<MedicineCreate>(_onCreate);
    on<MedicineUpdate>(_onUpdate);
    on<MedicineDelete>(_onDelete);
  }

  Future<void> _onFetchAll(MedicineFetchAll event, Emitter<MedicineState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      final medicines = await _medicineService.getAllMedicines();
      emit(state.copyWith(
        status: Status.success,
        medicines: medicines,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onFetchOne(MedicineFetchOne event, Emitter<MedicineState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      final medicine = await _medicineService.getMedicine(event.medicineId);
      emit(state.copyWith(
        status: Status.success,
        selectedMedicine: medicine,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onSearch(MedicineSearch event, Emitter<MedicineState> emit) async {
    emit(state.copyWith(
      status: Status.loading,
      searchQuery: event.query,
    ));
    
    try {
      final medicines = await _medicineService.searchMedicines(event.query);
      emit(state.copyWith(
        status: Status.success,
        medicines: medicines,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onCreate(MedicineCreate event, Emitter<MedicineState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      // Convert map to Medicine object
      final medicine = Medicine(
        name: event.medicineData['name'],
        dose: event.medicineData['dose'],
        scientificName: event.medicineData['scientificName'] ?? '',
        company: event.medicineData['company'] ?? '',
        price: event.medicineData['price'],
      );
      
      final createdMedicine = await _medicineService.createMedicine(medicine);
      
      // Update the list with the new medicine
      final updatedMedicines = List<Medicine>.from(state.medicines)..add(createdMedicine);
      
      emit(state.copyWith(
        status: Status.success,
        medicines: updatedMedicines,
        selectedMedicine: createdMedicine,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onUpdate(MedicineUpdate event, Emitter<MedicineState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      // Get current medicine
      Medicine? currentMedicine;
      if (state.selectedMedicine?.id == event.medicineId) {
        currentMedicine = state.selectedMedicine;
      } else {
        currentMedicine = await _medicineService.getMedicine(event.medicineId);
      }
      
      if (currentMedicine == null) {
        throw Exception('Medicine not found');
      }
      
      // Create updated medicine
      final updatedMedicine = Medicine(
        id: currentMedicine.id,
        name: event.medicineData['name'] ?? currentMedicine.name,
        dose: event.medicineData['dose'] ?? currentMedicine.dose,
        scientificName: event.medicineData['scientificName'] ?? currentMedicine.scientificName,
        company: event.medicineData['company'] ?? currentMedicine.company,
        price: event.medicineData['price'] ?? currentMedicine.price,
      );
      
      final savedMedicine = await _medicineService.updateMedicine(updatedMedicine);
      
      // Update the list with the updated medicine
      final updatedMedicines = state.medicines.map((m) {
        return m.id == savedMedicine.id ? savedMedicine : m;
      }).toList();
      
      emit(state.copyWith(
        status: Status.success,
        medicines: updatedMedicines,
        selectedMedicine: savedMedicine,
        clearFailure: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        failure: Failure(message: e.toString()),
      ));
    }
  }

  Future<void> _onDelete(MedicineDelete event, Emitter<MedicineState> emit) async {
    emit(state.copyWith(status: Status.loading));
    
    try {
      await _medicineService.deleteMedicine(event.medicineId);
      
      // Remove the deleted medicine from the list
      final updatedMedicines = state.medicines.where((m) => m.id != event.medicineId).toList();
      
      emit(state.copyWith(
        status: Status.success,
        medicines: updatedMedicines,
        clearSelectedMedicine: state.selectedMedicine?.id == event.medicineId,
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
