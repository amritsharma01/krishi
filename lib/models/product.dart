class Product {
  final int id;
  final String name;
  final int seller;
  final String sellerEmail;
  final String? sellerName;
  final String? sellerPhoneNumber;
  final int category;
  final String categoryName;
  final String? categoryNameEn;
  final String? categoryNameNe;
  final String? image;
  final String price;
  final String description;
  final int unit;
  final String unitName;
  final String? unitNameEn;
  final String? unitNameNe;
  final bool isAvailable;

  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.seller,
    required this.sellerEmail,
    this.sellerName,
    this.sellerPhoneNumber,
    required this.category,
    required this.categoryName,
    this.categoryNameEn,
    this.categoryNameNe,
    this.image,
    required this.price,
    required this.description,
    required this.unit,
    required this.unitName,
    this.unitNameEn,
    this.unitNameNe,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: (json['id'] as int?) ?? 0,
        name: (json['name'] as String?) ?? '',
        seller: (json['seller'] as int?) ?? 0,
        sellerEmail: (json['seller_email'] as String?) ?? '',
        sellerName: json['seller_name'] as String?,
        sellerPhoneNumber: json['seller_phone_number'] as String?,
        category: (json['category'] as int?) ?? 0,
        categoryName: (json['category_name'] as String?) ?? '',
        categoryNameEn: json['category_name_en'] as String?,
        categoryNameNe: json['category_name_ne'] as String?,
        image: json['image'] as String?,
        price: json['price']?.toString() ?? '0',
        description: (json['description'] as String?) ?? '',
        unit: (json['unit'] as int?) ?? 0,
        unitName: (json['unit_name'] as String?) ?? '',
        unitNameEn: json['unit_name_en'] as String?,
        unitNameNe: json['unit_name_ne'] as String?,
        isAvailable: (json['is_available'] as bool?) ?? true,
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
      'category': category,
      'category_name': categoryName,
      'category_name_en': categoryNameEn,
      'category_name_ne': categoryNameNe,
      'image': image,
      'price': price,
      'description': description,
      'unit': unit,
      'unit_name': unitName,
      'unit_name_en': unitNameEn,
      'unit_name_ne': unitNameNe,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;

  String localizedCategoryName(bool isNepali) {
    if (isNepali && categoryNameNe != null && categoryNameNe!.trim().isNotEmpty) {
      return categoryNameNe!;
    }
    if (!isNepali && categoryNameEn != null && categoryNameEn!.trim().isNotEmpty) {
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
