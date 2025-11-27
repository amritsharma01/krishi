# Marketplace API Documentation - Approval Workflow & Privacy Update

## Overview
This document describes the updated marketplace API with product approval workflow and privacy controls.

### Key Changes
1. **Product Approval Workflow**: Products must be approved by admin before appearing in marketplace
2. **Commission System**: Admin sets commission % which is added to base price
3. **Privacy Controls**: Seller and buyer contact details are hidden from each other
4. **Admin Visibility**: Admin can see all details and manage approvals

---

## Authentication
All endpoints require JWT authentication except public product listing.

**Headers:**
```
Authorization: Bearer <your_jwt_token>
```

---

## Product Lifecycle

### 1. Seller Creates Product (Status: Pending)
```http
POST /api/marketplace/products/
Content-Type: multipart/form-data
```

**Request Body:**
```json
{
  "name": "Fresh Tomatoes",
  "seller_phone_number": "9876543210",
  "seller_address": "Kathmandu, Nepal",
  "category": 1,
  "base_price": "50.00",
  "description": "Fresh organic tomatoes from local farm",
  "unit": 1,
  "image": <file>
}
```

**Response (201):**
```json
{
  "id": 1,
  "name": "Fresh Tomatoes",
  "seller": 2,
  "seller_email": "farmer@example.com",
  "seller_name": "John Farmer",
  "seller_phone_number": "9876543210",
  "seller_address": "Kathmandu, Nepal",
  "category": 1,
  "category_name": "Vegetables",
  "category_name_en": "Vegetables",
  "category_name_ne": "तरकारी",
  "base_price": "50.00",
  "commission_percent": "0.00",
  "final_price": "50.00",
  "description": "Fresh organic tomatoes from local farm",
  "approval_status": "pending",
  "rejection_reason": "",
  "unit": 1,
  "unit_name": "kg",
  "unit_name_en": "kg",
  "unit_name_ne": "केजी",
  "is_available": true,
  "image": "http://example.com/media/products/tomato.jpg",
  "created_at": "2025-11-27T10:30:00Z",
  "updated_at": "2025-11-27T10:30:00Z"
}
```

---

### 2. Admin Approves Product
```http
POST /api/marketplace/products/{id}/approve_product/
Content-Type: application/json
```

**Option A - Set Manual Commission:**
```json
{
  "approval_status": "approved",
  "commission_percent": 10.00
}
```

**Option B - Use Category Default Commission:**
```json
{
  "approval_status": "approved",
  "use_category_commission": true
}
```

**Response (200):**
```json
{
  "id": 1,
  "name": "Fresh Tomatoes",
  "approval_status": "approved",
  "base_price": "50.00",
  "commission_percent": "10.00",
  "final_price": "55.00",
  ...
}
```

**Permissions:** Admin only (`is_staff: true`)

---

### 3. Admin Rejects Product
```http
POST /api/marketplace/products/{id}/reject_product/
Content-Type: application/json
```

**Request Body:**
```json
{
  "approval_status": "rejected",
  "rejection_reason": "Images are not clear. Please upload better quality images."
}
```

**Response (200):**
```json
{
  "id": 1,
  "name": "Fresh Tomatoes",
  "approval_status": "rejected",
  "rejection_reason": "Images are not clear. Please upload better quality images.",
  ...
}
```

**Permissions:** Admin only

---

## Product Listing

### List Products (Public)
```http
GET /api/marketplace/products/
```

**Visibility Rules:**
- **Anonymous/Buyers**: Only approved products
- **Sellers**: Approved products + their own products (all statuses)
- **Admin**: All products (all statuses)

**Query Parameters:**
- `search` - Search in name and description
- `category` - Filter by category ID
- `category_name` - Filter by category name (EN/NE)
- `min_price` - Minimum final price
- `max_price` - Maximum final price
- `approval_status` - Filter by status (admin only)
- `ordering` - Sort by `final_price`, `-final_price`, `created_at`, `-created_at`, `name`, `-name`

**Example:**
```
GET /api/marketplace/products/?category=1&min_price=100&max_price=500
GET /api/marketplace/products/?approval_status=pending  (admin only)
```

**Response (200):**
```json
[
  {
    "id": 1,
    "name": "Fresh Tomatoes",
    "seller": 2,
    "seller_email": null,  // Hidden from buyers
    "seller_name": null,   // Hidden from buyers
    "seller_phone_number": null,  // Hidden from buyers
    "seller_address": null,  // Hidden from buyers
    "category": 1,
    "category_name": "Vegetables",
    "category_name_en": "Vegetables",
    "category_name_ne": "तरकारी",
    "base_price": "50.00",
    "commission_percent": "10.00",
    "final_price": "55.00",
    "approval_status": "approved",
    "unit": 1,
    "unit_name": "kg",
    "is_available": true,
    "image": "http://example.com/media/products/tomato.jpg",
    "created_at": "2025-11-27T10:30:00Z"
  }
]
```

**Privacy Note:**
- Seller contact details (email, name, phone, address) are `null` for buyers
- Seller sees their own contact details
- Admin sees all contact details

---

## Product Detail

### Get Single Product
```http
GET /api/marketplace/products/{id}/
```

**Response:** Same structure as list, privacy rules apply.

---

## Update Product (Seller Only)

### Update Product
```http
PATCH /api/marketplace/products/{id}/
Content-Type: application/json
```

**Request Body (partial update):**
```json
{
  "base_price": "60.00",
  "description": "Updated description"
}
```

**Permissions:**
- Only product owner (seller)
- Cannot update approval-related fields
- If product is approved and price changes, status may reset to pending (implementation dependent)

