# Orders API - Privacy & Seller ID Update

## Overview
Updated orders API to implement privacy controls between buyers and sellers, with anonymous seller IDs.

---

## Privacy Rules

### For Buyers (My Purchases)
- ✅ See: Order details, product info, **anonymous seller_id**
- ❌ Hidden: Seller email, seller contact details
- ❌ Hidden: Their own contact details in response (already submitted)

### For Sellers (My Sales)
- ✅ See: Order details, product info, **buyer contact details** (for delivery)
- ❌ Hidden: Buyer email, buyer account details

### For Admin
- ✅ See: **Everything** (all buyer and seller details)

---

## Seller ID System

### What is Seller ID?
- A unique, anonymous identifier for each seller
- Format: `S` + 11 uppercase alphanumeric characters
- Example: `S8A9F2E1B4C`
- Consistent for each seller (same seller always gets same ID)
- Cannot be reverse-engineered to reveal seller identity

### How It Works
```python
# Generated using SHA256 hash of user ID and email
seller_id = "S" + hash(user_id + email)[:11].upper()
```

---

## API Endpoints

### 1. Get My Purchases (Buyer)
```http
GET /api/orders/my_purchases/
Authorization: Bearer <buyer_token>
```

**Response (200):**
```json
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "buyer": 2,
      "buyer_email": null,              // ❌ Hidden from buyer
      "buyer_name": null,                // ❌ Hidden from buyer
      "buyer_address": null,             // ❌ Hidden from buyer
      "buyer_phone_number": null,        // ❌ Hidden from buyer
      "seller": 3,
      "seller_id": "S8A9F2E1B4C",       // ✅ Anonymous seller ID
      "seller_email": null,              // ❌ Hidden from buyer
      "product": 5,
      "product_name": "Fresh Tomatoes",
      "product_details": {
        "id": 5,
        "name": "Fresh Tomatoes",
        "description": "Organic tomatoes",
        "price": "55.00",
        "category": 1,
        "category_name_en": "Vegetables",
        "category_name_ne": "तरकारी",
        "unit": 1,
        "unit_name_en": "kg",
        "unit_name_ne": "केजी",
        "image": "http://example.com/media/products/tomato.jpg"
      },
      "quantity": 2,
      "unit_price": "55.00",
      "total_amount": "110.00",
      "status": "pending",
      "status_display": "Pending",
      "cancelled_by": null,
      "cancelled_by_display": null,
      "cancelled_at": null,
      "created_at": "2025-11-27T10:30:00Z",
      "updated_at": "2025-11-27T10:30:00Z"
    }
  ]
}
```

**Key Points for Buyers:**
- Contact fields (`buyer_name`, `buyer_address`, `buyer_phone_number`) return `null`
- Use `seller_id` to identify seller (anonymous)
- Cannot see seller email or contact details

---

### 2. Get My Sales (Seller)
```http
GET /api/orders/my_sales/
Authorization: Bearer <seller_token>
```

**Response (200):**
```json
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "buyer": 2,
      "buyer_email": null,                    // ❌ Hidden from seller
      "buyer_name": "John Doe",               // ✅ Visible (for delivery)
      "buyer_address": "Kathmandu, Nepal",    // ✅ Visible (for delivery)
      "buyer_phone_number": "9876543210",     // ✅ Visible (for delivery)
      "seller": 3,
      "seller_id": "S8A9F2E1B4C",
      "seller_email": null,                   // ❌ Hidden (own email not shown)
      "product": 5,
      "product_name": "Fresh Tomatoes",
      "product_details": {
        "id": 5,
        "name": "Fresh Tomatoes",
        "description": "Organic tomatoes",
        "price": "55.00",
        "category": 1,
        "unit": 1,
        "image": "http://example.com/media/products/tomato.jpg"
      },
      "quantity": 2,
      "unit_price": "55.00",
      "total_amount": "110.00",
      "status": "pending",
      "status_display": "Pending",
      "cancelled_by": null,
      "cancelled_by_display": null,
      "cancelled_at": null,
      "created_at": "2025-11-27T10:30:00Z",
      "updated_at": "2025-11-27T10:30:00Z"
    }
  ]
}
```

**Key Points for Sellers:**
- Can see buyer contact details (name, address, phone) for delivery
- Cannot see buyer email or account information
- `seller_id` is their own anonymous ID

---

