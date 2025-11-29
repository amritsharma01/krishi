/// Order item representing individual products within an order
class OrderItem {
  final int id;
  final int product;
  final String productName;
  final OrderProductDetails? productDetails;
  final int seller;
  final String sellerEmail;
  final String? sellerKrId;
  final String? sellerPhoneNumber;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.product,
    required this.productName,
    this.productDetails,
    required this.seller,
    required this.sellerEmail,
    this.sellerKrId,
    this.sellerPhoneNumber,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      product: (json['product'] as int?) ?? 0,
      productName: json['product_name']?.toString() ?? '',
      productDetails: json['product_details'] != null
          ? OrderProductDetails.fromJson(
              json['product_details'] as Map<String, dynamic>,
            )
          : null,
      seller: (json['seller'] as int?) ?? 0,
      sellerEmail: json['seller_email']?.toString() ?? '',
      sellerKrId: json['seller_id']?.toString(),
      sellerPhoneNumber: json['seller_phone_number']?.toString(),
      quantity: (json['quantity'] as int?) ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'product_name': productName,
      'product_details': productDetails?.toJson(),
      'seller': seller,
      'seller_email': sellerEmail,
      'seller_id': sellerKrId,
      'seller_phone_number': sellerPhoneNumber,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get unitPriceAsDouble => double.tryParse(unitPrice) ?? 0.0;
  double get totalPriceAsDouble => double.tryParse(totalPrice) ?? 0.0;
}

class Order {
  final int id;
  final int buyer;
  final String buyerEmail;
  final String? buyerKrId;
  final List<OrderItem> items;
  final String subtotal;
  final String? deliveryCharges;
  final String totalAmount;
  final String buyerName;
  final String buyerAddress;
  final String buyerPhoneNumber;
  final String status;
  final String? statusDisplay;
  final bool approvedByAdmin;
  final DateTime? adminApprovalDate;
  final String? cancelledBy;
  final String? cancelledByDisplay;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int?
  _itemsCountFromApi; // Store items_count from simplified API response

  Order({
    required this.id,
    required this.buyer,
    required this.buyerEmail,
    this.buyerKrId,
    required this.items,
    required this.subtotal,
    this.deliveryCharges,
    required this.totalAmount,
    required this.buyerName,
    required this.buyerAddress,
    required this.buyerPhoneNumber,
    required this.status,
    this.statusDisplay,
    required this.approvedByAdmin,
    this.adminApprovalDate,
    this.cancelledBy,
    this.cancelledByDisplay,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
    int? itemsCountFromApi,
  }) : _itemsCountFromApi = itemsCountFromApi;

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle items_count from simplified API response
    int? itemsCountFromApi;
    if (json.containsKey('items_count')) {
      final itemsCountValue = json['items_count'];
      if (itemsCountValue is int) {
        itemsCountFromApi = itemsCountValue;
      } else if (itemsCountValue is String) {
        itemsCountFromApi = int.tryParse(itemsCountValue);
      }
    }

