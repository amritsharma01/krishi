# Order Management API Quick Reference

Quick reference guide for developers working with the order management system.

---

## Order Status Flow

```
BUYER VIEW:
Place Order → Pending → Accepted → In Transit → Delivered → Completed
                ↓                                              
            Cancelled

SELLER VIEW:
Receive Order → Pending → Accepted → In Transit → Delivered → Completed
                   ↓          ↓
               Cancelled  Cancelled
```

---

## API Endpoints Summary

### List Orders
```dart
// Get all orders (buyer + seller)
GET /orders/

// Get buyer's orders
GET /orders/my_purchases/

// Get seller's orders
GET /orders/my_sales/

// Get specific order
GET /orders/{id}/
```

### Order Actions
```dart
// Seller accepts order (Pending → Accepted)
POST /orders/{id}/accept/

// Seller marks as in transit (Accepted → In Transit)
POST /orders/{id}/mark_in_transit/

// Seller marks as delivered (In Transit → Delivered)
POST /orders/{id}/deliver/

// Buyer marks as complete (Delivered → Completed)
POST /orders/{id}/complete/

// Cancel order (Any status → Cancelled)
POST /orders/{id}/cancel/
```

### Order Summaries
```dart
// Get buyer's purchase summary
GET /orders/purchases_summary/

// Get seller's sales summary with category breakdown
GET /orders/sales_summary/
```

---

## Code Examples

### Calling Order APIs

```dart
// Get API service instance
final apiService = ref.read(krishiApiServiceProvider);

// Get seller's orders
try {
  final orders = await apiService.getMySales();
  // Handle orders list
} catch (e) {
  // Handle error
}

// Get buyer's orders
try {
  final orders = await apiService.getMyPurchases();
  // Handle orders list
} catch (e) {
  // Handle error
}

// Get specific order details
try {
  final order = await apiService.getOrder(orderId);
  // Handle order details
} catch (e) {
  // Handle error
}

// Accept an order (Seller)
try {
  final updatedOrder = await apiService.acceptOrder(orderId);
  // Show success message
} catch (e) {
  // Show error message
}

// Mark order in transit (Seller)
try {
  final updatedOrder = await apiService.markOrderInTransit(orderId);
  // Show success message
} catch (e) {
  // Show error message
}

// Mark order delivered (Seller)
try {
  final updatedOrder = await apiService.deliverOrder(orderId);
  // Show success message
} catch (e) {
  // Show error message
}

// Complete order (Buyer)
try {
  final updatedOrder = await apiService.completeOrder(orderId);
  // Show success message
} catch (e) {
  // Show error message
}

// Cancel order (Buyer or Seller)
try {
  final updatedOrder = await apiService.cancelOrder(orderId);
  // Show success message
} catch (e) {
  // Show error message
}

// Get purchase summary
try {
  final summary = await apiService.getPurchasesSummary();
  print('Total orders: ${summary.totalOrders}');
  print('Total spent: NPR ${summary.totalSpentAsDouble}');
} catch (e) {
  // Handle error
}

// Get sales summary
try {
  final summary = await apiService.getSalesSummary();
  print('Total orders: ${summary.totalOrders}');
  print('Total revenue: NPR ${summary.totalRevenueAsDouble}');
  for (var category in summary.categoryBreakdown) {
    print('${category.categoryName}: ${category.orderCount} orders');
  }
} catch (e) {
  // Handle error
}
```

### Navigate to Order Pages

```dart
// Navigate to Received Orders (Seller)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OrdersListPage.sales(),
  ),
);

// Navigate to Placed Orders (Buyer)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OrdersListPage.purchases(),
  ),
);

// Navigate to Order Details
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrderDetailPage(
      orderId: order.id,
      isSeller: true, // or false for buyer
    ),
  ),
);
```

### Working with Order Model

```dart
// Access order fields
final orderId = order.id;
final status = order.status; // "pending", "accepted", etc.
final displayStatus = order.statusDisplay; // "Pending", "Accepted", etc.
final totalAmount = order.totalAmountAsDouble; // Converted to double
final unitPrice = order.unitPriceAsDouble; // Converted to double

// Access product details (if available)
if (order.productDetails != null) {
  final productName = order.productDetails!.name;
  final productImage = order.productDetails!.image;
  final categoryName = order.productDetails!.categoryNameEn; // English
  final categoryNameNe = order.productDetails!.categoryNameNe; // Nepali
  final unitName = order.productDetails!.unitNameEn;
}

// Access buyer information (for sellers)
final buyerName = order.buyerName;
final buyerPhone = order.buyerPhoneNumber;
final buyerEmail = order.buyerEmail;
final buyerAddress = order.buyerAddress;

// Access seller information (for buyers)
final sellerEmail = order.sellerEmail;

// Check order status
final isPending = order.status.toLowerCase() == 'pending';
final isAccepted = order.status.toLowerCase() == 'accepted';
final isInTransit = order.status.toLowerCase() == 'in_transit';
final isDelivered = order.status.toLowerCase() == 'delivered';
final isCompleted = order.status.toLowerCase() == 'completed';
final isCancelled = order.status.toLowerCase() == 'cancelled';
```

