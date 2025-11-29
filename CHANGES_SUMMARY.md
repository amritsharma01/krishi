# Order System Changes - Summary

## Overview
The order system has been restructured to support a **cart-based checkout flow** where the entire cart becomes **one single order** that must be **approved by admin** before sellers can see it.

---

## Key Changes

### 1. **New Order Flow**
```
BUYER: Add products to cart
   ↓
BUYER: Checkout (one order created with all cart items)
   ↓
ORDER STATUS: PENDING (waiting for admin approval)
   ↓
ADMIN: Reviews order, can:
   - Add delivery charges
   - Delete products from order
   - Approve or Reject
   ↓
ORDER STATUS: APPROVED (now visible to sellers)
   ↓
SELLER: Sees order in "received orders"
SELLER: Can mark as IN_TRANSIT → DELIVERED
   ↓
BUYER: Marks as COMPLETED
```

---

## Database Changes

### **Order Model** (Updated)
Previously: One order = one product
Now: One order = entire cart (can contain products from multiple sellers)

**New/Modified Fields:**
- `subtotal` - Total cost of all products (before delivery)
- `delivery_charges` - Added by admin (default: 0)
- `total_amount` - subtotal + delivery_charges (auto-calculated)
- `approved_by_admin` - Boolean flag (default: False)
- `admin_approval_date` - Timestamp when admin approved
- **Removed:** `seller`, `product`, `quantity`, `unit_price` fields (moved to OrderItem)

**New Status Values:**
- `PENDING` - "Pending (Waiting for Admin Approval)"
- `APPROVED` - "Approved by Admin" (new status)
- `REJECTED` - "Rejected by Admin" (new status)
- `IN_TRANSIT` - "In Transit"
- `DELIVERED` - "Delivered"
- `COMPLETED` - "Completed"
- `CANCELLED` - "Cancelled"

### **OrderItem Model** (New)
Represents individual products within an order.

**Fields:**
- `order` - ForeignKey to Order
- `product` - ForeignKey to Product
- `seller` - ForeignKey to User (seller of this product)
- `quantity` - Integer
- `unit_price` - Decimal
- `total_price` - Decimal (auto-calculated: quantity × unit_price)
- `created_at` - DateTime
- `updated_at` - DateTime

---

## Admin Panel Changes

### **Order Admin**
1. **Inline OrderItems** - Admin can view/edit/delete products in an order
2. **New Actions:**
   - `Approve selected orders` - Approves pending orders
   - `Reject selected orders` - Rejects pending orders
   - `Mark as in transit` - For approved orders
   - `Mark as delivered` - For in-transit orders
   - `Mark as completed` - For delivered orders

3. **Editable Fields:**
   - `delivery_charges` - Admin can set delivery charges
   - Order items can be deleted by admin

4. **Auto-recalculation:**
   - When order items are added/removed/edited, `subtotal` is recalculated
   - `total_amount` = `subtotal` + `delivery_charges` (auto-updated on save)

5. **Display Changes:**
   - Shows `items_count` instead of single product
   - Shows `subtotal`, `delivery_charges`, and `total_amount`
   - Shows `approved_by_admin` status

---

## API Changes

### **Order Endpoints**

#### **Buyer View** (`GET /api/orders/my_purchases/`)
- Buyer sees **all their orders** (all statuses)
- **Delivery charges** shown only if `approved_by_admin = True`
- If not approved, `delivery_charges` is `null` and `total_amount` shows only `subtotal`

**Response Example (Approved Order):**
```json
{
  "id": 1,
  "buyer_name": "John Doe",
  "buyer_address": "Kathmandu, Nepal",
  "buyer_phone_number": "9841234567",
  "items": [
    {
      "id": 1,
      "product_name": "Fresh Tomatoes",
      "quantity": 2,
      "unit_price": "50.00",
      "total_price": "100.00"
    },
    {
      "id": 2,
      "product_name": "Organic Potatoes",
      "quantity": 5,
      "unit_price": "40.00",
      "total_price": "200.00"
    }
  ],
  "subtotal": "300.00",
  "delivery_charges": "50.00",
  "total_amount": "350.00",
  "status": "approved",
  "status_display": "Approved by Admin",
  "approved_by_admin": true,
  "created_at": "2025-11-29T10:00:00Z"
}
```

**Response Example (Pending Order - Delivery charges hidden):**
```json
{
  "id": 2,
  "items": [...],
  "subtotal": "300.00",
  "delivery_charges": null,
  "total_amount": "300.00",
  "status": "pending",
  "status_display": "Pending (Waiting for Admin Approval)",
  "approved_by_admin": false
}
```

#### **Seller View** (`GET /api/orders/my_sales/`)
- Sellers see **ONLY APPROVED orders** that contain their products
- Shows buyer contact details (name, address, phone) for delivery coordination
- Filters: `approved_by_admin=True` and `items__seller=current_user`

