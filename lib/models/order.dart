class Order {
  final int id;
  final int buyer;
  final String buyerEmail;
  final int seller;
  final String sellerEmail;
  final String? sellerPhoneNumber;
  final int product;
  final String productName;
  final OrderProductDetails? productDetails;
  final int quantity;
  final String unitPrice;
  final String totalAmount;
  final String buyerName;
  final String buyerAddress;
  final String buyerPhoneNumber;
  final String status;
  final String? statusDisplay;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.buyer,
    required this.buyerEmail,
    required this.seller,
    required this.sellerEmail,
    this.sellerPhoneNumber,
    required this.product,
    required this.productName,
    this.productDetails,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.buyerName,
    required this.buyerAddress,
    required this.buyerPhoneNumber,
    required this.status,
    this.statusDisplay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      buyer: json['buyer'] as int,
      buyerEmail: json['buyer_email'] as String,
      seller: json['seller'] as int,
      sellerEmail: json['seller_email'] as String,
      sellerPhoneNumber: json['seller_phone_number'] as String?,
      product: json['product'] as int,
      productName: json['product_name'] as String,
      productDetails: json['product_details'] != null
          ? OrderProductDetails.fromJson(json['product_details'] as Map<String, dynamic>)
          : null,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'].toString(),
      totalAmount: json['total_amount'].toString(),
      buyerName: json['buyer_name'] as String,
      buyerAddress: json['buyer_address'] as String,
      buyerPhoneNumber: json['buyer_phone_number'] as String,
      status: json['status'] as String,
      statusDisplay: json['status_display'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer': buyer,
      'buyer_email': buyerEmail,
      'seller': seller,
      'seller_email': sellerEmail,
      'seller_phone_number': sellerPhoneNumber,
      'product': product,
      'product_name': productName,
      'product_details': productDetails?.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'buyer_name': buyerName,
      'buyer_address': buyerAddress,
      'buyer_phone_number': buyerPhoneNumber,
      'status': status,
      'status_display': statusDisplay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get unitPriceAsDouble => double.tryParse(unitPrice) ?? 0.0;
  double get totalAmountAsDouble => double.tryParse(totalAmount) ?? 0.0;
}

/// Product details embedded in order response
class OrderProductDetails {
  final int id;
  final String name;
  final String? description;
  final String price;
  final int? category;
  final String? categoryNameEn;
  final String? categoryNameNe;
  final int? unit;
  final String? unitNameEn;
  final String? unitNameNe;
  final String? image;

  OrderProductDetails({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.categoryNameEn,
    this.categoryNameNe,
    this.unit,
    this.unitNameEn,
    this.unitNameNe,
    this.image,
  });

  factory OrderProductDetails.fromJson(Map<String, dynamic> json) {
    return OrderProductDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price']?.toString() ?? '0',
      category: json['category'] as int?,
      categoryNameEn: json['category_name_en'] as String?,
      categoryNameNe: json['category_name_ne'] as String?,
      unit: json['unit'] as int?,
      unitNameEn: json['unit_name_en'] as String?,
      unitNameNe: json['unit_name_ne'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'category_name_en': categoryNameEn,
      'category_name_ne': categoryNameNe,
      'unit': unit,
      'unit_name_en': unitNameEn,
      'unit_name_ne': unitNameNe,
      'image': image,
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;
}

