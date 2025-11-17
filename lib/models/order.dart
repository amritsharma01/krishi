class Order {
  final int id;
  final int buyer;
  final String buyerEmail;
  final int seller;
  final String sellerEmail;
  final int product;
  final String productName;
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
    required this.product,
    required this.productName,
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
      product: json['product'] as int,
      productName: json['product_name'] as String,
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
      'product': product,
      'product_name': productName,
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

