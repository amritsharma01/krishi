class Product {
  final int id;
  final String name;
  final int seller;
  final String sellerEmail;
  final String? sellerPhoneNumber;
  final int category;
  final String categoryName;
  final String? image;
  final String price;
  final String description;
  final int unit;
  final String unitName;

  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.seller,
    required this.sellerEmail,
    this.sellerPhoneNumber,
    required this.category,
    required this.categoryName,
    this.image,
    required this.price,
    required this.description,
    required this.unit,
    required this.unitName,
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
        sellerPhoneNumber: json['seller_phone_number'] as String?,
        category: (json['category'] as int?) ?? 0,
        categoryName: (json['category_name'] as String?) ?? '',
        image: json['image'] as String?,
        price: json['price']?.toString() ?? '0',
        description: (json['description'] as String?) ?? '',
        unit: (json['unit'] as int?) ?? 0,
        unitName: (json['unit_name'] as String?) ?? '',
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
      'seller_phone_number': sellerPhoneNumber,
      'category': category,
      'category_name': categoryName,
      'image': image,
      'price': price,
      'description': description,
      'unit': unit,
      'unit_name': unitName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;
}
