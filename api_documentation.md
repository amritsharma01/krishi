# Krishi Server API Documentation

**Base URL:** `http://your-domain.com/api/`  
**Authentication:** Google OAuth 2.0 (No username/password)  
**Content-Type:** `application/json`

---

## 🔐 Authentication Overview

This API uses **Google OAuth 2.0 for authentication only**. There is no manual username/password registration.

**Authentication Flow:**
1. User signs in with Google in Flutter app
2. Flutter app gets Google ID token
3. Send ID token to `/auth/google/mobile/`
4. Backend validates token and returns DRF auth token
5. Use DRF token for all subsequent API calls

**User Profile:**
- Email, first name, last name come from Google account
- Phone number and address are optional (added later in profile)
- Phone number can be verified later but not required for login

---

## Table of Contents

1. [Authentication](#authentication)
2. [Marketplace APIs](#marketplace-apis)
3. [Cart APIs](#cart-apis)
4. [Order APIs](#order-apis)
5. [Review APIs](#review-apis)
6. [Comment APIs](#comment-apis)
7. [Error Handling](#error-handling)
8. [Common Response Codes](#common-response-codes)

---

## Authentication

**Authentication Method:** Google OAuth 2.0 Only  
**No username/password authentication**

### 1. Google OAuth Login (Mobile/Flutter)

**Endpoint:** `POST /auth/google/mobile/`  
**Description:** Authenticate with Google ID token from Flutter app  
**Authentication Required:** No

**Request Body:**
```json
{
  "id_token": "google_id_token_from_flutter_google_signin"
}
```

**Success Response (200):**
```json
{
  "token": "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "is_staff": false,
    "profile": {
      "id": 1,
      "full_name": "John Doe",
      "phone_number": "",
      "address": "",
      "profile_image": null,
      "created_at": "2025-01-17T10:00:00Z",
      "updated_at": "2025-01-17T10:00:00Z"
    }
  },
  "created": false
}
```

**Fields Explanation:**
- `token`: DRF authentication token (use this for subsequent API calls)
- `user`: Complete user object with profile
- `created`: `true` if new user was created, `false` if existing user logged in

**Error Response (400):**
```json
{
  "error": "id_token is required"
}
```

**Error Response (401):**
```json
{
  "error": "Invalid token: Token expired"
}
```

### 2. Get Current User Profile

**Endpoint:** `GET /auth/me/`  
**Description:** Get authenticated user's complete profile  
**Authentication Required:** Yes

**Success Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "is_staff": false,
  "profile": {
    "id": 1,
    "full_name": "John Doe",
    "phone_number": "9876543210",
    "address": "Kathmandu, Nepal",
    "profile_image": "http://domain.com/media/profiles/avatar.jpg",
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T11:00:00Z"
  }
}
```

### 3. Update User Profile

**Endpoint:** `PATCH /auth/me/update/`  
**Description:** Update user profile (name, phone, address)  
**Authentication Required:** Yes

**Request Body (all fields optional):**
```json
{
  "full_name": "John Doe",
  "phone_number": "9876543210",
  "address": "Street 123, Kathmandu, Nepal"
}
```

**Success Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "is_staff": false,
  "profile": {
    "id": 1,
    "full_name": "John Doe",
    "phone_number": "9876543210",
    "address": "Street 123, Kathmandu, Nepal",
    "profile_image": "http://domain.com/media/profiles/avatar.jpg",
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T12:00:00Z"
  }
}
```

**Validation Rules:**
- `full_name`: Minimum 2 characters
- `phone_number`: Minimum 10 digits
- `address`: Minimum 10 characters

**Error Response (400):**
```json
{
  "phone_number": ["Phone number must be at least 10 digits."]
}
```

### 4. Upload Profile Avatar

**Endpoint:** `POST /auth/me/avatar/`  
**Description:** Upload profile picture  
**Authentication Required:** Yes  
**Content-Type:** `multipart/form-data`

**Request Body:**
```
profile_image: <image file>
```

**Success Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "profile": {
    "id": 1,
    "full_name": "John Doe",
    "profile_image": "http://domain.com/media/profiles/avatar_new.jpg",
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T12:30:00Z"
  }
}
```

**Error Response (400):**
```json
{
  "profile_image": ["Upload a valid image. The file you uploaded was either not an image or a corrupted image."]
}
```

### Using Token in Requests

Include the token in the Authorization header for all authenticated requests:

```
Authorization: Token 9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b
```

### Important Notes

1. **No Manual Registration**: Users can only sign up/login via Google OAuth
2. **Email is Unique**: Email from Google account is used as the unique identifier
3. **Profile Fields Optional**: Phone number and address can be added later in the app
4. **Phone Verification**: Phone number can be verified later but not required for login
5. **Google Account Info**: First name and last name come from Google and cannot be changed through the API (change via Google account)
6. **Profile Name**: `full_name` in profile can be different from Google first/last name

---

## Marketplace APIs

### 1. List Product Categories

**Endpoint:** `GET /marketplace/categories/`  
**Description:** Get all product categories with bilingual names  
**Authentication Required:** No

**Query Parameters:**
- `search` (optional): Search in both English and Nepali names
- `ordering` (optional): `name_en`, `-name_en`, `name_ne`, `-name_ne`

**Success Response (200):**
```json
[
  {
    "id": 1,
    "name_en": "Vegetables",
    "name_ne": "तरकारी",
    "name": "Vegetables",
    "created_at": "2025-01-17T10:00:00Z"
  },
  {
    "id": 2,
    "name_en": "Fruits",
    "name_ne": "फलफूल",
    "name": "Fruits",
    "created_at": "2025-01-17T10:01:00Z"
  }
]
```

### 2. Create Product Category (Admin Only)

**Endpoint:** `POST /marketplace/categories/`  
**Description:** Create a new product category  
**Authentication Required:** Yes (Admin)

**Request Body:**
```json
{
  "name_en": "Dairy Products",
  "name_ne": "दुग्ध उत्पादन"
}
```

**Success Response (201):**
```json
{
  "id": 3,
  "name_en": "Dairy Products",
  "name_ne": "दुग्ध उत्पादन",
  "name": "Dairy Products",
  "created_at": "2025-01-17T10:05:00Z"
}
```

### 3. List Units

**Endpoint:** `GET /marketplace/units/`  
**Description:** Get all measurement units with bilingual names  
**Authentication Required:** No

**Success Response (200):**
```json
[
  {
    "id": 1,
    "name_en": "kg",
    "name_ne": "केजी",
    "name": "kg",
    "created_at": "2025-01-17T10:00:00Z"
  },
  {
    "id": 2,
    "name_en": "piece",
    "name_ne": "थान",
    "name": "piece",
    "created_at": "2025-01-17T10:01:00Z"
  }
]
```

### 4. List Products

**Endpoint:** `GET /marketplace/products/`  
**Description:** Get all products with advanced filtering  
**Authentication Required:** No

**Query Parameters:**
- `search` (optional): Search in product name, description
- `category` (optional): Filter by category ID
- `category_name` (optional): Search by category name (English or Nepali)
- `seller_email` (optional): Filter by seller email
- `seller_id` (optional): Filter by seller ID
- `min_price` (optional): Minimum price
- `max_price` (optional): Maximum price
- `ordering` (optional): `name`, `-name`, `price`, `-price`, `created_at`, `-created_at`

**Example Request:**
```
GET /marketplace/products/?category=1&min_price=10&max_price=100&ordering=-created_at
```

**Success Response (200):**
```json
[
  {
    "id": 1,
    "name": "Fresh Tomatoes",
    "description": "Organic red tomatoes",
    "price": "50.00",
    "seller": 2,
    "seller_email": "seller@example.com",
    "seller_phone_number": "9876543210",
    "category": 1,
    "category_name": "Vegetables",
    "category_name_en": "Vegetables",
    "category_name_ne": "तरकारी",
    "unit": 1,
    "unit_name": "kg",
    "unit_name_en": "kg",
    "unit_name_ne": "केजी",
    "image": "http://domain.com/media/products/tomato.jpg",
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T10:00:00Z"
  }
]
```

### 5. Get Product Details

**Endpoint:** `GET /marketplace/products/{id}/`  
**Description:** Get detailed information about a specific product  
**Authentication Required:** No

**Success Response (200):**
```json
{
  "id": 1,
  "name": "Fresh Tomatoes",
  "description": "Organic red tomatoes grown locally",
  "price": "50.00",
  "seller": 2,
  "seller_email": "seller@example.com",
  "seller_phone_number": "9876543210",
  "category": 1,
  "category_name": "Vegetables",
  "category_name_en": "Vegetables",
  "category_name_ne": "तरकारी",
  "unit": 1,
  "unit_name": "kg",
  "unit_name_en": "kg",
  "unit_name_ne": "केजी",
  "image": "http://domain.com/media/products/tomato.jpg",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T10:00:00Z"
}
```

**Error Response (404):**
```json
{
  "detail": "Not found."
}
```

### 6. Create Product (Seller)

**Endpoint:** `POST /marketplace/products/`  
**Description:** Create a new product (seller only)  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "name": "Fresh Potatoes",
  "description": "Local farm potatoes",
  "price": "30.00",
  "category": 1,
  "unit": 1,
  "seller_phone_number": "9876543210",
  "image": "<file upload or URL>"
}
```

**Success Response (201):**
```json
{
  "id": 2,
  "name": "Fresh Potatoes",
  "description": "Local farm potatoes",
  "price": "30.00",
  "seller": 2,
  "seller_email": "seller@example.com",
  "seller_phone_number": "9876543210",
  "category": 1,
  "category_name": "Vegetables",
  "category_name_en": "Vegetables",
  "category_name_ne": "तरकारी",
  "unit": 1,
  "unit_name": "kg",
  "unit_name_en": "kg",
  "unit_name_ne": "केजी",
  "image": "http://domain.com/media/products/potato.jpg",
  "created_at": "2025-01-17T11:00:00Z",
  "updated_at": "2025-01-17T11:00:00Z"
}
```

### 7. Update Product (Seller)

**Endpoint:** `PATCH /marketplace/products/{id}/`  
**Description:** Update product (only seller who created it)  
**Authentication Required:** Yes

**Request Body (partial update):**
```json
{
  "price": "45.00",
  "description": "Updated description"
}
```

**Success Response (200):**
```json
{
  "id": 1,
  "name": "Fresh Tomatoes",
  "description": "Updated description",
  "price": "45.00",
  "seller": 2,
  "seller_email": "seller@example.com",
  "category": 1,
  "unit": 1,
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T11:30:00Z"
}
```

### 8. Delete Product (Seller)

**Endpoint:** `DELETE /marketplace/products/{id}/`  
**Description:** Delete product (only seller who created it)  
**Authentication Required:** Yes

**Success Response (204):**
```
No content
```

**Error Response (403):**
```json
{
  "detail": "You do not have permission to perform this action."
}
```

---

## Cart APIs

### 1. Get Shopping Cart

**Endpoint:** `GET /cart/`  
**Description:** Get user's shopping cart with all items  
**Authentication Required:** Yes

**Success Response (200):**
```json
{
  "id": 1,
  "user": 2,
  "items": [
    {
      "id": 1,
      "product": 5,
      "product_details": {
        "id": 5,
        "name": "Fresh Tomatoes",
        "description": "Organic tomatoes",
        "price": "50.00",
        "category": 1,
        "category_name": "Vegetables",
        "category_name_en": "Vegetables",
        "category_name_ne": "तरकारी",
        "unit": 1,
        "unit_name": "kg",
        "unit_name_en": "kg",
        "unit_name_ne": "केजी",
        "seller": 3,
        "seller_email": "seller@example.com",
        "image": "http://domain.com/media/products/tomato.jpg"
      },
      "quantity": 3,
      "unit_price": "50.00",
      "subtotal": "150.00",
      "created_at": "2025-01-17T10:30:00Z",
      "updated_at": "2025-01-17T10:30:00Z"
    }
  ],
  "items_count": 1,
  "total_amount": "150.00",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T10:30:00Z"
}
```

### 2. Add Product to Cart

**Endpoint:** `POST /cart/add/`  
**Description:** Add a product to cart (adds to existing quantity if already in cart)  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "product_id": 5,
  "quantity": 3
}
```

**Success Response (201):**
```json
{
  "id": 1,
  "user": 2,
  "items": [
    {
      "id": 1,
      "product": 5,
      "product_details": {
        "id": 5,
        "name": "Fresh Tomatoes",
        "price": "50.00",
        "category_name_en": "Vegetables",
        "category_name_ne": "तरकारी"
      },
      "quantity": 3,
      "unit_price": "50.00",
      "subtotal": "150.00"
    }
  ],
  "items_count": 1,
  "total_amount": "150.00"
}
```

**Error Response (404):**
```json
{
  "error": "Product not found."
}
```

**Error Response (400):**
```json
{
  "quantity": ["Ensure this value is greater than or equal to 1."]
}
```

### 3. Update Cart Item Quantity

**Endpoint:** `PATCH /cart/items/{id}/`  
**Description:** Update quantity of a cart item (sets to new value, doesn't add)  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "quantity": 5
}
```

**Success Response (200):**
```json
{
  "id": 1,
  "product": 5,
  "product_details": {
    "id": 5,
    "name": "Fresh Tomatoes",
    "price": "50.00"
  },
  "quantity": 5,
  "unit_price": "50.00",
  "subtotal": "250.00",
  "created_at": "2025-01-17T10:30:00Z",
  "updated_at": "2025-01-17T11:00:00Z"
}
```

### 4. Remove Item from Cart

**Endpoint:** `DELETE /cart/remove/{item_id}/`  
**Description:** Remove a specific item from cart  
**Authentication Required:** Yes

**Success Response (200):**
```json
{
  "message": "Item removed from cart.",
  "product_name": "Fresh Tomatoes"
}
```

**Error Response (404):**
```json
{
  "error": "Cart item not found."
}
```

### 5. Clear Cart

**Endpoint:** `DELETE /cart/clear/`  
**Description:** Remove all items from cart  
**Authentication Required:** Yes

**Success Response (200):**
```json
{
  "message": "Cart cleared successfully.",
  "items_removed": 5
}
```

**Error Response (400):**
```json
{
  "error": "Cart is already empty."
}
```

### 6. Checkout

**Endpoint:** `POST /cart/checkout/`  
**Description:** Create orders from cart items and clear cart  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "buyer_name": "John Doe",
  "buyer_address": "Street 123, Kathmandu, Nepal",
  "buyer_phone_number": "9876543210"
}
```

**Success Response (201):**
```json
{
  "message": "Checkout successful.",
  "orders_created": 3,
  "order_ids": [1, 2, 3]
}
```

**Error Response (400):**
```json
{
  "error": "Cart is empty."
}
```

**Validation Errors (400):**
```json
{
  "buyer_address": ["Please provide a complete delivery address (minimum 10 characters)."],
  "buyer_phone_number": ["Phone number must be at least 10 digits."]
}
```

### 7. List Cart Items

**Endpoint:** `GET /cart/items/`  
**Description:** Get all items in cart  
**Authentication Required:** Yes

**Success Response (200):**
```json
[
  {
    "id": 1,
    "product": 5,
    "product_details": {
      "id": 5,
      "name": "Fresh Tomatoes",
      "price": "50.00"
    },
    "quantity": 3,
    "unit_price": "50.00",
    "subtotal": "150.00",
    "created_at": "2025-01-17T10:30:00Z",
    "updated_at": "2025-01-17T10:30:00Z"
  }
]
```

### 8. Delete Cart Item (Alternative)

**Endpoint:** `DELETE /cart/items/{id}/`  
**Description:** Delete a cart item  
**Authentication Required:** Yes

**Success Response (204):**
```
No content
```

---

## Order APIs

### 1. List Orders

**Endpoint:** `GET /orders/`  
**Description:** Get all orders for user (as buyer or seller)  
**Authentication Required:** Yes

**Success Response (200):**
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
      "name": "Fresh Tomatoes",
      "description": "Organic tomatoes",
      "price": "50.00",
      "category": 1,
      "category_name_en": "Vegetables",
      "category_name_ne": "तरकारी",
      "unit": 1,
      "unit_name_en": "kg",
      "unit_name_ne": "केजी",
      "image": "http://domain.com/media/products/tomato.jpg"
    },
    "quantity": 3,
    "unit_price": "50.00",
    "total_amount": "150.00",
    "buyer_name": "John Doe",
    "buyer_address": "Kathmandu, Nepal",
    "buyer_phone_number": "9876543210",
    "status": "pending",
    "status_display": "Pending",
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T10:00:00Z"
  }
]
```

### 2. Get Order Details

**Endpoint:** `GET /orders/{id}/`  
**Description:** Get detailed information about a specific order  
**Authentication Required:** Yes

**Success Response (200):**
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
    "name": "Fresh Tomatoes",
    "description": "Organic red tomatoes",
    "price": "50.00",
    "category": 1,
    "category_name_en": "Vegetables",
    "category_name_ne": "तरकारी",
    "unit": 1,
    "unit_name_en": "kg",
    "unit_name_ne": "केजी",
    "image": "http://domain.com/media/products/tomato.jpg"
  },
  "quantity": 3,
  "unit_price": "50.00",
  "total_amount": "150.00",
  "buyer_name": "John Doe",
  "buyer_address": "Street 123, Kathmandu, Nepal",
  "buyer_phone_number": "9876543210",
  "status": "pending",
  "status_display": "Pending",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T10:00:00Z"
}
```

**Error Response (404):**
```json
{
  "detail": "Not found."
}
```

**Error Response (403):**
```json
{
  "detail": "You do not have permission to perform this action."
}
```

### 3. Complete Order (Buyer Only)

**Endpoint:** `POST /orders/{id}/complete/`  
**Description:** Mark order as completed (buyer only)  
**Authentication Required:** Yes

**Success Response (200):**
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
  "status": "completed",
  "status_display": "Completed",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T11:00:00Z"
}
```

**Error Response (403):**
```json
{
  "error": "Only the buyer can mark this order as completed."
}
```

**Error Response (400):**
```json
{
  "error": "Order is already completed."
}
```

### 4. Get My Purchases

**Endpoint:** `GET /orders/my_purchases/`  
**Description:** Get all orders where user is the buyer  
**Authentication Required:** Yes

**Success Response (200):**
```json
[
  {
    "id": 1,
    "seller_email": "seller@example.com",
    "product_name": "Fresh Tomatoes",
    "product_details": {
      "name": "Fresh Tomatoes",
      "category_name_en": "Vegetables",
      "category_name_ne": "तरकारी"
    },
    "quantity": 3,
    "total_amount": "150.00",
    "status": "pending",
    "status_display": "Pending",
    "created_at": "2025-01-17T10:00:00Z"
  }
]
```

### 5. Get My Sales

**Endpoint:** `GET /orders/my_sales/`  
**Description:** Get all orders where user is the seller  
**Authentication Required:** Yes

**Success Response (200):**
```json
[
  {
    "id": 1,
    "buyer_email": "buyer@example.com",
    "product_name": "Fresh Tomatoes",
    "product_details": {
      "name": "Fresh Tomatoes",
      "category_name_en": "Vegetables"
    },
    "quantity": 3,
    "total_amount": "150.00",
    "buyer_name": "John Doe",
    "buyer_address": "Kathmandu, Nepal",
    "buyer_phone_number": "9876543210",
    "status": "pending",
    "status_display": "Pending",
    "created_at": "2025-01-17T10:00:00Z"
  }
]
```

---

## Review APIs

### 1. Get Product Reviews

**Endpoint:** `GET /reviews/products/{product_id}/reviews/`  
**Description:** Get all reviews for a specific product  
**Authentication Required:** No

**Success Response (200):**
```json
[
  {
    "id": 1,
    "user": 2,
    "user_email": "buyer@example.com",
    "product": 5,
    "rating": 5,
    "comment": "Excellent product! Very fresh and good quality.",
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T10:00:00Z"
  },
  {
    "id": 2,
    "user": 3,
    "user_email": "another@example.com",
    "product": 5,
    "rating": 4,
    "comment": "Good quality tomatoes.",
    "created_at": "2025-01-17T11:00:00Z",
    "updated_at": "2025-01-17T11:00:00Z"
  }
]
```

### 2. Create Product Review

**Endpoint:** `POST /reviews/products/{product_id}/reviews/`  
**Description:** Create a review for a product (must have purchased)  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "rating": 5,
  "comment": "Excellent product! Very fresh and good quality."
}
```

**Success Response (201):**
```json
{
  "id": 1,
  "user": 2,
  "user_email": "buyer@example.com",
  "product": 5,
  "rating": 5,
  "comment": "Excellent product! Very fresh and good quality.",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T10:00:00Z"
}
```

**Error Response (400):**
```json
{
  "error": "You must purchase this product before reviewing it."
}
```

**Validation Errors (400):**
```json
{
  "rating": ["Rating must be between 1 and 5."],
  "comment": ["Comment must be at least 10 characters long."]
}
```

### 3. Update Review

**Endpoint:** `PATCH /reviews/{id}/`  
**Description:** Update your own review  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "rating": 4,
  "comment": "Updated: Good quality but slightly expensive."
}
```

**Success Response (200):**
```json
{
  "id": 1,
  "user": 2,
  "user_email": "buyer@example.com",
  "product": 5,
  "rating": 4,
  "comment": "Updated: Good quality but slightly expensive.",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T11:30:00Z"
}
```

### 4. Delete Review

**Endpoint:** `DELETE /reviews/{id}/`  
**Description:** Delete your own review  
**Authentication Required:** Yes

**Success Response (204):**
```
No content
```

**Error Response (403):**
```json
{
  "detail": "You do not have permission to perform this action."
}
```

---

## Comment APIs

### 1. Get Product Comments

**Endpoint:** `GET /comments/products/{product_id}/comments/`  
**Description:** Get all comments for a specific product  
**Authentication Required:** No

**Success Response (200):**
```json
[
  {
    "id": 1,
    "user": 2,
    "user_email": "user@example.com",
    "product": 5,
    "text": "Is this product available for bulk orders?",
    "created_at": "2025-01-17T10:00:00Z",
    "updated_at": "2025-01-17T10:00:00Z"
  },
  {
    "id": 2,
    "user": 3,
    "user_email": "another@example.com",
    "product": 5,
    "text": "What is the delivery time?",
    "created_at": "2025-01-17T11:00:00Z",
    "updated_at": "2025-01-17T11:00:00Z"
  }
]
```

### 2. Create Product Comment

**Endpoint:** `POST /comments/products/{product_id}/comments/`  
**Description:** Create a comment on a product  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "text": "Is this product available for bulk orders?"
}
```

**Success Response (201):**
```json
{
  "id": 1,
  "user": 2,
  "user_email": "user@example.com",
  "product": 5,
  "text": "Is this product available for bulk orders?",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T10:00:00Z"
}
```

**Validation Errors (400):**
```json
{
  "text": ["Comment text must be at least 3 characters long."]
}
```

### 3. Update Comment

**Endpoint:** `PATCH /comments/{id}/`  
**Description:** Update your own comment  
**Authentication Required:** Yes

**Request Body:**
```json
{
  "text": "Updated comment: Is delivery available to my area?"
}
```

**Success Response (200):**
```json
{
  "id": 1,
  "user": 2,
  "user_email": "user@example.com",
  "product": 5,
  "text": "Updated comment: Is delivery available to my area?",
  "created_at": "2025-01-17T10:00:00Z",
  "updated_at": "2025-01-17T11:00:00Z"
}
```

### 4. Delete Comment

**Endpoint:** `DELETE /comments/{id}/`  
**Description:** Delete your own comment  
**Authentication Required:** Yes

**Success Response (204):**
```
No content
```

---

## Error Handling

### Common Error Response Format

All API errors follow a consistent format:

**Unauthorized (401):**
```json
{
  "detail": "Authentication credentials were not provided."
}
```

**Forbidden (403):**
```json
{
  "detail": "You do not have permission to perform this action."
}
```

**Not Found (404):**
```json
{
  "detail": "Not found."
}
```

**Validation Error (400):**
```json
{
  "field_name": ["Error message for this field."],
  "another_field": ["Another error message."]
}
```

**Custom Error (400):**
```json
{
  "error": "Descriptive error message."
}
```

**Server Error (500):**
```json
{
  "error": "Internal server error. Please try again later."
}
```

---

## Common Response Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Request successful, no content to return |
| 400 | Bad Request | Invalid request data or validation error |
| 401 | Unauthorized | Authentication required or invalid token |
| 403 | Forbidden | User doesn't have permission |
| 404 | Not Found | Resource not found |
| 500 | Server Error | Internal server error |

---

## Data Models

### Product
```json
{
  "id": "integer",
  "name": "string",
  "description": "string",
  "price": "decimal (string format)",
  "seller": "integer (user ID)",
  "seller_email": "string",
  "seller_phone_number": "string",
  "category": "integer (category ID)",
  "category_name": "string (backward compatibility)",
  "category_name_en": "string",
  "category_name_ne": "string",
  "unit": "integer (unit ID)",
  "unit_name": "string (backward compatibility)",
  "unit_name_en": "string",
  "unit_name_ne": "string",
  "image": "string (URL)",
  "created_at": "datetime (ISO 8601)",
  "updated_at": "datetime (ISO 8601)"
}
```

### Cart
```json
{
  "id": "integer",
  "user": "integer (user ID)",
  "items": "array of CartItem",
  "items_count": "integer",
  "total_amount": "decimal (string format)",
  "created_at": "datetime (ISO 8601)",
  "updated_at": "datetime (ISO 8601)"
}
```

### CartItem
```json
{
  "id": "integer",
  "product": "integer (product ID)",
  "product_details": "Product object",
  "quantity": "integer",
  "unit_price": "decimal (string format)",
  "subtotal": "decimal (string format)",
  "created_at": "datetime (ISO 8601)",
  "updated_at": "datetime (ISO 8601)"
}
```

### Order
```json
{
  "id": "integer",
  "buyer": "integer (user ID)",
  "buyer_email": "string",
  "seller": "integer (user ID)",
  "seller_email": "string",
  "product": "integer (product ID)",
  "product_name": "string",
  "product_details": "object with full product info",
  "quantity": "integer",
  "unit_price": "decimal (string format)",
  "total_amount": "decimal (string format)",
  "buyer_name": "string",
  "buyer_address": "string",
  "buyer_phone_number": "string",
  "status": "string (pending|completed)",
  "status_display": "string (Pending|Completed)",
  "created_at": "datetime (ISO 8601)",
  "updated_at": "datetime (ISO 8601)"
}
```

### Review
```json
{
  "id": "integer",
  "user": "integer (user ID)",
  "user_email": "string",
  "product": "integer (product ID)",
  "rating": "integer (1-5)",
  "comment": "string",
  "created_at": "datetime (ISO 8601)",
  "updated_at": "datetime (ISO 8601)"
}
```

### Comment
```json
{
  "id": "integer",
  "user": "integer (user ID)",
  "user_email": "string",
  "product": "integer (product ID)",
  "text": "string",
  "created_at": "datetime (ISO 8601)",
  "updated_at": "datetime (ISO 8601)"
}
```

---

## Important Notes for Flutter Integration

### 1. **Bilingual Support**
All categories and units have both English (`*_en`) and Nepali (`*_ne`) names. The `name` field (without suffix) is maintained for backward compatibility and defaults to English.

In your Flutter app:
```dart
String getDisplayName(dynamic item, String language) {
  if (language == 'ne') {
    return item['name_ne'] ?? item['name'];
  }
  return item['name_en'] ?? item['name'];
}
```

### 2. **Authentication Token**
Store the token securely (SharedPreferences, Secure Storage) and include it in all authenticated requests:

```dart
final response = await http.get(
  Uri.parse('$baseUrl/cart/'),
  headers: {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  },
);
```

### 3. **Price Format**
Prices are returned as strings (e.g., "50.00"). Parse them as needed:

```dart
double price = double.parse(product['price']);
```

### 4. **Image URLs**
Image URLs are absolute. Load them directly in Flutter:

```dart
Image.network(product['image'])
```

### 5. **DateTime Parsing**
All datetime fields use ISO 8601 format:

```dart
DateTime createdAt = DateTime.parse(order['created_at']);
```

### 6. **Pagination**
For large lists, implement pagination:
```
GET /marketplace/products/?page=1
GET /marketplace/products/?page=2
```

### 7. **Error Handling**
Always check response status codes and handle errors appropriately:

```dart
if (response.statusCode == 200) {
  // Success
  final data = json.decode(response.body);
} else if (response.statusCode == 401) {
  // Redirect to login
} else if (response.statusCode == 400) {
  // Show validation errors
  final errors = json.decode(response.body);
} else {
  // Show generic error
}
```

### 8. **Checkout Flow**
1. User adds products to cart
2. User goes to cart page
3. User clicks checkout
4. Show checkout form (name, address, phone)
5. Call `/cart/checkout/` API
6. Redirect to orders page with created order IDs

### 9. **Order Status**
Orders have two status fields:
- `status`: Technical value ("pending", "completed")
- `status_display`: Human-readable ("Pending", "Completed")

Use `status_display` for UI.

### 10. **Product Search**
Combine filters for powerful search:
```
/marketplace/products/?search=tomato&category=1&min_price=10&max_price=100
```

---

## Complete Flutter Example Flow

### 1. Google OAuth Login
```dart
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

