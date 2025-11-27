# API Privacy & User ID System

## 🔒 Complete Privacy Implementation

**TL;DR for Frontend:**
- All users have anonymous `user_id` (format: `U8A9F2E1B4C`)
- **ALL contact details return `null`** (except for admin)
- Buyers see seller `user_id`, sellers see buyer database ID
- Products show seller `user_id` only
- Only admin can see emails, names, phones, addresses

---

## Overview
Complete privacy system with anonymous user IDs for all interactions. Contact details are ONLY visible to admin.

---

## Privacy Rules

### For All Users (Buyers & Sellers)
- ✅ See: Anonymous `user_id` for other users
- ❌ Hidden: All contact details (name, email, phone, address)
- ❌ Hidden: Even their own contact details in API responses

### For Admin Only
- ✅ See: **Everything** (all user details, emails, contacts)

---

## User ID System

### What is User ID?
- A unique, anonymous identifier for EVERY user
- Format: `U` + 11 uppercase alphanumeric characters
- Example: `U8A9F2E1B4C`, `U3D7F9A2E6B`
- Consistent for each user (same user = same ID always)
- Cannot be reverse-engineered to reveal user identity
- Used in products, orders, and all interactions

### How It Works
```python
# Generated using SHA256 hash
user_id = "U" + hash(user_id + email + created_at)[:11].upper()
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
  "results": [
    {
      "id": 1,
      "buyer": 2,
      "buyer_id": "U3D7F9A2E6B",        // ✅ Anonymous buyer ID
      "buyer_email": null,              // ❌ Admin only
      "buyer_name": null,                // ❌ Admin only
      "buyer_address": null,             // ❌ Admin only
      "buyer_phone_number": null,        // ❌ Admin only
      "seller": 3,
      "seller_id": "U8A9F2E1B4C",       // ✅ Anonymous seller ID
      "seller_email": null,              // ❌ Admin only
      "product": 5,
      "product_name": "Fresh Tomatoes",
      "quantity": 2,
      "unit_price": "55.00",
      "total_amount": "110.00",
      "status": "pending",
      "status_display": "Pending",
      "created_at": "2025-11-27T10:30:00Z",
      "updated_at": "2025-11-27T10:30:00Z"
    }
  ]
}
```

**What Buyers See:**
- ✅ Order ID, product, quantity, price, status
- ✅ `buyer_id` - their own anonymous ID (e.g., U3D7F9A2E6B)
- ✅ `seller_id` - anonymous seller identifier (e.g., U8A9F2E1B4C)
- ❌ All contact details are `null`

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
  "results": [
    {
      "id": 1,
      "buyer": 2,
      "buyer_id": "U3D7F9A2E6B",        // ✅ Anonymous buyer ID
      "buyer_email": null,              // ❌ Admin only
      "buyer_name": null,                // ❌ Admin only
      "buyer_address": null,             // ❌ Admin only
      "buyer_phone_number": null,        // ❌ Admin only
      "seller": 3,
      "seller_id": "U8A9F2E1B4C",       // ✅ Anonymous seller ID
      "seller_email": null,              // ❌ Admin only
      "product": 5,
      "product_name": "Fresh Tomatoes",
      "quantity": 2,
      "unit_price": "55.00",
      "total_amount": "110.00",
      "status": "pending",
      "status_display": "Pending",
      "created_at": "2025-11-27T10:30:00Z",
      "updated_at": "2025-11-27T10:30:00Z"
    }
  ]
}
```

**What Sellers See:**
- ✅ Order ID, product, quantity, price, status
- ✅ `buyer_id` - anonymous buyer identifier (e.g., U3D7F9A2E6B)
- ✅ `seller_id` - their own anonymous ID (e.g., U8A9F2E1B4C)
- ❌ All contact details are `null` (buyer info hidden)

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
      "buyer_id": "U3D7F9A2E6B",                    // ✅ Anonymous buyer ID
      "buyer_email": "buyer@example.com",           // ✅ Admin only
      "buyer_name": "John Doe",                     // ✅ Admin only
      "buyer_address": "Kathmandu, Nepal",          // ✅ Admin only
      "buyer_phone_number": "9876543210",           // ✅ Admin only
      "seller": 3,
      "seller_id": "U8A9F2E1B4C",                   // ✅ Anonymous seller ID
      "seller_email": "seller@example.com",         // ✅ Admin only
      "seller_name": "Seller Name",                 // ✅ Admin only
      "seller_phone_number": "9841234567",          // ✅ Admin only
      "seller_address": "Pokhara, Nepal",           // ✅ Admin only
      "product": 5,
      "product_name": "Fresh Tomatoes",
      "quantity": 2,
      "total_amount": "110.00",
      "status": "pending"
    }
  ]
}
```

