class Traveler {
  final int id;
  final String firstName;
  final String lastName;
  final String title;
  final String type;
  final String? dateOfBirth;
  final String? email;
  final String? phone;
  final String? passportNumber;
  final bool isDefault;

  Traveler({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.type,
    this.dateOfBirth,
    this.email,
    this.phone,
    this.passportNumber,
    this.isDefault = false,
  });

  String get fullName => '$lastName / $firstName';
  String get initials =>
      '${lastName.isNotEmpty ? lastName[0] : ''}${firstName.isNotEmpty ? firstName[0] : ''}';

  factory Traveler.fromJson(Map<String, dynamic> json) {
    return Traveler(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      title: json['title'] ?? 'MR',
      type: json['type'] ?? 'ADULT',
      dateOfBirth: json['dateOfBirth'],
      email: json['email'],
      phone: json['phone'],
      passportNumber: json['passportNumber'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'title': title,
        'type': type,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (passportNumber != null) 'passportNumber': passportNumber,
        'isDefault': isDefault,
      };
}
