class Address {
  final int id;
  final AddressType type;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.type,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress {
    final parts = [line1];
    if (line2 != null && line2!.isNotEmpty) parts.add(line2!);
    parts.addAll([city, state, postalCode, country]);
    return parts.join(', ');
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      type: AddressType.fromString(json['type']),
      line1: json['line1'],
      line2: json['line2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      isDefault: json['is_default'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AddressRequest {
  final AddressType type;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressRequest({
    required this.type,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'is_default': isDefault,
    };
  }
}

enum AddressType {
  billing('billing'),
  shipping('shipping');

  const AddressType(this.value);
  final String value;

  static AddressType fromString(String value) {
    return AddressType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AddressType.shipping,
    );
  }

  String get displayName {
    switch (this) {
      case AddressType.billing:
        return 'Billing Address';
      case AddressType.shipping:
        return 'Shipping Address';
    }
  }
}

class PaginatedAddressList {
  final int count;
  final String? next;
  final String? previous;
  final List<Address> results;

  PaginatedAddressList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedAddressList.fromJson(Map<String, dynamic> json) {
    return PaginatedAddressList(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => Address.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
