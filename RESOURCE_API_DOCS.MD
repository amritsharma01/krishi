# Resources API Documentation for Flutter Development

Base URL: `http://YOUR_SERVER_IP:8000/api/`

All endpoints are **READ-ONLY** (GET requests only) unless specified otherwise.

---

## 1. FAQs (Frequently Asked Questions)

### List All FAQs
**Endpoint:** `GET /resources/faqs/`

**Description:** Get all active FAQs ordered by display order

**Authentication:** Not required

**Request:** None

**Response:**
```json
[
  {
    "id": 1,
    "question": "How do I register as a seller?",
    "answer": "To register as a seller, go to Account Settings > Profile > Switch to Seller Account. You'll need to provide your farm details and contact information.",
    "order": 1,
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  },
  {
    "id": 2,
    "question": "What payment methods are supported?",
    "answer": "We currently support cash on delivery, eSewa, Khalti, and bank transfer.",
    "order": 2,
    "created_at": "2025-11-18T10:31:00Z",
    "updated_at": "2025-11-18T10:31:00Z"
  }
]
```

### Get Single FAQ
**Endpoint:** `GET /resources/faqs/{id}/`

**Response:**
```json
{
  "id": 1,
  "question": "How do I register as a seller?",
  "answer": "To register as a seller, go to Account Settings > Profile > Switch to Seller Account...",
  "order": 1,
  "created_at": "2025-11-18T10:30:00Z",
  "updated_at": "2025-11-18T10:30:00Z"
}
```

---

## 2. Contacts (Official Contact Information)

### List All Contacts
**Endpoint:** `GET /resources/contacts/`

**Description:** Get all official contact information

**Query Parameters:**
- `contact_type` (optional): Filter by type (`general`, `support`, `technical`, `sales`, `emergency`)

**Example:** `GET /resources/contacts/?contact_type=emergency`

**Response:**
```json
[
  {
    "id": 1,
    "title": "Krishi Support Center",
    "contact_type": "support",
    "contact_type_display": "Support",
    "phone_number": "1155",
    "email": "support@krishi.gov.np",
    "address": "Agriculture Service Center, Kathmandu",
    "description": "24/7 agriculture helpline for farmers",
    "order": 1,
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  },
  {
    "id": 2,
    "title": "Emergency Pest Control",
    "contact_type": "emergency",
    "contact_type_display": "Emergency",
    "phone_number": "16600121212",
    "email": "emergency@moald.gov.np",
    "address": "Ministry of Agriculture and Livestock Development",
    "description": "Emergency contact for pest attacks and crop diseases",
    "order": 2,
    "created_at": "2025-11-18T10:31:00Z",
    "updated_at": "2025-11-18T10:31:00Z"
  }
]
```

### Get Single Contact
**Endpoint:** `GET /resources/contacts/{id}/`

---

## 3. User Manuals (How to Use App)

### List All User Manuals
**Endpoint:** `GET /resources/user-manuals/`

**Description:** Tutorials and guides on how to use the app

**Query Parameters:**
- `category` (optional): Filter by category (`buying`, `selling`, `account`, `orders`, `other`)

**Example:** `GET /resources/user-manuals/?category=buying`

**Response:**
```json
[
  {
    "id": 1,
    "title": "How to Buy Products",
    "content": "Step 1: Browse products...\nStep 2: Add to cart...\nStep 3: Place order...",
    "category": "buying",
    "category_display": "How to Buy",
    "order": 1,
    "image": "http://YOUR_SERVER/media/manuals/buying_guide.jpg",
    "video_url": "https://youtube.com/watch?v=example",
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  },
  {
    "id": 2,
    "title": "How to Sell Products",
    "content": "Step 1: Switch to seller account...\nStep 2: Add product listing...",
    "category": "selling",
    "category_display": "How to Sell",
    "order": 2,
    "image": "http://YOUR_SERVER/media/manuals/selling_guide.jpg",
    "video_url": "",
    "created_at": "2025-11-18T10:31:00Z",
    "updated_at": "2025-11-18T10:31:00Z"
  }
]
```

**Field Notes:**
- `image`: Can be null if no image
- `video_url`: Can be empty string if no video

### Get Single User Manual
**Endpoint:** `GET /resources/user-manuals/{id}/`

---

## 4. Soil Test Information

