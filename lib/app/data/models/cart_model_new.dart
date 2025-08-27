import 'user_model.dart';

class Cart {
  final int id;
  final String currency;
  final List<CartItem> items;
  final double totalAmount;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.currency,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      currency: json['currency'] ?? 'USD',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : [],
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      totalItems: int.parse(json['total_items']?.toString() ?? '0'),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount.toString(),
      'total_items': totalItems.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Cart copyWith({
    int? id,
    String? currency,
    List<CartItem>? items,
    double? totalAmount,
    int? totalItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CartItem {
  final int id;
  final Artwork artwork;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic>? snapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.artwork,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.snapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      artwork: Artwork.fromJson(json['artwork'] ?? {}),
      quantity: json['quantity'] ?? 1,
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
      totalPrice: double.parse(json['total_price']?.toString() ?? '0'),
      snapshot: json['snapshot'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artwork': artwork.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice.toString(),
      'total_price': totalPrice.toString(),
      'snapshot': snapshot,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    int? id,
    Artwork? artwork,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    Map<String, dynamic>? snapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      artwork: artwork ?? this.artwork,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      snapshot: snapshot ?? this.snapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Artwork model for cart items (simplified version)
class Artwork {
  final String id;
  final String title;
  final String slug;
  final String artistName;
  final String categoryName;
  final double price;
  final String currency;
  final String? mainImage;
  final bool isFeatured;
  final String tribe;
  final String region;
  final String material;
  final int viewCount;
  final int likeCount;

  Artwork({
    required this.id,
    required this.title,
    required this.slug,
    required this.artistName,
    required this.categoryName,
    required this.price,
    required this.currency,
    this.mainImage,
    required this.isFeatured,
    required this.tribe,
    required this.region,
    required this.material,
    required this.viewCount,
    required this.likeCount,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      artistName: json['artist_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      currency: json['currency'] ?? 'USD',
      mainImage: json['main_image'],
      isFeatured: json['is_featured'] ?? false,
      tribe: json['tribe'] ?? '',
      region: json['region'] ?? '',
      material: json['material'] ?? '',
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'artist_name': artistName,
      'category_name': categoryName,
      'price': price.toString(),
      'currency': currency,
      'main_image': mainImage,
      'is_featured': isFeatured,
      'tribe': tribe,
      'region': region,
      'material': material,
      'view_count': viewCount,
      'like_count': likeCount,
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class Order {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String currency;
  final Address shippingAddress;
  final Address? billingAddress;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.currency,
    required this.shippingAddress,
    this.billingAddress,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.shippedAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
      shipping: double.parse(json['shipping']?.toString() ?? '0'),
      tax: double.parse(json['tax']?.toString() ?? '0'),
      total: double.parse(json['total']?.toString() ?? '0'),
      currency: json['currency'] ?? 'USD',
      shippingAddress: Address.fromJson(json['shipping_address'] ?? {}),
      billingAddress: json['billing_address'] != null
          ? Address.fromJson(json['billing_address'])
          : null,
      paymentMethod: json['payment_method'] ?? '',
      notes: json['notes'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal.toString(),
      'shipping': shipping.toString(),
      'tax': tax.toString(),
      'total': total.toString(),
      'currency': currency,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress?.toJson(),
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String id;
  final Artwork artwork;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.artwork,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      artwork: Artwork.fromJson(json['artwork'] ?? {}),
      quantity: json['quantity'] ?? 1,
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
      totalPrice: double.parse(json['total_price']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artwork': artwork.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice.toString(),
      'total_price': totalPrice.toString(),
    };
  }
}
