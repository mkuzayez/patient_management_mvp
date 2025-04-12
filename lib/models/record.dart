import 'package:patient_management_app/models/patient.dart';
import 'package:patient_management_app/models/prescribed_medicine.dart';

class Record {
  final int? id;
  final int patientId;
  final String doctorSpecialization;
  final String vitalSigns;
  final String issuedDate;
  final String createdAt;
  final List<PrescribedMedicine> prescribedMedicines;
  final int totalGivenMedicines;

  Record({
    this.id,
    required this.patientId,
    required this.doctorSpecialization,
    this.vitalSigns = '',
    required this.issuedDate,
    required this.createdAt,
    this.prescribedMedicines = const [],
    this.totalGivenMedicines = 0,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    List<PrescribedMedicine> medicines = [];
    if (json['prescribed_medicines'] != null) {
      medicines = (json['prescribed_medicines'] as List)
          .map((medicine) => PrescribedMedicine.fromJson(medicine))
          .toList();
    }

    return Record(
      id: json['id'],
      patientId: json['patient'],
      doctorSpecialization: json['doctor_specialization'],
      vitalSigns: json['vital_signs'] ?? '',
      issuedDate: json['issued_date'],
      createdAt: json['created_at'],
      prescribedMedicines: medicines,
      totalGivenMedicines: json['total_given_medicines'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patientId,
      'doctor_specialization': doctorSpecialization,
      'vital_signs': vitalSigns,
      'issued_date': issuedDate,
      'created_at': createdAt,
    };
  }
}