### List All Soil Test Centers
**Endpoint:** `GET /resources/soil-tests/`

**Description:** Information about soil testing services in different municipalities

**Response:**
```json
[
  {
    "id": 1,
    "title": "Soil Testing Laboratory - Kathmandu",
    "description": "Complete soil analysis service including NPK, pH, organic matter, and micronutrients testing.",
    "municipality_name": "Kathmandu Metropolitan City",
    "contact_person": "Dr. Ram Prasad Sharma",
    "phone_number": "01-4262429",
    "email": "soillab@kathmandu.gov.np",
    "address": "Agriculture Service Center, Harihar Bhawan, Lalitpur",
    "cost": "Rs. 500 for basic test, Rs. 1500 for complete analysis",
    "duration": "7-10 working days",
    "requirements": "Bring 500g soil sample from 6-inch depth, mixed from 5 different spots of your field. Bring in clean plastic bag with farm location details.",
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  }
]
```

### Get Single Soil Test Info
**Endpoint:** `GET /resources/soil-tests/{id}/`

---

## 5. Official Notices

### List All Notices
**Endpoint:** `GET /resources/notices/`

**Description:** Official notices and announcements from government/admin

**Query Parameters:**
- `notice_type` (optional): Filter by type (`general`, `important`, `urgent`, `event`, `training`)

**Example:** `GET /resources/notices/?notice_type=urgent`

**Response:**
```json
[
  {
    "id": 1,
    "title": "Subsidy Program Application Deadline Extended",
    "description": "The application deadline for the government subsidy program on agricultural equipment has been extended to December 31, 2025. Eligible farmers can apply through their local agriculture office.",
    "notice_type": "important",
    "notice_type_display": "Important",
    "pdf_file": "http://YOUR_SERVER/media/notices/pdfs/subsidy_notice.pdf",
    "image": "http://YOUR_SERVER/media/notices/images/subsidy_poster.jpg",
    "published_date": "2025-11-15T09:00:00Z",
    "created_by": 1,
    "created_by_email": "admin@krishi.gov.np",
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  }
]
```

**Field Notes:**
- `pdf_file`: Can be null if notice is text/image only
- `image`: Can be null if notice is PDF/text only
- At least one of `pdf_file` or `image` will be present, or notice will be text-only

### Get Single Notice
**Endpoint:** `GET /resources/notices/{id}/`

---

## 6. Educational Videos

### List All Videos
**Endpoint:** `GET /resources/videos/`

**Description:** YouTube educational videos about farming

**Query Parameters:**
- `category` (optional): Filter by category (`farming`, `pest_control`, `irrigation`, `harvesting`, `storage`, `marketing`, `other`)

**Example:** `GET /resources/videos/?category=farming`

**Response:**
```json
[
  {
    "id": 1,
    "title": "Modern Tomato Farming Techniques",
    "description": "Learn about modern tomato cultivation methods including drip irrigation, staking, and pest management for higher yields.",
    "youtube_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "thumbnail": "http://YOUR_SERVER/media/videos/thumbnails/tomato_thumb.jpg",
    "category": "farming",
    "category_display": "Farming Techniques",
    "duration": "15:30",
    "views_count": 1250,
    "order": 1,
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  }
]
```

**Field Notes:**
- `thumbnail`: Can be null (Flutter can extract from YouTube URL)
- `duration`: Format is "MM:SS" or "HH:MM:SS"
- `views_count`: Read-only, managed by backend

### Get Single Video
**Endpoint:** `GET /resources/videos/{id}/`

---

## 7. Talk to Expert

### List All Experts
**Endpoint:** `GET /resources/experts/`

**Description:** Agricultural experts available for consultation