### 3. Get Order Detail (Buyer or Seller)
```http
GET /api/orders/{id}/
Authorization: Bearer <token>
```

**Response:** Same privacy rules as above based on user role

---

### 4. Update Contact Details (Buyer Only)
```http
PATCH /api/orders/{id}/update_contact/
Authorization: Bearer <buyer_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "buyer_name": "Updated Name",
  "buyer_address": "Updated Address, Nepal",
  "buyer_phone_number": "9841234567"
}
```

**Response (200):**
```json
{
  "id": 1,
  "buyer_name": null,              // ❌ Not shown in response to buyer
  "buyer_address": null,           // ❌ Not shown in response to buyer
  "buyer_phone_number": null,      // ❌ Not shown in response to buyer
  "message": "Contact details updated successfully"
}
```

**Notes:**
- Buyers can update their contact details
- Updated details are saved but not returned in response (privacy)
- Seller will see updated details in their sales view

---

### 5. Admin View (All Orders)
```http
GET /api/orders/
Authorization: Bearer <admin_token>
```

**Response (200):**
```json
{
  "count": 1,
  "results": [
    {
      "id": 1,
      "buyer": 2,
      "buyer_email": "buyer@example.com",           // ✅ Admin sees all
      "buyer_name": "John Doe",                     // ✅ Admin sees all
      "buyer_address": "Kathmandu, Nepal",          // ✅ Admin sees all
      "buyer_phone_number": "9876543210",           // ✅ Admin sees all
      "seller": 3,
      "seller_id": "S8A9F2E1B4C",
      "seller_email": "seller@example.com",         // ✅ Admin sees all
      "product": 5,
      "product_name": "Fresh Tomatoes",
      ...
    }
  ]
}
```

**Key Points for Admin:**
- Full visibility of all information
- Can see both buyer and seller emails
- Can see all contact details

---

## Privacy Matrix

| Field | Buyer | Seller | Admin |
|-------|-------|--------|-------|
| `buyer_email` | ❌ | ❌ | ✅ |
| `buyer_name` | ❌ | ✅ | ✅ |
| `buyer_address` | ❌ | ✅ | ✅ |
| `buyer_phone_number` | ❌ | ✅ | ✅ |
| `seller_id` | ✅ | ✅ | ✅ |
| `seller_email` | ❌ | ❌ | ✅ |
| Product details | ✅ | ✅ | ✅ |
| Order status | ✅ | ✅ | ✅ |
| Price details | ✅ | ✅ | ✅ |

---

## Frontend Implementation

### Buyer View (My Orders)
```javascript
// Fetch buyer's orders
fetch('/api/orders/my_purchases/', {
  headers: {
    'Authorization': `Bearer ${buyerToken}`
  }
})
.then(res => res.json())
.then(data => {
  data.results.forEach(order => {
    console.log('Order ID:', order.id);
    console.log('Product:', order.product_name);
    console.log('Seller ID:', order.seller_id);  // Anonymous ID
    console.log('Status:', order.status_display);
    
    // Contact fields will be null - don't display
    // order.buyer_name === null
    // order.buyer_address === null
    // order.buyer_phone_number === null
  });
});
```

### Seller View (My Sales)
```javascript
// Fetch seller's orders
fetch('/api/orders/my_sales/', {
  headers: {
    'Authorization': `Bearer ${sellerToken}`
  }
})
.then(res => res.json())
.then(data => {
  data.results.forEach(order => {
    console.log('Order ID:', order.id);
    console.log('Product:', order.product_name);
    
    // Can see buyer contact info for delivery
    console.log('Deliver to:', order.buyer_name);
    console.log('Address:', order.buyer_address);
    console.log('Phone:', order.buyer_phone_number);
    
    // Cannot see buyer email
    // order.buyer_email === null
  });
});
```

### Update Contact Details (Buyer)
```javascript
// Buyer updates their delivery info
fetch(`/api/orders/${orderId}/update_contact/`, {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${buyerToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    buyer_name: 'New Name',
    buyer_address: 'New Address',
    buyer_phone_number: '9841234567'
  })
})
.then(res => res.json())
.then(data => {
  console.log('Contact updated');
  // Note: Response won't show updated details (privacy)
  // Refetch the order or show success message
});
```

---

## UI/UX Recommendations

