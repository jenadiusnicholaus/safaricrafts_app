class AddressModel {
  final String firstName;
  final String lastName;
  final String? company;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String region;
  final String? postalCode;
  final String country;
  final String phone;

  AddressModel({
    required this.firstName,
    required this.lastName,
    this.company,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.region,
    this.postalCode,
    required this.country,
    required this.phone,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      company: json['company'],
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      postalCode: json['postal_code'],
      country: json['country'] ?? 'TZ',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'company': company ?? '',
      'address_line_1': addressLine1,
      'address_line_2': addressLine2 ?? '',
      'city': city,
      'region': region,
      'postal_code': postalCode ?? '',
      'country': country,
      'phone': phone,
    };
  }

  AddressModel copyWith({
    String? firstName,
    String? lastName,
    String? company,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? region,
    String? postalCode,
    String? country,
    String? phone,
  }) {
    return AddressModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      region: region ?? this.region,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
    );
  }

  String get fullName => '$firstName $lastName';

  String get formattedAddress {
    final parts = [
      if (company?.isNotEmpty == true) company,
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2,
      '$city, $region',
      if (postalCode?.isNotEmpty == true) postalCode,
      country,
    ];
    return parts.join('\n');
  }

  @override
  String toString() {
    return 'AddressModel(firstName: $firstName, lastName: $lastName, city: $city, country: $country)';
  }
}