**What Admin Sees:**
- ✅ **EVERYTHING** - all emails, names, phones, addresses
- ✅ Both buyer and seller complete information
- ✅ Used for moderation and dispute resolution

---

## Products API - Privacy

### Get Products
```http
GET /api/marketplace/products/
```

**Response:**
```json
[{
  "id": 5,
  "name": "Fresh Tomatoes",
  "seller": 3,
  "seller_id": "U8A9F2E1B4C",        // ✅ Anonymous ID
  "seller_email": null,               // ❌ Admin only
  "seller_name": null,                // ❌ Admin only
  "seller_phone_number": null,        // ❌ Admin only
  "seller_address": null,             // ❌ Admin only
  "category": 1,
  "category_name_en": "Vegetables",
  "price": "55.00",
  "description": "Organic tomatoes",
  "image": "http://example.com/media/products/tomato.jpg",
  "approval_status": "approved"
}]
```

**Privacy in Products:**
- ✅ Everyone sees `seller_id` (anonymous)
- ❌ Seller contact details hidden from everyone except admin
- ✅ Product info, price, category visible to all

---

## Complete Privacy Matrix

| Field | Buyer | Seller | Admin |
|-------|-------|--------|-------|
| **Order - Buyer Info** |
| `buyer_id` (user_id) | ✅ | ✅ | ✅ |
| `buyer_email` | ❌ | ❌ | ✅ |
| `buyer_name` | ❌ | ❌ | ✅ |
| `buyer_address` | ❌ | ❌ | ✅ |
| `buyer_phone_number` | ❌ | ❌ | ✅ |
| **Order - Seller Info** |
| `seller_id` (user_id) | ✅ | ✅ | ✅ |
| `seller_email` | ❌ | ❌ | ✅ |
| **Product - Seller Info** |
| `seller_id` (user_id) | ✅ | ✅ | ✅ |
| `seller_email` | ❌ | ❌ | ✅ |
| `seller_name` | ❌ | ❌ | ✅ |
| `seller_phone_number` | ❌ | ❌ | ✅ |
| `seller_address` | ❌ | ❌ | ✅ |
| **General** |
| Product details | ✅ | ✅ | ✅ |
| Order status | ✅ | ✅ | ✅ |
| Price details | ✅ | ✅ | ✅ |

---

## Frontend Implementation

### Buyer View (My Orders)
```javascript
fetch('/api/orders/my_purchases/', {
  headers: { 'Authorization': `Bearer ${buyerToken}` }
})
.then(res => res.json())
.then(data => {
  data.results.forEach(order => {
    // Show basic order info
    console.log('Order ID:', order.id);
    console.log('Product:', order.product_name);
    console.log('Buyer:', order.buyer_id);    // Anonymous: U3D7F9A2E6B
    console.log('Seller:', order.seller_id);  // Anonymous: U8A9F2E1B4C
    console.log('Status:', order.status_display);
    console.log('Total:', order.total_amount);
    
    // All contact fields are null - don't display them
  });
});
```

### Seller View (My Sales)
```javascript
fetch('/api/orders/my_sales/', {
  headers: { 'Authorization': `Bearer ${sellerToken}` }
})
.then(res => res.json())
.then(data => {
  data.results.forEach(order => {
    // Show basic order info
    console.log('Order ID:', order.id);
    console.log('Product:', order.product_name);
    console.log('Buyer:', order.buyer_id);    // Anonymous: U3D7F9A2E6B
    console.log('Seller:', order.seller_id);  // Anonymous: U8A9F2E1B4C
    console.log('Status:', order.status_display);
    console.log('Total:', order.total_amount);
    
    // All contact fields are null - don't display them
    // Contact admin if delivery issues
  });
});
```

