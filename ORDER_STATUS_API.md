# Order Status Change API Documentation

This document provides complete API documentation for order status management and transitions.

## Table of Contents
- [Order Status Flow](#order-status-flow)
- [Authentication](#authentication)
- [Order Statuses](#order-statuses)
- [API Endpoints](#api-endpoints)
  - [List Orders](#list-orders)
  - [Get Order Details](#get-order-details)
  - [Accept Order (Seller)](#accept-order-seller)
  - [Mark In Transit (Seller)](#mark-in-transit-seller)
  - [Mark Delivered (Seller)](#mark-delivered-seller)
  - [Complete Order (Buyer)](#complete-order-buyer)
  - [Cancel Order](#cancel-order)
  - [My Purchases (Buyer)](#my-purchases-buyer)
  - [My Sales (Seller)](#my-sales-seller)

---

## Order Status Flow

```
PENDING → ACCEPTED → IN_TRANSIT → DELIVERED → COMPLETED
    ↓         ↓           ↓
CANCELLED  CANCELLED  CANCELLED
```

### Status Descriptions

| Status | Description | Who Can Set |
|--------|-------------|-------------|
| `pending` | Order placed, awaiting seller acceptance | System (on checkout) |
| `accepted` | Seller has accepted the order | Seller |
| `in_transit` | Order is being delivered | Seller |
| `delivered` | Order delivered to buyer | Seller |
| `completed` | Buyer confirms successful receipt | Buyer |
| `cancelled` | Order cancelled by buyer, seller, or admin | Buyer, Seller, Admin |

---

## Authentication

All endpoints require authentication via token:

```
Authorization: Token <your-auth-token>
```

---

## Order Statuses

### Available Statuses
- `pending` - Initial state after checkout
- `accepted` - Seller accepted the order
- `in_transit` - Order is being delivered
- `delivered` - Order has been delivered
- `completed` - Buyer confirmed receipt
- `cancelled` - Order was cancelled

### Cancelled By Options
When an order is cancelled, the system tracks who cancelled it:
- `buyer` - Cancelled by the buyer
- `seller` - Cancelled by the seller
- `admin` - Cancelled by an administrator

---

## API Endpoints

### Base URL
```
/orders/
```

---

## List Orders

Get all orders for the authenticated user (as buyer or seller).

**Endpoint:** `GET /orders/`

**Authentication:** Required

**Authorization:**
- Buyers see orders where they are the buyer
- Sellers see orders for their products
- Admins see all orders

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "buyer": 2,
    "buyer_email": "buyer@example.com",
    "seller": 3,
    "seller_email": "seller@example.com",
    "product": 5,
    "product_name": "Fresh Tomatoes",
    "product_details": {
      "id": 5,
      "name_en": "Fresh Tomatoes",
      "name_ne": "ताजा टमाटर",
      "category": "Vegetables",
      "unit": "kg"
    },
    "quantity": 3,
    "unit_price": "50.00",
    "total_amount": "150.00",
    "buyer_name": "John Doe",
    "buyer_address": "Kathmandu",
    "buyer_phone_number": "9876543210",
    "status": "pending",
    "cancelled_by": null,
    "cancelled_at": null,
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T10:00:00Z"
  }
]
```

---

## Get Order Details

Retrieve details of a specific order.

**Endpoint:** `GET /orders/{id}/`

**Authentication:** Required

**Authorization:**
- Buyers can view their own orders
- Sellers can view orders for their products
- Admins can view all orders

**Response:** `200 OK`
```json
{
  "id": 1,
  "buyer": 2,
  "buyer_email": "buyer@example.com",
  "seller": 3,
  "seller_email": "seller@example.com",
  "product": 5,
  "product_name": "Fresh Tomatoes",
  "product_details": {
    "id": 5,
    "name_en": "Fresh Tomatoes",
    "name_ne": "ताजा टमाटर",
    "category": "Vegetables",
    "unit": "kg"
  },
  "quantity": 3,
  "unit_price": "50.00",
  "total_amount": "150.00",
  "buyer_name": "John Doe",
  "buyer_address": "Kathmandu",
  "buyer_phone_number": "9876543210",
  "status": "pending",
  "cancelled_by": null,
  "cancelled_at": null,
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T10:00:00Z"
}
```

**Error Responses:**
- `404 Not Found` - Order doesn't exist
- `403 Forbidden` - User not authorized to view this order

---

## Accept Order (Seller)

Seller accepts a pending order.

**Endpoint:** `POST /orders/{id}/accept/`

**Authentication:** Required

**Authorization:** Only the seller can accept their orders

**Request:** No body required

**Valid State Transitions:**
- `pending` → `accepted`

**Response:** `200 OK`
```json
{
  "id": 1,
  "buyer": 2,
  "buyer_email": "buyer@example.com",
  "seller": 3,
  "seller_email": "seller@example.com",
  "product": 5,
  "product_name": "Fresh Tomatoes",
  "quantity": 3,
  "unit_price": "50.00",
  "total_amount": "150.00",
  "buyer_name": "John Doe",
  "buyer_address": "Kathmandu",
  "buyer_phone_number": "9876543210",
  "status": "accepted",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T10:05:00Z"
}
```

**Error Responses:**

`403 Forbidden` - Not the seller
```json
{
  "error": "Only the seller can accept this order."
}
```

`400 Bad Request` - Invalid state transition
```json
{
  "error": "Only pending orders can be accepted."
}
```

---

## Mark In Transit (Seller)

Seller marks an accepted order as in transit during delivery.

**Endpoint:** `POST /orders/{id}/mark_in_transit/`

**Authentication:** Required

**Authorization:** Only the seller can mark orders as in transit

**Request:** No body required

**Valid State Transitions:**
- `accepted` → `in_transit`
- `in_transit` → `in_transit` (idempotent)

**Response:** `200 OK`
```json
{
  "id": 1,
  "status": "in_transit",
  "updated_at": "2025-01-17T10:30:00Z"
}
```

**Error Responses:**

`403 Forbidden` - Not the seller
```json
{
  "error": "Only the seller can update this order."
}
```

`400 Bad Request` - Invalid state transition
```json
{
  "error": "Only accepted orders can be marked as in transit."
}
```

---

## Mark Delivered (Seller)

Seller confirms that the order has been delivered to the buyer.

**Endpoint:** `POST /orders/{id}/deliver/`

**Authentication:** Required

**Authorization:** Only the seller can mark orders as delivered

**Request:** No body required

**Valid State Transitions:**
- `accepted` → `delivered`
- `in_transit` → `delivered`

**Response:** `200 OK`
```json
{
  "id": 1,
  "status": "delivered",
  "updated_at": "2025-01-17T11:00:00Z"
}
```

**Error Responses:**

`403 Forbidden` - Not the seller
```json
{
  "error": "Only the seller can mark this order as delivered."
}
```

`400 Bad Request` - Invalid state transition
```json
{
  "error": "Order must be accepted or in transit before delivery."
}
```

---

## Complete Order (Buyer)

Buyer confirms successful receipt and completion of the order.

**Endpoint:** `POST /orders/{id}/complete/`

**Authentication:** Required

**Authorization:** Only the buyer can complete their orders

**Request:** No body required

**Valid State Transitions:**
- `delivered` → `completed`

**Response:** `200 OK`
```json
{
  "id": 1,
  "status": "completed",
  "updated_at": "2025-01-17T12:00:00Z"
}
```

**Error Responses:**

`403 Forbidden` - Not the buyer
```json
{
  "error": "Only the buyer can mark this order as completed."
}
```

`400 Bad Request` - Already completed
```json
{
  "error": "Order is already completed."
}
```

`400 Bad Request` - Not delivered yet
```json
{
  "error": "Order must be marked as delivered before completion."
}
```

---

## Cancel Order

Cancel an order. Buyers, sellers, or admins can cancel orders.

**Endpoint:** `POST /orders/{id}/cancel/`

**Authentication:** Required

**Authorization:** Buyer, Seller, or Admin

**Request:** No body required

**Valid State Transitions:**
- `pending` → `cancelled`
- `accepted` → `cancelled`
- `in_transit` → `cancelled`

**Not Allowed:**
- Cannot cancel `delivered` orders
- Cannot cancel `completed` orders
- Cannot cancel already `cancelled` orders

**Response:** `200 OK`
```json
{
  "id": 1,
  "status": "cancelled",
  "cancelled_by": "buyer",
  "cancelled_at": "2025-01-17T10:15:00Z",
  "updated_at": "2025-01-17T10:15:00Z"
}
```

**The `cancelled_by` field will be:**
- `"buyer"` - If cancelled by the buyer
- `"seller"` - If cancelled by the seller
- `"admin"` - If cancelled by an admin

**Error Responses:**

`403 Forbidden` - Not authorized
```json
{
  "error": "You are not allowed to cancel this order."
}
```

`400 Bad Request` - Invalid state
```json
{
  "error": "Delivered or completed orders cannot be cancelled."
}
```

---

## My Purchases (Buyer)

Get all orders where the authenticated user is the buyer.

**Endpoint:** `GET /orders/my_purchases/`

**Authentication:** Required

**Authorization:** Authenticated users only

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "seller_email": "seller@example.com",
    "product_name": "Fresh Tomatoes",
    "quantity": 3,
    "total_amount": "150.00",
    "status": "pending",
    "created_at": "2025-01-17T10:00:00Z"
  },
  {
    "id": 2,
    "seller_email": "farmer@example.com",
    "product_name": "Organic Rice",
    "quantity": 10,
    "total_amount": "800.00",
    "status": "delivered",
    "created_at": "2025-01-15T08:00:00Z"
  }
]
```

---

## My Sales (Seller)

Get all orders where the authenticated user is the seller.

**Endpoint:** `GET /orders/my_sales/`

**Authentication:** Required

**Authorization:** Authenticated users only

**Response:** `200 OK`
```json
[
  {
    "id": 3,
    "buyer_email": "customer@example.com",
    "buyer_name": "Jane Smith",
    "buyer_address": "Pokhara, Nepal",
    "buyer_phone_number": "9812345678",
    "product_name": "Fresh Tomatoes",
    "quantity": 5,
    "total_amount": "250.00",
    "status": "accepted",
    "created_at": "2025-01-17T09:00:00Z"
  }
]
```

**Note:** This endpoint includes buyer contact information for delivery coordination.

---

## Frontend Implementation Guide

### Order Status Badge Colors

Suggested color scheme for displaying order statuses:

```javascript
const statusColors = {
  pending: '#FFA500',    // Orange
  accepted: '#4169E1',   // Royal Blue
  in_transit: '#9370DB', // Medium Purple
  delivered: '#32CD32',  // Lime Green
  completed: '#228B22',  // Forest Green
  cancelled: '#DC143C'   // Crimson
};
```

### Order Status Icons

Suggested icons for each status:

```javascript
const statusIcons = {
  pending: '⏳',      // Hourglass
  accepted: '✓',     // Check mark
  in_transit: '🚚',  // Truck
  delivered: '📦',   // Package
  completed: '✅',   // Check mark button
  cancelled: '❌'    // Cross mark
};
```

### Buyer Action Buttons

Based on order status, show appropriate buttons to buyers:

```javascript
function getBuyerActions(order) {
  switch(order.status) {
    case 'pending':
      return ['View Details', 'Cancel Order'];
    case 'accepted':
      return ['View Details', 'Cancel Order'];
    case 'in_transit':
      return ['View Details', 'Cancel Order'];
    case 'delivered':
      return ['View Details', 'Complete Order'];
    case 'completed':
      return ['View Details'];
    case 'cancelled':
      return ['View Details'];
    default:
      return ['View Details'];
  }
}
```

### Seller Action Buttons

Based on order status, show appropriate buttons to sellers:

```javascript
function getSellerActions(order) {
  switch(order.status) {
    case 'pending':
      return ['Accept Order', 'Cancel Order'];
    case 'accepted':
      return ['Mark In Transit', 'Mark Delivered', 'Cancel Order'];
    case 'in_transit':
      return ['Mark Delivered', 'Cancel Order'];
    case 'delivered':
      return ['View Details'];
    case 'completed':
      return ['View Details'];
    case 'cancelled':
      return ['View Details'];
    default:
      return ['View Details'];
  }
}
```

### Example API Calls

#### Accept an Order (Seller)
```javascript
async function acceptOrder(orderId, authToken) {
  const response = await fetch(`/orders/${orderId}/accept/`, {
    method: 'POST',
    headers: {
      'Authorization': `Token ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to accept order');
  }
  
  return await response.json();
}
```

#### Mark Order In Transit (Seller)
```javascript
async function markInTransit(orderId, authToken) {
  const response = await fetch(`/orders/${orderId}/mark_in_transit/`, {
    method: 'POST',
    headers: {
      'Authorization': `Token ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to mark order in transit');
  }
  
  return await response.json();
}
```

#### Mark Order Delivered (Seller)
```javascript
async function markDelivered(orderId, authToken) {
  const response = await fetch(`/orders/${orderId}/deliver/`, {
    method: 'POST',
    headers: {
      'Authorization': `Token ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to mark order as delivered');
  }
  
  return await response.json();
}
```

#### Complete Order (Buyer)
```javascript
async function completeOrder(orderId, authToken) {
  const response = await fetch(`/orders/${orderId}/complete/`, {
    method: 'POST',
    headers: {
      'Authorization': `Token ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to complete order');
  }
  
  return await response.json();
}
```

#### Cancel Order
```javascript
async function cancelOrder(orderId, authToken) {
  const response = await fetch(`/orders/${orderId}/cancel/`, {
    method: 'POST',
    headers: {
      'Authorization': `Token ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to cancel order');
  }
  
  return await response.json();
}
```

#### Get My Purchases (Buyer)
```javascript
async function getMyPurchases(authToken) {
  const response = await fetch('/orders/my_purchases/', {
    method: 'GET',
    headers: {
      'Authorization': `Token ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error('Failed to fetch purchases');
  }
  
  return await response.json();
}
```

#### Get My Sales (Seller)
```javascript
async function getMySales(authToken) {
  const response = await fetch('/orders/my_sales/', {
    method: 'GET',
    headers: {
      'Authorization': `Token ${authToken}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error('Failed to fetch sales');
  }
  
  return await response.json();
}
```

### Error Handling

Always handle errors appropriately in your frontend:

```javascript
try {
  const order = await acceptOrder(orderId, authToken);
  // Update UI with success message
  showSuccessMessage('Order accepted successfully!');
  updateOrderDisplay(order);
} catch (error) {
  // Show error to user
  showErrorMessage(error.message);
}
```

---

## Status Transition Rules Summary

| Current Status | Allowed Actions | Who Can Perform |
|---------------|----------------|-----------------|
| `pending` | Accept, Cancel | Seller (accept), Buyer/Seller/Admin (cancel) |
| `accepted` | Mark In Transit, Deliver, Cancel | Seller |
| `in_transit` | Deliver, Cancel | Seller |
| `delivered` | Complete | Buyer |
| `completed` | None (final state) | - |
| `cancelled` | None (final state) | - |

---

## Notes on Order Reversals

Currently, the system does **not support order reversals** after delivery. Once an order reaches the `delivered` or `completed` state, it cannot be cancelled or reversed through the API.

### Future Enhancement Considerations

If you need to implement returns/refunds in the future, consider:

1. **Return Request System**
   - Add a `return_requested` status
   - Allow buyers to request returns within X days of delivery
   - Sellers approve/reject return requests

2. **Refund Processing**
   - Add a `refunded` status
   - Track refund amounts
   - Integration with payment gateway for automated refunds

3. **Return Tracking**
   - Track return shipment status
   - Add fields for return reason
   - Photo evidence for disputes

### Current Workaround

For now, if a buyer needs to return a delivered order:
1. They should contact the seller directly using the contact information
2. Admins can manually adjust the order in the Django admin panel if needed
3. Consider building a separate dispute/return request system outside the order status flow

---

## Additional Resources

- [Main API Documentation](../API_DOCUMENTATION.md)
- [Flutter Integration Guide](FLUTTER_INTEGRATION.md)
- [Marketplace Setup Guide](MARKETPLACE_SETUP_GUIDE.md)
- [Django Admin Panel](http://your-domain/admin/)

---

## Support

For questions or issues with the order management system:
- Check the Django admin panel for manual order management
- Review server logs for error details
- Contact the development team

Last Updated: November 24, 2025
