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
  final int unitsAvailable;
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
    required this.unitsAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      seller: json['seller'] as int,
      sellerEmail: json['seller_email'] as String,
      sellerPhoneNumber: json['seller_phone_number'] as String?,
      category: json['category'] as int,
      categoryName: json['category_name'] as String,
      image: json['image'] as String?,
      price: json['price'].toString(),
      description: json['description'] as String,
      unit: json['unit'] as int,
      unitName: json['unit_name'] as String,
      unitsAvailable: json['units_available'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
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
      'units_available': unitsAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;
}

