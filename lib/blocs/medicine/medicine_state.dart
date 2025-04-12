import 'package:equatable/equatable.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/models/medicine.dart';

class MedicineState extends Equatable {
  final Status status;
  final List<Medicine> medicines;
  final Medicine? selectedMedicine;
  final String? searchQuery;
  final Failure? failure;

  const MedicineState({
    this.status = Status.initial,
    this.medicines = const [],
    this.selectedMedicine,
    this.searchQuery,
    this.failure,
  });

  @override
  List<Object?> get props => [
        status,
        medicines,
        selectedMedicine,
        searchQuery,
        failure,
      ];

  // Custom copyWith method to create a new instance with updated values
  MedicineState copyWith({
    Status? status,
    List<Medicine>? medicines,
    Medicine? selectedMedicine,
    String? searchQuery,
    Failure? failure,
    // Use this to explicitly set nullable fields to null
    bool clearSelectedMedicine = false,
    bool clearSearchQuery = false,
    bool clearFailure = false,
  }) {
    return MedicineState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      selectedMedicine: clearSelectedMedicine ? null : selectedMedicine ?? this.selectedMedicine,
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
