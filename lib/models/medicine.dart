class Medicine {
  final int? id;
  final String name;
  final String dose;
  final String scientificName;
  final String company;
  final double price;

  Medicine({
    this.id,
    required this.name,
    required this.dose,
    this.scientificName = '',
    this.company = '',
    required this.price,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      dose: json['dose'],
      scientificName: json['scientific_name'] ?? '',
      company: json['company'] ?? '',
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'scientific_name': scientificName,
      'company': company,
      'price': price,
    };
  }
}