// Sign in with Google
Future<void> signInWithGoogle() async {
  try {
    // 1. Trigger Google Sign-In
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      // User cancelled
      return;
    }
    
    // 2. Get authentication
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    
    if (idToken == null) {
      throw Exception('Failed to get ID token');
    }
    
    // 3. Send ID token to backend
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google/mobile/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_token': idToken,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['token'];
      Map<String, dynamic> user = data['user'];
      bool isNewUser = data['created'];
      
      // Save token and user data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', json.encode(user));
      
      if (isNewUser) {
        // New user - maybe show profile setup screen
        print('Welcome new user!');
      } else {
        // Existing user
        print('Welcome back ${user['email']}!');
      }
    }
  } catch (e) {
    print('Google Sign-In failed: $e');
  }
}
```

### 2. Get Current User Profile
```dart
Future<Map<String, dynamic>?> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  
  final response = await http.get(
    Uri.parse('$baseUrl/auth/me/'),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  return null;
}
```

### 3. Update Profile
```dart
Future<bool> updateProfile({
  String? fullName,
  String? phoneNumber,
  String? address,
}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  
  final Map<String, dynamic> data = {};
  if (fullName != null) data['full_name'] = fullName;
  if (phoneNumber != null) data['phone_number'] = phoneNumber;
  if (address != null) data['address'] = address;
  
  final response = await http.patch(
    Uri.parse('$baseUrl/auth/me/update/'),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );
  
  if (response.statusCode == 200) {
    final userData = json.decode(response.body);
    await prefs.setString('user_data', json.encode(userData));
    return true;
  }
  return false;
}
```

### 4. Upload Avatar
```dart
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<bool> uploadAvatar() async {
  // Pick image
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  
  if (image == null) return false;
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  
  // Create multipart request
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/auth/me/avatar/'),
  );
  
  request.headers['Authorization'] = 'Token $token';
  request.files.add(await http.MultipartFile.fromPath('profile_image', image.path));
  
  final response = await request.send();
  
  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final userData = json.decode(responseData);
    await prefs.setString('user_data', json.encode(userData));
    return true;
  }
  return false;
}
```

### 5. Sign Out
```dart
Future<void> signOut() async {
  // Sign out from Google
  await _googleSignIn.signOut();
  
  // Clear local storage
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  await prefs.remove('user_data');
}
```

### 6. Browse Products
```dart
final response = await http.get(
  Uri.parse('$baseUrl/marketplace/products/'),
);

