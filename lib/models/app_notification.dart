class AppNotification {
  final int id;
  final String notificationType;
  final String notificationTypeDisplay;
  final String title;
  final String message;
  final int? relatedOrderId;
  final int? relatedProductId;
  final int? relatedReviewId;
  final int? relatedCommentId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.notificationType,
    required this.notificationTypeDisplay,
    required this.title,
    required this.message,
    this.relatedOrderId,
    this.relatedProductId,
    this.relatedReviewId,
    this.relatedCommentId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return AppNotification(
      id: parseNullableInt(json['id']) ?? 0,
      notificationType: (json['notification_type'] as String?) ?? '',
      notificationTypeDisplay:
          (json['notification_type_display'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      relatedOrderId: parseNullableInt(json['related_order_id']),
      relatedProductId: parseNullableInt(json['related_product_id']),
      relatedReviewId: parseNullableInt(json['related_review_id']),
      relatedCommentId: parseNullableInt(json['related_comment_id']),
      isRead: json['is_read'] as bool? ?? false,
      readAt: parseNullableDate(json['read_at']),
      createdAt: parseNullableDate(json['created_at']) ?? DateTime.now(),
    );
  }

  AppNotification copyWith({
    int? id,
    String? notificationType,
    String? notificationTypeDisplay,
    String? title,
    String? message,
    int? relatedOrderId,
    int? relatedProductId,
    int? relatedReviewId,
    int? relatedCommentId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      notificationTypeDisplay:
          notificationTypeDisplay ?? this.notificationTypeDisplay,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      relatedProductId: relatedProductId ?? this.relatedProductId,
      relatedReviewId: relatedReviewId ?? this.relatedReviewId,
      relatedCommentId: relatedCommentId ?? this.relatedCommentId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

