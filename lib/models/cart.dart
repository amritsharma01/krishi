import 'package:krishi/models/product.dart';

class CartItem {
  final int id;
  final int product;
  final Product? productDetails;
  final int quantity;
  final String unitPrice;
  final String subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.product,
    this.productDetails,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      product: json['product'] as int,
      productDetails: json['product_details'] != null
          ? Product.fromJson(json['product_details'] as Map<String, dynamic>)
          : null,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'].toString(),
      subtotal: json['subtotal'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'product_details': productDetails?.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get unitPriceAsDouble => double.tryParse(unitPrice) ?? 0.0;
  double get subtotalAsDouble => double.tryParse(subtotal) ?? 0.0;
}

class Cart {
  final int id;
  final int user;
  final List<CartItem> items;
  final String totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.user,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int,
      user: json['user'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: json['total_amount'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get totalAmountAsDouble => double.tryParse(totalAmount) ?? 0.0;
}