### For Buyers:
1. Show `seller_id` instead of seller name
2. Display as: "Seller: S8A9F2E1B4C" or "Seller #S8A9F2E1B4C"
3. Add tooltip: "Seller identity is protected for privacy"
4. Don't show empty contact fields (they'll be null)

### For Sellers:
1. Show buyer contact details prominently for delivery
2. Add "Delivery Information" section with:
   - Name: {buyer_name}
   - Address: {buyer_address}
   - Phone: {buyer_phone_number}
3. Don't attempt to show buyer email (it will be null)

### For Both:
1. Handle null values gracefully
2. Don't show fields that return null
3. Use placeholder text like "Protected for privacy" if needed

---

## Example UI Components

### Buyer Order Card
```jsx
<OrderCard>
  <OrderId>#{order.id}</OrderId>
  <ProductName>{order.product_name}</ProductName>
  <SellerInfo>
    <Label>Seller:</Label>
    <SellerId>{order.seller_id}</SellerId>
    <Tooltip>Seller identity protected</Tooltip>
  </SellerInfo>
  <Price>Total: Rs. {order.total_amount}</Price>
  <Status>{order.status_display}</Status>
</OrderCard>
```

### Seller Order Card
```jsx
<OrderCard>
  <OrderId>#{order.id}</OrderId>
  <ProductName>{order.product_name}</ProductName>
  <DeliveryInfo>
    <SectionTitle>Delivery Details</SectionTitle>
    <InfoRow>
      <Label>Name:</Label>
      <Value>{order.buyer_name}</Value>
    </InfoRow>
    <InfoRow>
      <Label>Address:</Label>
      <Value>{order.buyer_address}</Value>
    </InfoRow>
    <InfoRow>
      <Label>Phone:</Label>
      <Value>{order.buyer_phone_number}</Value>
    </InfoRow>
  </DeliveryInfo>
  <Price>Total: Rs. {order.total_amount}</Price>
  <Status>{order.status_display}</Status>
</OrderCard>
```

---

## Technical Notes

1. **Seller ID Generation:**
   - Uses SHA256 hash of `seller_{user_id}_{email}`
   - First 11 characters of hash, prefixed with "S"
   - Deterministic (same seller = same ID always)
   - Cannot be reversed to get seller info

2. **Privacy Implementation:**
   - Uses `SerializerMethodField` for dynamic field values
   - Checks `request.user` to determine what to show
   - Returns `None` for hidden fields (not empty string)

3. **Database:**
   - No changes to database schema required
   - `seller_id` is computed on-the-fly
   - Existing `buyer_name`, `buyer_address`, `buyer_phone_number` fields store actual data
   - Serializer controls what gets returned

4. **Backward Compatibility:**
   - Existing orders work without migration
   - Fields that return `None` should be handled by frontend
   - Admin API unchanged (sees everything)

---

## Migration Instructions

### Backend:
```bash
# No database migration needed for seller_id (computed property)
# But recommended to ensure Profile model is synced
python manage.py makemigrations accounts
python manage.py migrate accounts

# Restart server to apply serializer changes
python manage.py runserver
```

### Frontend:
1. Update order list/detail components to handle `null` values
2. Replace seller name/email with `seller_id` display
3. For sellers: Add delivery information section
4. For buyers: Remove or hide contact detail fields
5. Test with different user roles

---

## Security Considerations

1. **Seller ID is not a secret:**
   - It's meant to be anonymous, not secure
   - Don't use it for authentication
   - It's for display purposes only

2. **Contact Information:**
   - Buyer contact details are necessary for delivery
   - Sellers must see them to fulfill orders
   - This is standard e-commerce practice

3. **Email Privacy:**
   - Both buyer and seller emails are hidden from each other
   - Prevents unwanted direct contact outside platform
   - Admin can see for moderation purposes

4. **Database Security:**
   - Actual data still stored in database
   - Privacy is enforced at API layer
   - Database admins can see all data

---

## Testing Checklist

- [ ] Buyer cannot see their own contact details in response
- [ ] Buyer can see seller_id (anonymous)
- [ ] Buyer cannot see seller email
- [ ] Seller can see buyer contact details (name, address, phone)
- [ ] Seller cannot see buyer email
- [ ] Buyer can update contact details
- [ ] Updated details visible to seller immediately
- [ ] Admin can see all information
- [ ] Seller ID is consistent for same seller
- [ ] Null values handled properly in frontend

---

**Last Updated:** November 27, 2025  
**API Version:** 2.1