**Response:**
```json
[
  {
    "id": 1,
    "name": "Dr. Ramesh Kumar Sharma",
    "specialization": "Crop Disease Management",
    "qualifications": "PhD in Plant Pathology, 15 years experience in crop disease diagnosis and management",
    "phone_number": "9851234567",
    "email": "dr.ramesh@agriculture.gov.np",
    "office_address": "Agriculture Research Center, Khumaltar, Lalitpur",
    "available_days": "Sunday to Friday",
    "available_hours": "10:00 AM - 4:00 PM",
    "consultation_fee": "Free for initial consultation, Rs. 500 for farm visit",
    "photo": "http://YOUR_SERVER/media/experts/dr_ramesh.jpg",
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  },
  {
    "id": 2,
    "name": "Er. Sita Devi Poudel",
    "specialization": "Irrigation and Water Management",
    "qualifications": "B.E. Agriculture Engineering, Certified Drip Irrigation Specialist",
    "phone_number": "9841234567",
    "email": "sita.poudel@moald.gov.np",
    "office_address": "District Agriculture Office, Bhaktapur",
    "available_days": "Monday to Friday",
    "available_hours": "9:00 AM - 5:00 PM",
    "consultation_fee": "Free",
    "photo": "http://YOUR_SERVER/media/experts/sita_poudel.jpg",
    "created_at": "2025-11-18T10:31:00Z",
    "updated_at": "2025-11-18T10:31:00Z"
  }
]
```

**Field Notes:**
- `photo`: Can be null
- `email`: Can be empty string
- Users should call/email experts directly for consultation

### Get Single Expert
**Endpoint:** `GET /resources/experts/{id}/`

---

## 8. Agriculture Branch Contacts

### List All Agriculture Branches
**Endpoint:** `GET /resources/agriculture-branches/`

**Description:** Local agriculture department branch offices

**Query Parameters:**
- `district` (optional): Filter by district name

**Example:** `GET /resources/agriculture-branches/?district=Kathmandu`

**Response:**
```json
[
  {
    "id": 1,
    "branch_name": "District Agriculture Development Office",
    "district": "Kathmandu",
    "municipality": "Kathmandu Metropolitan City",
    "address": "Harihar Bhawan, Lalitpur",
    "phone_number": "01-5521197",
    "email": "dado.kathmandu@moald.gov.np",
    "head_officer_name": "Mr. Bishnu Prasad Adhikari",
    "head_officer_contact": "9851234567",
    "services_offered": "- Agricultural extension services\n- Soil testing\n- Seed distribution\n- Training programs\n- Subsidies and grants\n- Technical consultation",
    "office_hours": "Sunday to Friday: 10:00 AM - 5:00 PM",
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  }
]
```

**Field Notes:**
- `services_offered`: Multiline text, can format with bullet points in Flutter
- `email`: Can be empty string

### Get Single Agriculture Branch
**Endpoint:** `GET /resources/agriculture-branches/{id}/`

---

## 9. Service Providers (Goods/Services Purchase)

### List All Service Providers
**Endpoint:** `GET /resources/service-providers/`

**Description:** Contact information for purchasing seeds, fertilizers, equipment, etc.

**Query Parameters:**
- `service_type` (optional): Filter by type (`seeds`, `fertilizer`, `pesticide`, `equipment`, `veterinary`, `transport`, `other`)

**Example:** `GET /resources/service-providers/?service_type=seeds`

**Response:**
```json
[
  {
    "id": 1,
    "business_name": "Annapurna Seeds and Fertilizers",
    "service_type": "seeds",
    "service_type_display": "Seeds",
    "contact_person": "Ram Bahadur Thapa",
    "phone_number": "9801234567",
    "alternate_phone": "01-4123456",
    "email": "info@annapurnaseeds.com.np",
    "address": "Kalimati, Kathmandu (Near Kalimati Fruit Market)",
    "description": "Wide variety of hybrid and open-pollinated vegetable seeds, certified quality seeds with government approval. Also stock organic fertilizers and bio-pesticides.",
    "price_range": "Seeds: Rs. 50 - Rs. 5000 per packet",
    "delivery_available": true,
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  },
  {
    "id": 2,
    "business_name": "Nepal Agriculture Equipment Center",
    "service_type": "equipment",
    "service_type_display": "Equipment/Tools",
    "contact_person": "Shyam Sundar Joshi",
    "phone_number": "9851234567",
    "alternate_phone": "",
    "email": "",
    "address": "Suryabinayak-5, Bhaktapur",
    "description": "Sales and rental of agricultural machinery: tractors, power tillers, water pumps, sprayers, and harvesters. Repair and maintenance services also available.",
    "price_range": "Rental: Rs. 2000/day onwards, Sales: Rs. 50000 onwards",
    "delivery_available": false,
    "created_at": "2025-11-18T10:31:00Z",
    "updated_at": "2025-11-18T10:31:00Z"
  }
]
```

