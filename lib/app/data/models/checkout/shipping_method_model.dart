class ShippingMethodModel {
  final int id;
  final String name;
  final String description;
  final String carrier;
  final double baseCost;
  final double costPerKg;
  final double calculatedCost;
  final int minDeliveryDays;
  final int maxDeliveryDays;
  final double maxWeight;
  final String maxDimensions;
  final bool domesticOnly;
  final List<String> supportedCountries;
  final bool isActive;
  final String estimatedDelivery;
  final String currency;

  ShippingMethodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.carrier,
    required this.baseCost,
    required this.costPerKg,
    required this.calculatedCost,
    required this.minDeliveryDays,
    required this.maxDeliveryDays,
    required this.maxWeight,
    required this.maxDimensions,
    required this.domesticOnly,
    required this.supportedCountries,
    required this.isActive,
    required this.estimatedDelivery,
    this.currency = 'TZS',
  });

  factory ShippingMethodModel.fromJson(Map<String, dynamic> json) {
    return ShippingMethodModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      carrier: json['carrier'] ?? '',
      baseCost: double.parse(json['base_cost']?.toString() ?? '0'),
      costPerKg: double.parse(json['cost_per_kg']?.toString() ?? '0'),
      calculatedCost: double.parse(json['calculated_cost']?.toString() ?? '0'),
      minDeliveryDays: json['min_delivery_days'] ?? 0,
      maxDeliveryDays: json['max_delivery_days'] ?? 0,
      maxWeight: double.parse(json['max_weight']?.toString() ?? '0'),
      maxDimensions: json['max_dimensions'] ?? '',
      domesticOnly: json['domestic_only'] ?? false,
      supportedCountries: List<String>.from(json['supported_countries'] ?? []),
      isActive: json['is_active'] ?? false,
      estimatedDelivery: json['estimated_delivery'] ?? '',
      currency: json['currency'] ?? 'TZS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'carrier': carrier,
      'base_cost': baseCost.toString(),
      'cost_per_kg': costPerKg.toString(),
      'calculated_cost': calculatedCost.toString(),
      'min_delivery_days': minDeliveryDays,
      'max_delivery_days': maxDeliveryDays,
      'max_weight': maxWeight.toString(),
      'max_dimensions': maxDimensions,
      'domestic_only': domesticOnly,
      'supported_countries': supportedCountries,
      'is_active': isActive,
      'estimated_delivery': estimatedDelivery,
      'currency': currency,
    };
  }

  String get deliveryTimeRange {
    if (minDeliveryDays == maxDeliveryDays) {
      return '$minDeliveryDays day${minDeliveryDays > 1 ? 's' : ''}';
    }
    return '$minDeliveryDays-$maxDeliveryDays days';
  }

  String get formattedCost {
    if (currency == 'TZS') {
      return 'TZS ${calculatedCost.toStringAsFixed(0)}';
    }
    return '$currency ${calculatedCost.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'ShippingMethodModel(id: $id, name: $name, carrier: $carrier, cost: $formattedCost)';
  }
}
