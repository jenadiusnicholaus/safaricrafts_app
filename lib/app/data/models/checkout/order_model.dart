import '../artwork_model.dart';
import 'address_model.dart';
import 'shipping_method_model.dart';
import 'payment_method_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  completed,
  cancelled,
  refunded,
}

class OrderModel {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final String currency;
  final double subtotal;
  final double shippingCost;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final AddressModel shippingAddress;
  final AddressModel billingAddress;
  final List<OrderItemModel> items;
  final ShippingMethodInfo? shippingMethod;
  final PaymentInfo? payment;
  final ShipmentInfo? shipment;
  final List<OrderStatusHistory> statusHistory;
  final String? customerNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPaid;
  final bool canBeCancelled;
  final bool canBeRefunded;
  final bool paymentRequired;
  final String? paymentUrl;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.shippingCost,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.shippingAddress,
    required this.billingAddress,
    required this.items,
    this.shippingMethod,
    this.payment,
    this.shipment,
    required this.statusHistory,
    this.customerNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.isPaid,
    required this.canBeCancelled,
    required this.canBeRefunded,
    required this.paymentRequired,
    this.paymentUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      status: _parseOrderStatus(json['status']),
      currency: json['currency'] ?? 'TZS',
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
      shippingCost: double.parse(json['shipping_cost']?.toString() ?? '0'),
      taxAmount: double.parse(json['tax_amount']?.toString() ?? '0'),
      discountAmount: double.parse(json['discount_amount']?.toString() ?? '0'),
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      shippingAddress: AddressModel.fromJson(json['shipping_address'] ?? {}),
      billingAddress: AddressModel.fromJson(json['billing_address'] ?? {}),
      items: (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      shippingMethod: json['shipping_method'] != null
          ? ShippingMethodInfo.fromJson(json['shipping_method'])
          : null,
      payment: json['payment'] != null
          ? PaymentInfo.fromJson(json['payment'])
          : null,
      shipment: json['shipment'] != null
          ? ShipmentInfo.fromJson(json['shipment'])
          : null,
      statusHistory: (json['status_history'] as List?)
              ?.map((history) => OrderStatusHistory.fromJson(history))
              .toList() ??
          [],
      customerNotes: json['customer_notes'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      isPaid: json['is_paid'] ?? false,
      canBeCancelled: json['can_be_cancelled'] ?? false,
      canBeRefunded: json['can_be_refunded'] ?? false,
      paymentRequired: json['payment_required'] ?? true,
      paymentUrl: json['payment_url'],
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get formattedTotal {
    if (currency == 'TZS') {
      return 'TZS ${totalAmount.toStringAsFixed(0)}';
    }
    return '$currency ${totalAmount.toStringAsFixed(2)}';
  }

  String get formattedSubtotal {
    if (currency == 'TZS') {
      return 'TZS ${subtotal.toStringAsFixed(0)}';
    }
    return '$currency ${subtotal.toStringAsFixed(2)}';
  }

  String get formattedShippingCost {
    if (currency == 'TZS') {
      return 'TZS ${shippingCost.toStringAsFixed(0)}';
    }
    return '$currency ${shippingCost.toStringAsFixed(2)}';
  }

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, status: $statusDisplayName, total: $formattedTotal)';
  }
}

class OrderItemModel {
  final int id;
  final ArtworkSummary artwork;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double taxRate;
  final double taxAmount;
  final Map<String, dynamic> snapshot;

  OrderItemModel({
    required this.id,
    required this.artwork,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.taxRate,
    required this.taxAmount,
    required this.snapshot,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      artwork: ArtworkSummary.fromJson(json['artwork'] ?? {}),
      quantity: json['quantity'] ?? 1,
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
      totalPrice: double.parse(json['total_price']?.toString() ?? '0'),
      taxRate: double.parse(json['tax_rate']?.toString() ?? '0'),
      taxAmount: double.parse(json['tax_amount']?.toString() ?? '0'),
      snapshot: Map<String, dynamic>.from(json['snapshot'] ?? {}),
    );
  }

  String get formattedUnitPrice {
    final currency = snapshot['currency'] ?? 'TZS';
    if (currency == 'TZS') {
      return 'TZS ${unitPrice.toStringAsFixed(0)}';
    }
    return '$currency ${unitPrice.toStringAsFixed(2)}';
  }

  String get formattedTotalPrice {
    final currency = snapshot['currency'] ?? 'TZS';
    if (currency == 'TZS') {
      return 'TZS ${totalPrice.toStringAsFixed(0)}';
    }
    return '$currency ${totalPrice.toStringAsFixed(2)}';
  }
}

class ArtworkSummary {
  final String id;
  final String title;
  final String artistName;
  final ArtworkMainImage? mainImage;

  ArtworkSummary({
    required this.id,
    required this.title,
    required this.artistName,
    this.mainImage,
  });

  factory ArtworkSummary.fromJson(Map<String, dynamic> json) {
    return ArtworkSummary(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artistName: json['artist_name'] ?? '',
      mainImage: json['main_image'] != null
          ? ArtworkMainImage.fromJson(json['main_image'])
          : null,
    );
  }
}

class ArtworkMainImage {
  final String file;
  final String thumbnail;

  ArtworkMainImage({
    required this.file,
    required this.thumbnail,
  });

  factory ArtworkMainImage.fromJson(Map<String, dynamic> json) {
    return ArtworkMainImage(
      file: json['file'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

class ShippingMethodInfo {
  final int id;
  final String name;
  final String carrier;
  final String estimatedDelivery;

  ShippingMethodInfo({
    required this.id,
    required this.name,
    required this.carrier,
    required this.estimatedDelivery,
  });

  factory ShippingMethodInfo.fromJson(Map<String, dynamic> json) {
    return ShippingMethodInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      carrier: json['carrier'] ?? '',
      estimatedDelivery: json['estimated_delivery'] ?? '',
    );
  }
}

class PaymentInfo {
  final String id;
  final String status;
  final String method;
  final String provider;
  final double amount;
  final DateTime? processedAt;

  PaymentInfo({
    required this.id,
    required this.status,
    required this.method,
    required this.provider,
    required this.amount,
    this.processedAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      method: json['method'] ?? '',
      provider: json['provider'] ?? '',
      amount: double.parse(json['amount']?.toString() ?? '0'),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
    );
  }
}

class ShipmentInfo {
  final String id;
  final String status;
  final String? trackingNumber;
  final String carrier;
  final String estimatedDelivery;

  ShipmentInfo({
    required this.id,
    required this.status,
    this.trackingNumber,
    required this.carrier,
    required this.estimatedDelivery,
  });

  factory ShipmentInfo.fromJson(Map<String, dynamic> json) {
    return ShipmentInfo(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      trackingNumber: json['tracking_number'],
      carrier: json['carrier'] ?? '',
      estimatedDelivery: json['estimated_delivery'] ?? '',
    );
  }
}

class OrderStatusHistory {
  final OrderStatus status;
  final DateTime changedAt;
  final String? note;

  OrderStatusHistory({
    required this.status,
    required this.changedAt,
    this.note,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: OrderModel._parseOrderStatus(json['status']),
      changedAt: DateTime.parse(
          json['changed_at'] ?? DateTime.now().toIso8601String()),
      note: json['note'],
    );
  }
}
