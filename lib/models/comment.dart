class Comment {
  final int id;
  final int product;
  final String productName;
  final int user;
  final String userEmail;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.product,
    required this.productName,
    required this.user,
    required this.userEmail,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      product: json['product'] as int,
      productName: json['product_name'] as String,
      user: json['user'] as int,
      userEmail: json['user_email'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'product_name': productName,
      'user': user,
      'user_email': userEmail,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

