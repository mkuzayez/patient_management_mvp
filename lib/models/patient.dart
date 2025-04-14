class Patient {
  int? id;
  String fullName;
  int age;
  String? gender;
  String? area;
  String? mobileNumber;
  String? pastIllnesses;
  String? status;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  int recordsCount;
  String? lastVisit;

  Patient({
    this.id,
    required this.fullName,
    required this.age,
    this.gender,
    this.area,
    this.mobileNumber,
    this.pastIllnesses,
    this.status,
    // this.createdAt,
    // this.updatedAt,
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
      // createdAt: json['created_at'],
      // updatedAt: json['updated_at'],
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
      // 'created_at': createdAt,
      // 'updated_at': updatedAt,
      'records_count': recordsCount,
      'last_visit': lastVisit,
    };
  }
}