---

## Translation Keys

### Status Keys
- `pending` - "Pending" / "बाँकी"
- `accepted` - "Accepted" / "स्वीकृत"
- `in_transit` - "In Transit" / "ट्रान्जिटमा"
- `delivered` - "Delivered" / "डेलिभर भयो"
- `completed` - "Completed" / "पूरा भयो"
- `cancelled` - "Cancelled" / "रद्द गरियो"

### Action Keys
- `accept_order` - "Accept Order"
- `cancel_order` - "Cancel Order"
- `mark_in_transit` - "Mark In Transit"
- `mark_delivered` - "Mark Delivered"
- `mark_as_complete` - "Mark as Complete"
- `view_details` - "View Details"

### Message Keys
- `order_accepted` - Success message
- `order_accept_failed` - Error message
- `order_marked_in_transit` - Success message
- `order_transit_failed` - Error message
- `order_delivered` - Success message
- `order_deliver_failed` - Error message
- `order_completed` - Success message
- `order_complete_failed` - Error message
- `order_cancelled` - Success message
- `order_cancel_failed` - Error message

### UI Label Keys
- `order_details` - Page title
- `order_status` - Label
- `order_information` - Section title
- `buyer_information` - Section title
- `seller_info` - Section title
- `order_id` - Label
- `order_date` - Label
- `total_amount` - Label
- `quantity` - Label
- `unit_price` - Label

### Usage
```dart
// In widgets
'order_status'.tr(context)
'accept_order'.tr(context)
'order_accepted'.tr(context)

// In snackbar
Get.snackbar('order_accepted'.tr(context), color: Colors.green);
```

---

## Status Color Scheme

```dart
// Get status colors
(Color bgColor, Color textColor, Color borderColor) = _statusColors(status);

// Pending: Orange
// Accepted/In Transit: Blue
// Delivered: Purple
// Completed: Green
// Cancelled: Red
```

---

## Permission Matrix

| Action | Pending | Accepted | In Transit | Delivered | Completed | Cancelled |
|--------|---------|----------|------------|-----------|-----------|-----------|
| **Seller: Accept** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Seller: Mark In Transit** | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Seller: Mark Delivered** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Seller: Cancel** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Buyer: Complete** | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **Buyer: Cancel** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## Testing Checklist

### Seller Testing
- [ ] View received orders list
- [ ] Tap order to see details
- [ ] Accept a pending order
- [ ] Mark accepted order as in transit
- [ ] Mark in-transit order as delivered
- [ ] Cancel a pending order
- [ ] Try to cancel accepted order
- [ ] View completed orders
- [ ] Check sales summary

### Buyer Testing
- [ ] View placed orders list
- [ ] Tap order to see details
- [ ] Cancel a pending order
- [ ] Mark delivered order as complete
- [ ] View order in transit (read-only)
- [ ] View completed orders
- [ ] Check purchase summary

### Edge Cases
- [ ] Orders with no product images
- [ ] Orders with long names/descriptions
- [ ] Network errors during actions
- [ ] Empty order lists
- [ ] Rapid action button clicks
- [ ] Navigate back after actions

---

## Common Issues & Solutions

### Issue: API returns 403 Forbidden
**Solution:** User doesn't have permission for that action. Check status and user role.

### Issue: Product details are null
**Solution:** Order was created before product_details was added. Use productName fallback.

### Issue: Status not updating after action
**Solution:** Make sure to refresh the order list after returning from detail page.

### Issue: Translation key not found
**Solution:** Check app_translations.dart. Key might be missing or misspelled.

### Issue: Colors not matching design
**Solution:** Use _statusColors() method for consistent color scheme.

---

## Files Reference

- **Models:** `lib/models/order.dart`, `lib/models/order_summary.dart`
- **API Service:** `lib/core/services/api_services/krishi_api_service.dart`
- **Endpoints:** `lib/core/utils/api_endpoints.dart`
- **List Page:** `lib/features/orders/orders_list_page.dart`
- **Detail Page:** `lib/features/orders/order_detail_page.dart`
- **Translations:** `lib/core/configs/app_translations.dart`

---

## Support

For questions or issues:
1. Check the main documentation: `ORDER_MANAGEMENT_IMPLEMENTATION.md`
2. Review the API documentation: `api_documentation.md`
3. Check backend API logs for errors
4. Test with Postman/Swagger to verify backend functionality

---

**Last Updated:** November 18, 2025