### Product View (All Users)
```javascript
fetch('/api/marketplace/products/')
.then(res => res.json())
.then(products => {
  products.forEach(product => {
    console.log('Product:', product.name);
    console.log('Seller:', product.seller_id);  // Anonymous: U8A9F2E1B4C
    console.log('Price:', product.price);
    
    // Seller contact details are all null
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
1. Show `seller_id` (e.g., "Seller: U8A9F2E1B4C")
2. Add tooltip: "Seller identity protected for privacy"
3. Hide all null contact fields
4. Focus on order status and product info

### For Sellers:
1. Show buyer database ID only (not contact info)
2. Add message: "Contact admin for delivery coordination"
3. Hide all null contact fields
4. Focus on order status and product info

### For Both:
1. **Handle null gracefully** - don't display null fields
2. Use anonymous `user_id` for identification
3. Contact details only visible to admin
4. Keep UI focused on order/product information

---

## Example UI Components

### Order Card (Buyer/Seller)
```jsx
<OrderCard>
  <OrderId>#{order.id}</OrderId>
  <ProductName>{order.product_name}</ProductName>
  <UserInfo>
    <Label>{isBuyer ? 'Seller:' : 'Buyer:'}</Label>
    <UserId>{isBuyer ? order.seller_id : order.buyer_id}</UserId>
    <Tooltip>Identity protected for privacy</Tooltip>
  </UserInfo>
  <Price>Total: Rs. {order.total_amount}</Price>
  <Status>{order.status_display}</Status>
  <Note>For delivery issues, contact admin</Note>
</OrderCard>
```

### Product Card
```jsx
<ProductCard>
  <ProductName>{product.name}</ProductName>
  <SellerInfo>
    <Label>Seller:</Label>
    <UserId>{product.seller_id}</UserId>
    <Tooltip>Seller identity protected</Tooltip>
  </SellerInfo>
  <Price>Rs. {product.price}</Price>
  <Category>{product.category_name_en}</Category>
  <Description>{product.description}</Description>
</ProductCard>
```

---

## Key Changes Summary

### What Changed:
1. **User ID System**: All users now have anonymous `user_id` (format: U + 11 chars)
2. **Complete Privacy**: Contact details hidden from everyone except admin
3. **Orders**: Buyer and seller can't see each other's contact info
4. **Products**: Seller details hidden, only `seller_id` shown
5. **Admin Only**: All emails, names, phones, addresses visible only to admin

### Technical Notes

1. **User ID Generation:**
   - Uses SHA256 hash of `user_{id}_{email}_{created_at}`
   - Format: `U` + 11 uppercase characters
   - Example: `U8A9F2E1B4C`, `U3D7F9A2E6B`
   - Deterministic (same user = same ID always)
   - Cannot be reversed to get user info

2. **Privacy Implementation:**
   - Uses `SerializerMethodField` for all contact fields
   - Checks `request.user.is_staff` for admin
   - Returns `None` for hidden fields
   - Contact data stored in database, hidden at API layer

3. **No Database Changes:**
   - `user_id` computed on-the-fly (property)
   - Existing data structure unchanged
   - Works with existing orders and products

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

**Privacy Tests:**
- [ ] Buyer cannot see any contact details (all null)
- [ ] Buyer sees seller `user_id` (anonymous)
- [ ] Seller cannot see buyer contact details (all null)
- [ ] Seller sees buyer database ID only
- [ ] Products show `seller_id` but no seller contact info
- [ ] Admin sees ALL information (emails, names, phones, addresses)

**User ID Tests:**
- [ ] User ID format is correct (U + 11 uppercase chars)
- [ ] Same user always gets same ID
- [ ] User ID appears in products
- [ ] User ID appears in orders

**Frontend Tests:**
- [ ] Null values handled without errors
- [ ] No attempt to display null fields
- [ ] UI shows anonymous IDs clearly
- [ ] No broken layouts from missing data

---

**Last Updated:** November 27, 2025  
**API Version:** 2.1

