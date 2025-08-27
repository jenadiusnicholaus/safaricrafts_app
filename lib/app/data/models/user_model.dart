class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Address>? addresses;
  final Address? defaultAddress;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.dateOfBirth,
    this.gender,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.addresses,
    this.defaultAddress,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get displayName => fullName.isEmpty ? email : fullName;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      avatar: json['avatar'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'])
          : DateTime.now(),
      updatedAt: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : DateTime.now(),
      addresses: json['addresses'] != null
          ? (json['addresses'] as List)
              .map((addr) => Address.fromJson(addr))
              .toList()
          : null,
      defaultAddress: json['default_address'] != null
          ? Address.fromJson(json['default_address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar': avatar,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'addresses': addresses?.map((addr) => addr.toJson()).toList(),
      'default_address': defaultAddress?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    DateTime? dateOfBirth,
    String? gender,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Address>? addresses,
    Address? defaultAddress,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addresses: addresses ?? this.addresses,
      defaultAddress: defaultAddress ?? this.defaultAddress,
    );
  }
}

class Address {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? phone;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.phone,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  String get fullAddress => '$street, $city, $state $postalCode, $country';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      phone: json['phone'],
      isDefault: json['is_default'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'phone': phone,
      'is_default': isDefault,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Address copyWith({
    String? id,
    String? name,
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? phone,
    bool? isDefault,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