**Field Notes:**
- `alternate_phone`: Can be empty string
- `email`: Can be empty string
- `delivery_available`: Boolean - show "Delivery Available" badge if true

### Get Single Service Provider
**Endpoint:** `GET /resources/service-providers/{id}/`

---

## 10. Agriculture Places

### List All Agriculture Places
**Endpoint:** `GET /resources/agriculture-places/`

**Description:** Important agricultural places like research centers, training centers, markets, etc.

**Query Parameters:**
- `place_type` (optional): Filter by type (`research`, `training`, `demonstration`, `market`, `warehouse`, `other`)
- `district` (optional): Filter by district

**Example:** `GET /resources/agriculture-places/?place_type=research`

**Response:**
```json
[
  {
    "id": 1,
    "place_name": "National Agriculture Research Council (NARC)",
    "place_type": "research",
    "place_type_display": "Research Center",
    "description": "Leading agricultural research institution conducting research on crop improvement, pest management, and sustainable farming practices. Offers training programs and demonstration farms.",
    "address": "Khumaltar, Lalitpur, Nepal",
    "district": "Lalitpur",
    "phone_number": "01-5521074",
    "email": "narc@narc.gov.np",
    "website": "https://narc.gov.np",
    "latitude": "27.663889",
    "longitude": "85.345833",
    "facilities": "- Research laboratories\n- Demonstration farms\n- Training hall (capacity 100)\n- Library\n- Greenhouse facilities\n- Soil testing lab",
    "visiting_hours": "Sunday to Friday: 10:00 AM - 4:00 PM (Prior appointment recommended)",
    "image": "http://YOUR_SERVER/media/places/narc_building.jpg",
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  },
  {
    "id": 2,
    "place_name": "Kalimati Fruit and Vegetable Market",
    "place_type": "market",
    "place_type_display": "Agricultural Market",
    "description": "Largest wholesale fruit and vegetable market in Nepal. Farmers can sell their produce directly. Daily price information available.",
    "address": "Kalimati, Kathmandu",
    "district": "Kathmandu",
    "phone_number": "01-4270033",
    "email": "info@kalimatimarket.gov.np",
    "website": "",
    "latitude": "27.697778",
    "longitude": "85.290278",
    "facilities": "- 200+ wholesale shops\n- Auction platform\n- Cold storage\n- Parking for trucks\n- Banking services",
    "visiting_hours": "Daily: 2:00 AM - 10:00 AM (Peak: 4:00 AM - 7:00 AM)",
    "image": "http://YOUR_SERVER/media/places/kalimati_market.jpg",
    "created_at": "2025-11-18T10:31:00Z",
    "updated_at": "2025-11-18T10:31:00Z"
  }
]
```

**Field Notes:**
- `latitude` & `longitude`: Decimal strings, can be null - use for map integration
- `website`: Can be empty string
- `email`: Can be empty string
- `facilities`: Multiline text with bullet points
- `image`: Can be null

### Get Single Agriculture Place
**Endpoint:** `GET /resources/agriculture-places/{id}/`

---

## 11. Crop Calendar

### List All Crops
**Endpoint:** `GET /resources/crop-calendar/`

**Description:** Planting and harvesting calendar for different crops

**Query Parameters:**
- `crop_type` (optional): Filter by type (`cereal`, `vegetable`, `fruit`, `pulses`, `cash_crop`, `other`)

**Example:** `GET /resources/crop-calendar/?crop_type=vegetable`