**Response Example:**
```json
{
  "id": 1,
  "buyer_name": "John Doe",
  "buyer_address": "Kathmandu, Nepal",
  "buyer_phone_number": "9841234567",
  "items": [
    {
      "id": 1,
      "product_name": "Fresh Tomatoes",
      "seller_id": "KRSELLER123",
      "quantity": 2,
      "unit_price": "50.00",
      "total_price": "100.00"
    }
  ],
  "subtotal": "100.00",
  "delivery_charges": "50.00",
  "total_amount": "150.00",
  "status": "approved",
  "approved_by_admin": true
}
```

#### **Seller Actions**
1. `POST /api/orders/{id}/start_delivery/` - Mark approved order as IN_TRANSIT
2. `POST /api/orders/{id}/deliver/` - Mark in-transit/approved order as DELIVERED
3. `POST /api/orders/{id}/cancel/` - Cancel order (if not delivered/completed)

**Note:** Sellers can only perform actions on **approved orders** containing their products.

---

### **Cart Checkout** (`POST /api/cart/checkout/`)

#### **Old Behavior:**
- Created **multiple orders** (one per cart item)
- Each order immediately visible to respective seller
- Status: `PENDING` (seller could accept)

#### **New Behavior:**
- Creates **ONE order** with all cart items as `OrderItem` objects
- Order status: `PENDING` (waiting for admin approval)
- `approved_by_admin = False`
- Sellers **cannot see** this order until admin approves

**Request:**
```json
{
  "buyer_name": "John Doe",
  "buyer_address": "Kathmandu, Nepal",
  "buyer_phone_number": "9841234567"
}
```

**Response:**
```json
{
  "message": "Checkout successful. Your order is awaiting admin approval.",
  "order_id": 1,
  "items_count": 3,
  "total_amount": "450.00"
}
```

---

## Permission Changes

### **OrderPermission** (Updated)
```python
# OLD
- Seller could see orders where they are the seller

# NEW
- Seller can see orders ONLY IF:
  1. Order contains their products (items__seller = user)
  2. AND order is approved (approved_by_admin = True)
```

---

## Summary Statistics Changes

### **Seller Sales Summary** (`GET /api/orders/sales_summary/`)
- Now counts from `OrderItem` model (not Order)
- Only includes items from **approved orders**
- Groups by product category

### **Buyer Purchases Summary** (`GET /api/orders/purchases_summary/`)
- Counts from `OrderItem` model
- Includes delivery charges in total
- Groups by product category

### **Admin Commission Report** (`GET /api/orders/commission_report/`)
- Updated to work with `OrderItem` model
- Commission calculated per item: `(final_price - base_price) × quantity`

---

## Migration

A migration file has been created:
```bash
# To apply the migration:
python manage.py migrate orders
```

**Warning:** This is a **breaking change** that restructures the Order model significantly. The migration will:
1. Create new `OrderItem` table
2. Modify existing `Order` table (remove old fields, add new ones)
3. Existing order data may need manual migration if you have production data

---

## Testing Checklist

### **Buyer Flow:**
- [ ] Add products to cart
- [ ] Checkout creates single order with all items
- [ ] Order shows as PENDING
- [ ] Delivery charges NOT visible while pending
- [ ] After admin approval, delivery charges visible
- [ ] Can update contact details (only if PENDING)
- [ ] Can view order details with all items

### **Admin Flow:**
- [ ] See all orders in admin panel
- [ ] Can view order items inline
- [ ] Can add delivery charges
- [ ] Can delete order items
- [ ] Can approve/reject pending orders
- [ ] Subtotal recalculates when items changed

### **Seller Flow:**
- [ ] Cannot see pending orders
- [ ] CAN see approved orders with their products
- [ ] Can view buyer contact details
- [ ] Can mark order as in transit
- [ ] Can mark order as delivered
- [ ] Sales summary works correctly

---

## Breaking Changes

1. **Order Model Structure** - Completely changed
2. **API Responses** - Order serializer returns different fields
3. **Checkout** - Returns single order_id instead of array of order_ids
4. **Seller Visibility** - Sellers now see orders only after admin approval

---

## Next Steps

1. **Run Migration:**
   ```bash
   python manage.py migrate orders
   ```

2. **Test All Flows:**
   - Create test orders through cart checkout
   - Test admin approval workflow
   - Test seller visibility after approval
   - Test delivery charges visibility

3. **Update Frontend:**
   - Order list/detail views
   - Checkout success message
   - Seller dashboard (filter for approved orders)
   - Admin panel customizations

4. **Data Migration (if needed):**
   - If you have existing orders, create a data migration script
   - Map old orders to new structure

---

## Support

All changes are backward compatible at the API level (endpoints remain the same), but the data structure has changed significantly. Update your frontend to handle:
- Single order with multiple items (instead of multiple orders)
- Conditional delivery charges visibility
- New order statuses (PENDING, APPROVED, REJECTED)