    return Order(
      id: json['id'] as int,
      buyer: (json['buyer'] as int?) ?? 0,
      buyerEmail: json['buyer_email']?.toString() ?? '',
      buyerKrId: json['buyer_id']?.toString(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: json['subtotal']?.toString() ?? '0',
      deliveryCharges: json['delivery_charges']?.toString(),
      totalAmount:
          (json['total_amount'] ?? json['total_price'])?.toString() ?? '0',
      buyerName: (json['buyer_name'] as String?) ?? '',
      buyerAddress: (json['buyer_address'] as String?) ?? '',
      buyerPhoneNumber: (json['buyer_phone_number'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      statusDisplay: json['status_display'] as String?,
      approvedByAdmin: json['approved_by_admin'] as bool? ?? false,
      adminApprovalDate: json['admin_approval_date'] != null
          ? DateTime.parse(json['admin_approval_date'] as String)
          : null,
      cancelledBy: json['cancelled_by'] as String?,
      cancelledByDisplay: json['cancelled_by_display'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(
              json['created_at'] as String,
            ), // Fallback to created_at
      itemsCountFromApi: itemsCountFromApi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer': buyer,
      'buyer_email': buyerEmail,
      'buyer_id': buyerKrId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_charges': deliveryCharges,
      'total_amount': totalAmount,
      'buyer_name': buyerName,
      'buyer_address': buyerAddress,
      'buyer_phone_number': buyerPhoneNumber,
      'status': status,
      'status_display': statusDisplay,
      'approved_by_admin': approvedByAdmin,
      'admin_approval_date': adminApprovalDate?.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancelled_by_display': cancelledByDisplay,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get subtotalAsDouble => double.tryParse(subtotal) ?? 0.0;
  double get deliveryChargesAsDouble =>
      double.tryParse(deliveryCharges ?? '0') ?? 0.0;
  double get totalAmountAsDouble => double.tryParse(totalAmount) ?? 0.0;

  int get itemsCount => _itemsCountFromApi ?? items.length;

  // For backward compatibility - returns first item's details or defaults
  String get productName => items.isNotEmpty ? items.first.productName : '';
  int get quantity => items.fold(0, (sum, item) => sum + item.quantity);

  // Seller info from first item (for backward compatibility)
  int get seller => items.isNotEmpty ? items.first.seller : 0;
  String get sellerEmail => items.isNotEmpty ? items.first.sellerEmail : '';
  String? get sellerKrId => items.isNotEmpty ? items.first.sellerKrId : null;
  String? get sellerPhoneNumber =>
      items.isNotEmpty ? items.first.sellerPhoneNumber : null;

  // Product info from first item (for backward compatibility)
  int get product => items.isNotEmpty ? items.first.product : 0;
  OrderProductDetails? get productDetails =>
      items.isNotEmpty ? items.first.productDetails : null;

  // Helper to check if order has delivery charges set
  bool get hasDeliveryCharges =>
      deliveryCharges != null && deliveryCharges!.isNotEmpty;
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

/// Order item for seller view (from /orders/my_sales/ endpoint)
class OrderItemSeller {
  final int id;
  final int orderId;
  final String orderStatus;
  final DateTime orderDate;
  final int product;
  final String productName;
  final String basePrice;
  final int quantity;

  OrderItemSeller({
    required this.id,
    required this.orderId,
    required this.orderStatus,
    required this.orderDate,
    required this.product,
    required this.productName,
    required this.basePrice,
    required this.quantity,
  });

  factory OrderItemSeller.fromJson(Map<String, dynamic> json) {
    // Handle order_date parsing safely
    DateTime orderDate;
    final orderDateStr = json['order_date']?.toString();
    if (orderDateStr != null && orderDateStr.isNotEmpty) {
      try {
        orderDate = DateTime.parse(orderDateStr);
      } catch (e) {
        // Fallback to current date if parsing fails
        orderDate = DateTime.now();
      }
    } else {
      // Fallback to current date if missing
      orderDate = DateTime.now();
    }

    return OrderItemSeller(
      id: json['id'] as int,
      orderId: json['order_id']?.toInt() ?? 0,
      orderStatus: json['order_status']?.toString() ?? '',
      orderDate: orderDate,
      product: json['product']?.toInt() ?? 0,
      productName: json['product_name']?.toString() ?? '',
      basePrice: json['base_price']?.toString() ?? '0',
      quantity: (json['quantity'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_status': orderStatus,
      'order_date': orderDate.toIso8601String(),
      'product': product,
      'product_name': productName,
      'base_price': basePrice,
      'quantity': quantity,
    };
  }

  double get basePriceAsDouble => double.tryParse(basePrice) ?? 0.0;
  double get totalPriceAsDouble => basePriceAsDouble * quantity;

  // Helper to get status display text
  String get statusDisplay {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return 'Pending (Waiting for Admin Approval)';
      case 'approved':
        return 'Approved by Admin';
      case 'rejected':
        return 'Rejected by Admin';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus;
    }
  }
}
