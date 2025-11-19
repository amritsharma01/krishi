/// Summary of buyer's purchases
class PurchasesSummary {
  final int totalOrders;
  final int pendingOrders;
  final int acceptedOrders;
  final int inTransitOrders;
  final int deliveredOrders;
  final int completedOrders;
  final int cancelledOrders;
  final String totalSpent;

  PurchasesSummary({
    required this.totalOrders,
    required this.pendingOrders,
    required this.acceptedOrders,
    required this.inTransitOrders,
    required this.deliveredOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalSpent,
  });

  factory PurchasesSummary.fromJson(Map<String, dynamic> json) {
    return PurchasesSummary(
      totalOrders: json['total_orders'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      acceptedOrders: json['accepted_orders'] as int? ?? 0,
      inTransitOrders: json['in_transit_orders'] as int? ?? 0,
      deliveredOrders: json['delivered_orders'] as int? ?? 0,
      completedOrders: json['completed_orders'] as int? ?? 0,
      cancelledOrders: json['cancelled_orders'] as int? ?? 0,
      totalSpent: json['total_spent']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'accepted_orders': acceptedOrders,
      'in_transit_orders': inTransitOrders,
      'delivered_orders': deliveredOrders,
      'completed_orders': completedOrders,
      'cancelled_orders': cancelledOrders,
      'total_spent': totalSpent,
    };
  }

  double get totalSpentAsDouble => double.tryParse(totalSpent) ?? 0.0;
}

/// Summary of seller's sales by category
class SalesSummary {
  final int totalOrders;
  final int pendingOrders;
  final int acceptedOrders;
  final int inTransitOrders;
  final int deliveredOrders;
  final int completedOrders;
  final int cancelledOrders;
  final String totalRevenue;
  final List<CategorySales> categoryBreakdown;

  SalesSummary({
    required this.totalOrders,
    required this.pendingOrders,
    required this.acceptedOrders,
    required this.inTransitOrders,
    required this.deliveredOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.categoryBreakdown,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalOrders: json['total_orders'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      acceptedOrders: json['accepted_orders'] as int? ?? 0,
      inTransitOrders: json['in_transit_orders'] as int? ?? 0,
      deliveredOrders: json['delivered_orders'] as int? ?? 0,
      completedOrders: json['completed_orders'] as int? ?? 0,
      cancelledOrders: json['cancelled_orders'] as int? ?? 0,
      totalRevenue: json['total_revenue']?.toString() ?? '0',
      categoryBreakdown: (json['category_breakdown'] as List<dynamic>?)
              ?.map((item) => CategorySales.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'pending_orders': pendingOrders,
      'accepted_orders': acceptedOrders,
      'in_transit_orders': inTransitOrders,
      'delivered_orders': deliveredOrders,
      'completed_orders': completedOrders,
      'cancelled_orders': cancelledOrders,
      'total_revenue': totalRevenue,
      'category_breakdown': categoryBreakdown.map((item) => item.toJson()).toList(),
    };
  }

  double get totalRevenueAsDouble => double.tryParse(totalRevenue) ?? 0.0;
}

/// Sales breakdown by category
class CategorySales {
  final String categoryName;
  final String? categoryNameEn;
  final String? categoryNameNe;
  final int orderCount;
  final String revenue;

  CategorySales({
    required this.categoryName,
    this.categoryNameEn,
    this.categoryNameNe,
    required this.orderCount,
    required this.revenue,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      categoryName: json['category_name'] as String? ?? '',
      categoryNameEn: json['category_name_en'] as String?,
      categoryNameNe: json['category_name_ne'] as String?,
      orderCount: json['order_count'] as int? ?? 0,
      revenue: json['revenue']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'category_name_en': categoryNameEn,
      'category_name_ne': categoryNameNe,
      'order_count': orderCount,
      'revenue': revenue,
    };
  }

  double get revenueAsDouble => double.tryParse(revenue) ?? 0.0;
}

