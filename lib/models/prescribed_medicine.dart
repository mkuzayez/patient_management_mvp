import 'package:patient_management_app/models/medicine.dart';

class PrescribedMedicine {
  final int? id;
  final int recordId;
  final int medicineId;
  final String medicineName;
  final double medicinePrice;
  final String dose;
  final int quantity;

  PrescribedMedicine({
    this.id,
    required this.recordId,
    required this.medicineId,
    required this.medicineName,
    required this.medicinePrice,
    required this.dose,
    required this.quantity,
  });

  factory PrescribedMedicine.fromJson(Map<String, dynamic> json) {
    return PrescribedMedicine(
      id: json['id'],
      recordId: json['record'] ?? 0,
      medicineId: json['medicine'],
      medicineName: json['medicine_name'] ?? '',
      medicinePrice: double.parse(json['medicine_price']?.toString() ?? '0.0'),
      dose: json['dose'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'record': recordId,
      'medicine': medicineId,
      'dose': dose,
      'quantity': quantity,
    };
  }
}
