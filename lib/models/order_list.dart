/// Simplified order model for list view (from /orders/my_purchases/ endpoint)
class OrderList {
  final int id;
  final DateTime createdAt;
  final String totalPrice;

  OrderList({
    required this.id,
    required this.createdAt,
    required this.totalPrice,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalPrice: json['total_price']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'total_price': totalPrice,
    };
  }

  double get totalPriceAsDouble => double.tryParse(totalPrice) ?? 0.0;
}