---

## Delete Product (Seller Only)

```http
DELETE /api/marketplace/products/{id}/
```

**Response (204):** No content

**Permissions:** Only product owner

---

## Categories Management

### List Categories
```http
GET /api/marketplace/categories/
```

**Response (200):**
```json
[
  {
    "id": 1,
    "name_en": "Vegetables",
    "name_ne": "तरकारी",
    "name": "Vegetables",
    "default_commission_percent": "10.00",
    "created_at": "2025-11-27T10:00:00Z"
  }
]
```

### Create Category (Admin Only)
```http
POST /api/marketplace/categories/
Content-Type: application/json
```

**Request Body:**
```json
{
  "name_en": "Vegetables",
  "name_ne": "तरकारी",
  "default_commission_percent": 10.00
}
```

---

## Units Management

### List Units
```http
GET /api/marketplace/units/
```

**Response (200):**
```json
[
  {
    "id": 1,
    "name_en": "kg",
    "name_ne": "केजी",
    "name": "kg",
    "created_at": "2025-11-27T10:00:00Z"
  }
]
```

### Create Unit (Admin Only)
```http
POST /api/marketplace/units/
Content-Type: application/json
```

**Request Body:**
```json
{
  "name_en": "kg",
  "name_ne": "केजी"
}
```

---

## Status Codes

- `200 OK` - Successful GET/PATCH/POST (update)
- `201 Created` - Successful POST (create)
- `204 No Content` - Successful DELETE
- `400 Bad Request` - Invalid data
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Not authorized (e.g., non-admin accessing admin endpoint)
- `404 Not Found` - Resource doesn't exist

---

## Error Response Format

```json
{
  "field_name": ["Error message"],
  "another_field": ["Another error message"]
}
```

**Example:**
```json
{
  "base_price": ["Price must be greater than 0."],
  "seller_address": ["This field is required."]
}
```

---

## User Roles & Permissions

### Anonymous Users
- View approved products only
- No contact details visible

### Buyers (Authenticated)
- View approved products
- Seller contact details hidden
- Can add to cart, place orders

### Sellers (Authenticated)
- View approved products + their own products (all statuses)
- Create new products (status: pending)
- Update/delete their own products
- See their own contact details
- Cannot see other sellers' contact details

### Admin (Staff)
- View all products (all statuses)
- Approve/reject products
- Set commission percentages
- See all contact details (buyers and sellers)
- Manage categories and units

---

## Commission Calculation

**Formula:**
```
final_price = base_price + (base_price × commission_percent / 100)
```

**Example:**
```
base_price = 50.00
commission_percent = 10.00
final_price = 50.00 + (50.00 × 10 / 100) = 55.00
```

---

## Frontend Integration Guide

### Product Creation Flow (Seller)
1. Seller fills product form with base_price and contact details
2. Submit to `POST /api/marketplace/products/`
3. Product created with `approval_status: "pending"`
4. Show message: "Product submitted for approval"

### Product Approval Flow (Admin)
1. Admin views pending products: `GET /api/marketplace/products/?approval_status=pending`
2. Admin clicks approve, sets commission
3. Submit to `POST /api/marketplace/products/{id}/approve_product/`
4. Product becomes visible in marketplace

### Product Display (Buyer)
1. Fetch approved products: `GET /api/marketplace/products/`
2. Display `final_price` (not base_price)
3. Contact details will be `null` - hide these fields
4. Show "Contact seller" button that triggers order/inquiry flow

### Product Management (Seller)
1. Fetch own products: `GET /api/marketplace/products/` (will include own products of all statuses)
2. Show status badge based on `approval_status`
3. If rejected, show `rejection_reason`
4. Allow edit only for pending/rejected products

---

## Quick Reference

| Endpoint | Method | Auth | Role | Description |
|----------|--------|------|------|-------------|
| `/api/marketplace/products/` | GET | Optional | Any | List products (filtered by role) |
| `/api/marketplace/products/` | POST | Required | Seller | Create product (pending) |
| `/api/marketplace/products/{id}/` | GET | Optional | Any | Get product detail |
| `/api/marketplace/products/{id}/` | PATCH | Required | Seller (owner) | Update product |
| `/api/marketplace/products/{id}/` | DELETE | Required | Seller (owner) | Delete product |
| `/api/marketplace/products/{id}/approve_product/` | POST | Required | Admin | Approve product |
| `/api/marketplace/products/{id}/reject_product/` | POST | Required | Admin | Reject product |
| `/api/marketplace/categories/` | GET | None | Any | List categories |
| `/api/marketplace/categories/` | POST | Required | Admin | Create category |
| `/api/marketplace/units/` | GET | None | Any | List units |
| `/api/marketplace/units/` | POST | Required | Admin | Create unit |

---

## Notes for Frontend Developers

1. **Privacy Handling**: Check if contact fields are `null` before displaying
2. **Status Display**: Show clear badges for pending/approved/rejected
3. **Price Display**: Always show `final_price` to buyers, show both to sellers/admin
4. **Commission Display**: Show commission breakdown to sellers (optional for buyers)
5. **Approval UI**: Create admin dashboard for product approval with commission input
6. **Validation**: Handle all field validations on frontend matching backend rules
7. **Bilingual Support**: Use `name_en` or `name_ne` based on user language preference

---

## Migration Instructions

To apply these changes to your database:

```bash
# Activate virtual environment
source venv/bin/activate  # or your env name

# Apply migrations
python manage.py migrate marketplace

# Create superuser if needed
python manage.py createsuperuser

# Run server
python manage.py runserver
```

---

**Last Updated:** November 27, 2025
**API Version:** 2.0