if (response.statusCode == 200) {
  List products = json.decode(response.body);
  // Display products
}
```

### 7. Add to Cart
```dart
final response = await http.post(
  Uri.parse('$baseUrl/cart/add/'),
  headers: {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  },
  body: json.encode({
    'product_id': 5,
    'quantity': 3,
  }),
);

if (response.statusCode == 201) {
  // Show success message
}
```

### 8. View Cart
```dart
final response = await http.get(
  Uri.parse('$baseUrl/cart/'),
  headers: {'Authorization': 'Token $token'},
);

if (response.statusCode == 200) {
  final cart = json.decode(response.body);
  print('Total: ${cart['total_amount']}');
  print('Items: ${cart['items_count']}');
}
```

### 9. Checkout
```dart
final response = await http.post(
  Uri.parse('$baseUrl/cart/checkout/'),
  headers: {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  },
  body: json.encode({
    'buyer_name': 'John Doe',
    'buyer_address': 'Kathmandu, Nepal',
    'buyer_phone_number': '9876543210',
  }),
);

if (response.statusCode == 201) {
  final result = json.decode(response.body);
  print('Orders created: ${result['orders_created']}');
  // Navigate to orders page
}
```

### 10. View Orders
```dart
final response = await http.get(
  Uri.parse('$baseUrl/orders/my_purchases/'),
  headers: {'Authorization': 'Token $token'},
);

if (response.statusCode == 200) {
  List orders = json.decode(response.body);
  // Display orders
}
```

### 11. Complete Order
```dart
final response = await http.post(
  Uri.parse('$baseUrl/orders/$orderId/complete/'),
  headers: {'Authorization': 'Token $token'},
);

if (response.statusCode == 200) {
  // Show success message
}
```

---

## Testing with Swagger

All APIs can be tested interactively at:
- **Swagger UI:** `http://your-domain.com/swagger/`
- **ReDoc:** `http://your-domain.com/redoc/`

---

**End of Documentation**

For any questions or issues, please contact the backend team.