**Response:**
```json
[
  {
    "id": 1,
    "crop_name": "Tomato",
    "crop_type": "vegetable",
    "crop_type_display": "Vegetable",
    "planting_season": "September-October (Main), February-March (Off-season)",
    "harvesting_season": "December-February (Main), May-June (Off-season)",
    "duration_days": 90,
    "climate_requirement": "Temperature: 15-30°C optimal. Requires 6-8 hours direct sunlight. Cannot tolerate frost. Best in cool dry weather during fruiting.",
    "soil_type": "Well-drained loamy soil with pH 6.0-7.0. Rich in organic matter.",
    "water_requirement": "Moderate to high water requirement. Critical during flowering and fruit development. Drip irrigation recommended for best results.",
    "best_practices": "- Use certified hybrid seeds for better yield\n- Transplant seedlings after 25-30 days\n- Spacing: 60cm x 45cm\n- Provide staking support\n- Remove side shoots regularly\n- Apply balanced fertilizer (NPK)\n- Mulching helps retain moisture",
    "common_pests": "Early blight, Late blight, Fruit borer, Whitefly, Leaf miner. Use IPM practices for control.",
    "image": "http://YOUR_SERVER/media/crops/tomato.jpg",
    "created_at": "2025-11-18T10:30:00Z",
    "updated_at": "2025-11-18T10:30:00Z"
  },
  {
    "id": 2,
    "crop_name": "Rice (Paddy)",
    "crop_type": "cereal",
    "crop_type_display": "Cereal",
    "planting_season": "June-July (Monsoon season)",
    "harvesting_season": "October-November",
    "duration_days": 120,
    "climate_requirement": "Temperature: 20-35°C. Requires abundant water during growing season. Monsoon rain is ideal.",
    "soil_type": "Clayey loam soil that can retain water. pH 5.5-7.0",
    "water_requirement": "Very high. Requires standing water (2-5 inches) during most of growing period.",
    "best_practices": "- Use certified seeds of high-yielding varieties\n- Prepare nursery 25 days before transplanting\n- Transplant 2-3 seedlings per hill\n- Spacing: 20cm x 15cm\n- Apply urea in 3 splits\n- Keep 2-3 inch water level\n- Drain field 10 days before harvest",
    "common_pests": "Brown planthopper, Stem borer, Blast disease, Bacterial leaf blight. Use light traps and resistant varieties.",
    "image": "http://YOUR_SERVER/media/crops/rice.jpg",
    "created_at": "2025-11-18T10:31:00Z",
    "updated_at": "2025-11-18T10:31:00Z"
  }
]
```

**Field Notes:**
- `duration_days`: Integer - days from planting to harvest
- `image`: Can be null
- All text fields can contain multiline content with formatting

### Get Single Crop
**Endpoint:** `GET /resources/crop-calendar/{id}/`

---

## Common Patterns Across All Endpoints

### Pagination
All list endpoints support pagination:
- Default: Returns all items
- To enable pagination, check response headers or contact backend team

### Filtering
- Use query parameters as shown in examples
- Multiple filters can be combined: `?district=Kathmandu&place_type=research`

### Sorting
- Most endpoints are pre-sorted logically (by order, name, district, etc.)

### Search
Some endpoints may support search parameter:
- `?search=keyword` - searches across relevant text fields

### Error Responses

**404 Not Found:**
```json
{
  "detail": "Not found."
}
```

**500 Server Error:**
```json
{
  "detail": "Internal server error"
}
```

---

## Image URLs

All image fields return absolute URLs like:
- `http://YOUR_SERVER:8000/media/manuals/guide.jpg`

Handle null/empty image URLs gracefully in Flutter:
```dart
image != null && image.isNotEmpty 
  ? NetworkImage(image) 
  : AssetImage('assets/placeholder.png')
```

---

## Tips for Flutter Implementation

1. **Create Model Classes:** Create Dart model classes with `fromJson()` factories for each resource type

2. **Singleton Service:** Create a `ResourcesApiService` singleton for all API calls

3. **Caching:** Consider caching responses locally (SharedPreferences/Hive) since this is mostly static data

4. **Offline Support:** Sync data periodically and show cached data when offline

5. **Image Handling:** Use `CachedNetworkImage` package for efficient image loading

6. **PDF Viewing:** Use `flutter_pdfview` or `syncfusion_flutter_pdfviewer` for notice PDFs

7. **Video Player:** Use `youtube_player_flutter` package for video playback

8. **Phone/Email Links:** Use `url_launcher` package to open phone dialer and email client

9. **Maps:** Use `google_maps_flutter` or similar to show agriculture places on map using lat/long

10. **Search/Filter:** Implement local filtering in Flutter for better UX, or use backend search parameter

---

## Sample Flutter Model

```dart
class FAQ {
  final int id;
  final String question;
  final String answer;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

---

## Need Help?

Contact backend team if you need:
- Additional endpoints
- Modified response formats
- Search/filter capabilities
- Pagination configuration
- Authentication requirements

---

**Last Updated:** November 18, 2025  
**API Version:** 1.0  
**Backend Framework:** Django REST Framework

