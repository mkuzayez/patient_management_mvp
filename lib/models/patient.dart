class Patient {
  final int? id;
  final String fullName;
  final int age;
  final String gender;
  final String area;
  final String mobileNumber;
  final String pastIllnesses;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int recordsCount;
  final String? lastVisit;

  Patient({
    this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.area,
    required this.mobileNumber,
    this.pastIllnesses = '',
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.recordsCount = 0,
    this.lastVisit,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['full_name'],
      age: json['age'],
      gender: json['gender'],
      area: json['area'],
      mobileNumber: json['mobile_number'],
      pastIllnesses: json['past_illnesses'] ?? '',
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      recordsCount: json['records_count'] ?? 0,
      lastVisit: json['last_visit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'area': area,
      'mobile_number': mobileNumber,
      'past_illnesses': pastIllnesses,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'records_count': recordsCount,
      'last_visit': lastVisit,
    };
  }
}
