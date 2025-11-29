class Product {
  final int id;
  final String name;
  final int seller;
  final String sellerEmail;
  final String? sellerName;
  final String? sellerPhoneNumber;
  final String? sellerAddress;
  final String? sellerId;
  final int category;
  final String categoryName;
  final String? categoryNameEn;
  final String? categoryNameNe;
  final String? image;
  final String basePrice;
  final String price; // final price (what buyers pay)
  final String? commissionPercent;
  final String description;
  final int unit;
  final String unitName;
  final String? unitNameEn;
  final String? unitNameNe;
  final String? approvalStatus;
  final String? rejectionReason;
  final bool isAvailable;
  final bool? recommend;
  final bool? freeDelivery;
  final String? rating;
  final String? sellerDescription;

  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.seller,
    required this.sellerEmail,
    this.sellerName,
    this.sellerPhoneNumber,
    this.sellerAddress,
    this.sellerId,
    required this.category,
    required this.categoryName,
    this.categoryNameEn,
    this.categoryNameNe,
    this.image,
    required this.basePrice,
    required this.price,
    this.commissionPercent,
    required this.description,
    required this.unit,
    required this.unitName,
    this.unitNameEn,
    this.unitNameNe,
    this.approvalStatus,
    this.rejectionReason,
    required this.isAvailable,
    this.recommend,
    this.freeDelivery,
    this.rating,
    this.sellerDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      final parsedFinalPrice =
          json['final_price']?.toString() ?? json['price']?.toString() ?? '0';
      return Product(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? '',
        seller: (json['seller'] as int?) ?? 0,
        sellerEmail: (json['seller_email'] as String?) ?? '',
        sellerName: json['seller_name'] as String?,
        sellerPhoneNumber: json['seller_phone_number'] as String?,
        sellerAddress: json['address'] as String?,
        sellerId: json['seller_id']?.toString(),
        category: (json['category'] as int?) ?? 0,
        categoryName: (json['category_name'] as String?) ?? '',
        categoryNameEn: json['category_name_en'] as String?,
        categoryNameNe: json['category_name_ne'] as String?,
        image: json['image'] as String?,
        basePrice: json['base_price']?.toString() ?? parsedFinalPrice,
        price: parsedFinalPrice,
        commissionPercent: json['commission_percent']?.toString(),
        description: (json['description'] as String?) ?? '',
        unit: (json['unit'] as int?) ?? 0,
        unitName: (json['unit_name'] as String?) ?? '',
        unitNameEn: json['unit_name_en'] as String?,
        unitNameNe: json['unit_name_ne'] as String?,
        approvalStatus: json['approval_status'] as String?,
        rejectionReason: json['rejection_reason'] as String?,
        isAvailable: (json['is_available'] as bool?) ?? true,
        recommend: json['recommend'] as bool?,
        freeDelivery: json['free_delivery'] as bool?,
        rating: json['rating']?.toString(),
        sellerDescription: json['seller_description'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing Product JSON: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'seller': seller,
      'seller_email': sellerEmail,
      'seller_name': sellerName,
      'seller_phone_number': sellerPhoneNumber,
      'address': sellerAddress,
      'seller_id': sellerId,
      'category': category,
      'category_name': categoryName,
      'category_name_en': categoryNameEn,
      'category_name_ne': categoryNameNe,
      'image': image,
      'base_price': basePrice,
      'price': price,
      'final_price': price,
      'commission_percent': commissionPercent,
      'description': description,
      'unit': unit,
      'unit_name': unitName,
      'unit_name_en': unitNameEn,
      'unit_name_ne': unitNameNe,
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'is_available': isAvailable,
      'recommend': recommend,
      'free_delivery': freeDelivery,
      'rating': rating,
      'seller_description': sellerDescription,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;
  double get basePriceAsDouble => double.tryParse(basePrice) ?? 0.0;
  bool get isPending => approvalStatus == 'pending';
  bool get isApproved => approvalStatus == 'approved';
  bool get isRejected => approvalStatus == 'rejected';

  String localizedCategoryName(bool isNepali) {
    if (isNepali &&
        categoryNameNe != null &&
        categoryNameNe!.trim().isNotEmpty) {
      return categoryNameNe!;
    }
    if (!isNepali &&
        categoryNameEn != null &&
        categoryNameEn!.trim().isNotEmpty) {
      return categoryNameEn!;
    }
    if (!isNepali && categoryName.trim().isNotEmpty) {
      return categoryName;
    }
    return categoryNameNe?.isNotEmpty == true
        ? categoryNameNe!
        : (categoryNameEn?.isNotEmpty == true ? categoryNameEn! : categoryName);
  }

  String localizedUnitName(bool isNepali) {
    if (isNepali && unitNameNe != null && unitNameNe!.trim().isNotEmpty) {
      return unitNameNe!;
    }
    if (!isNepali && unitNameEn != null && unitNameEn!.trim().isNotEmpty) {
      return unitNameEn!;
    }
    if (!isNepali && unitName.trim().isNotEmpty) {
      return unitName;
    }
    return unitNameNe?.isNotEmpty == true
        ? unitNameNe!
        : (unitNameEn?.isNotEmpty == true ? unitNameEn! : unitName);
  }
}
