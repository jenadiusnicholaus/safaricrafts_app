class PaymentMethodModel {
  final String provider;
  final String method;
  final String name;
  final String description;
  final String? icon;
  final PaymentFees? fees;
  final List<String> supportedCurrencies;
  final List<String> supportedMethods;
  final bool isActive;

  PaymentMethodModel({
    required this.provider,
    required this.method,
    required this.name,
    required this.description,
    this.icon,
    this.fees,
    required this.supportedCurrencies,
    this.supportedMethods = const [],
    required this.isActive,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      provider: json['provider'] ?? '',
      method: json['method'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      fees: json['fees'] != null ? PaymentFees.fromJson(json['fees']) : null,
      supportedCurrencies:
          List<String>.from(json['supported_currencies'] ?? []),
      supportedMethods: List<String>.from(json['supported_methods'] ?? []),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'method': method,
      'name': name,
      'description': description,
      'icon': icon,
      'fees': fees?.toJson(),
      'supported_currencies': supportedCurrencies,
      'supported_methods': supportedMethods,
      'is_active': isActive,
    };
  }

  bool get isMobilePayment {
    return ['mpesa', 'airtel_money', 'tigo_pesa'].contains(method);
  }

  bool get isBankTransfer {
    return method == 'bank_transfer';
  }

  bool get isPayPal {
    return method == 'paypal';
  }

  String get displayName {
    switch (method) {
      case 'mpesa':
        return 'M-Pesa';
      case 'airtel_money':
        return 'Airtel Money';
      case 'tigo_pesa':
        return 'Tigo Pesa';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'paypal':
        return 'PayPal';
      default:
        return name;
    }
  }

  double get processingFee {
    return fees?.fixedAmount ?? 0.0;
  }

  @override
  String toString() {
    return 'PaymentMethodModel(provider: $provider, method: $method, name: $name)';
  }
}

class PaymentFees {
  final double percentage;
  final double fixedAmount;

  PaymentFees({
    required this.percentage,
    required this.fixedAmount,
  });

  factory PaymentFees.fromJson(Map<String, dynamic> json) {
    return PaymentFees(
      percentage: double.parse(json['percentage']?.toString() ?? '0'),
      fixedAmount: double.parse(json['fixed_amount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'fixed_amount': fixedAmount.toString(),
    };
  }

  String getFormattedFees() {
    if (percentage > 0 && fixedAmount > 0) {
      return '${percentage.toStringAsFixed(1)}% + TZS ${fixedAmount.toStringAsFixed(0)}';
    } else if (percentage > 0) {
      return '${percentage.toStringAsFixed(1)}%';
    } else if (fixedAmount > 0) {
      return 'TZS ${fixedAmount.toStringAsFixed(0)}';
    }
    return 'Free';
  }
}
