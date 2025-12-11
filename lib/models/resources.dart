// Resource models for the Krishi app

// 1. Notice Model
class Notice {
  final int id;
  final String title;
  final String description;
  final String noticeType;
  final String noticeTypeDisplay;
  final String? pdfFile;
  final String? image;
  final DateTime publishedDate;
  final int createdBy;
  final String createdByEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.noticeType,
    required this.noticeTypeDisplay,
    this.pdfFile,
    this.image,
    required this.publishedDate,
    required this.createdBy,
    required this.createdByEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    }

    return Notice(
      id: parseInt(json['id']),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      noticeType: (json['notice_type'] as String?) ?? '',
      noticeTypeDisplay: (json['notice_type_display'] as String?) ?? '',
      pdfFile: json['pdf_file'] as String?,
      image: json['image'] as String?,
      publishedDate: json['published_date'] != null
          ? DateTime.parse(json['published_date'] as String)
          : DateTime.now(),
      createdBy: parseInt(json['created_by']),
      createdByEmail: (json['created_by_email'] as String?) ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// 2. Video Model
class Video {
  final int id;
  final String title;
  final String description;
  final String youtubeUrl;
  final String? thumbnail;
  final String category;
  final String categoryDisplay;
  final String duration;
  final int viewsCount;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    this.thumbnail,
    required this.category,
    required this.categoryDisplay,
    required this.duration,
    required this.viewsCount,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int? ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      youtubeUrl: (json['youtube_url'] as String?) ?? '',
      thumbnail: json['thumbnail'] as String?,
      category: (json['category'] as String?) ?? '',
      categoryDisplay: (json['category_display'] as String?) ?? '',
      duration: (json['duration'] as String?) ?? '',
      viewsCount: json['views_count'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  String get youtubeVideoId {
    final uri = Uri.parse(youtubeUrl);
    return uri.queryParameters['v'] ?? '';
  }
}

// 3. Crop Calendar Model
class CropCalendar {
  final int id;
  final String cropName;
  final String cropType;
  final String cropTypeDisplay;
  final String plantingSeason;
  final String harvestingSeason;
  final int durationDays;
  final String climateRequirement;
  final String soilType;
  final String waterRequirement;
  final String bestPractices;
  final String commonPests;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  CropCalendar({
    required this.id,
    required this.cropName,
    required this.cropType,
    required this.cropTypeDisplay,
    required this.plantingSeason,
    required this.harvestingSeason,
    required this.durationDays,
    required this.climateRequirement,
    required this.soilType,
    required this.waterRequirement,
    required this.bestPractices,
    required this.commonPests,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CropCalendar.fromJson(Map<String, dynamic> json) {
    return CropCalendar(
      id: json['id'] as int? ?? 0,
      cropName: (json['crop_name'] as String?) ?? '',
      cropType: (json['crop_type'] as String?) ?? '',
      cropTypeDisplay: (json['crop_type_display'] as String?) ?? '',
      plantingSeason: (json['planting_season'] as String?) ?? '',
      harvestingSeason: (json['harvesting_season'] as String?) ?? '',
      durationDays: json['duration_days'] as int? ?? 0,
      climateRequirement: (json['climate_requirement'] as String?) ?? '',
      soilType: (json['soil_type'] as String?) ?? '',
      waterRequirement: (json['water_requirement'] as String?) ?? '',
      bestPractices: (json['best_practices'] as String?) ?? '',
      commonPests: (json['common_pests'] as String?) ?? '',
      image: json['image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// 4. Expert Model
class Expert {
  final int id;
  final String name;
  final String specialization;
  final String qualifications;
  final String phoneNumber;
  final String email;
  final String officeAddress;
  final String availableDays;
  final String availableHours;
  final String consultationFee;
  final String? photo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expert({
    required this.id,
    required this.name,
    required this.specialization,
    required this.qualifications,
    required this.phoneNumber,
    required this.email,
    required this.officeAddress,
    required this.availableDays,
    required this.availableHours,
    required this.consultationFee,
    this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      id: json['id'] as int? ?? 0,
      name: (json['name'] as String?) ?? '',
      specialization: (json['specialization'] as String?) ?? '',
      qualifications: (json['qualifications'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      officeAddress: (json['office_address'] as String?) ?? '',
      availableDays: (json['available_days'] as String?) ?? '',
      availableHours: (json['available_hours'] as String?) ?? '',
      consultationFee: (json['consultation_fee'] as String?) ?? '',
      photo: json['photo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// 5. Service Provider Model
class ServiceProvider {
  final int id;
  final String businessName;
  final String serviceType;
  final String serviceTypeDisplay;
  final String contactPerson;
  final String phoneNumber;
  final String alternatePhone;
  final String email;
  final String address;
  final String description;
  final String priceRange;
  final bool deliveryAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceProvider({
    required this.id,
    required this.businessName,
    required this.serviceType,
    required this.serviceTypeDisplay,
    required this.contactPerson,
    required this.phoneNumber,
    required this.alternatePhone,
    required this.email,
    required this.address,
    required this.description,
    required this.priceRange,
    required this.deliveryAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as int? ?? 0,
      businessName: (json['business_name'] as String?) ?? '',
      serviceType: (json['service_type'] as String?) ?? '',
      serviceTypeDisplay: (json['service_type_display'] as String?) ?? '',
      contactPerson: (json['contact_person'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      alternatePhone: (json['alternate_phone'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      priceRange: (json['price_range'] as String?) ?? '',
      deliveryAvailable: json['delivery_available'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// 6. Contact Model
class Contact {
  final int id;
  final String title;
  final String contactType;
  final String contactTypeDisplay;
  final String phoneNumber;
  final String email;
  final String address;
  final String description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contact({
    required this.id,
    required this.title,
    required this.contactType,
    required this.contactTypeDisplay,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int? ?? 0,
      title: (json['title'] as String?) ?? '',
      contactType: (json['contact_type'] as String?) ?? '',
      contactTypeDisplay: (json['contact_type_display'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// 7. FAQ Model
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
      id: json['id'] as int? ?? 0,
      question: (json['question'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// 8. User Manual Model
class UserManual {
  final int id;
  final String title;
  final String content;
  final String category;
  final String categoryDisplay;
  final int order;
  final String? image;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserManual({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.categoryDisplay,
    required this.order,
    this.image,
    this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserManual.fromJson(Map<String, dynamic> json) {
    return UserManual(
      id: json['id'] as int? ?? 0,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      categoryDisplay: (json['category_display'] as String?) ?? '',
      order: json['order'] as int? ?? 0,
      image: json['image'] as String?,
      videoUrl: json['video_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// 9. Program Model
class Program {
  final int id;
  final String title;
  final String description;
  final String googleFormLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.googleFormLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return Program(
      id: json['id'] as int? ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      googleFormLink: (json['google_form_link'] as String?) ?? '',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

// 9. Market Price Model
class MarketPrice {
  final int id;
  final String category;
  final String categoryDisplay;
  final String name;
  final double price;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketPrice({
    required this.id,
    required this.category,
    required this.categoryDisplay,
    required this.name,
    required this.price,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return MarketPrice(
      id: json['id'] as int? ?? 0,
      category: (json['category'] as String?) ?? '',
      categoryDisplay: (json['category_display'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      price: parsePrice(json['price']),
      unit: (json['unit'] as String?) ?? '',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

// 10. Dynamic Market Prices Response
class DynamicMarketPricesResponse {
  final int count;
  final String? next;
  final String? previous;
  final DynamicMarketPricesData results;

  DynamicMarketPricesResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory DynamicMarketPricesResponse.fromJson(Map<String, dynamic> json) {
    return DynamicMarketPricesResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: DynamicMarketPricesData.fromJson(
        json['results'] as Map<String, dynamic>,
      ),
    );
  }
}

class DynamicMarketPricesData {
  final List<String> columns;
  final List<List<String>> data;

  DynamicMarketPricesData({
    required this.columns,
    required this.data,
  });

  factory DynamicMarketPricesData.fromJson(Map<String, dynamic> json) {
    final columnsList = json['columns'] as List<dynamic>? ?? [];
    final dataList = json['data'] as List<dynamic>? ?? [];

    return DynamicMarketPricesData(
      columns: columnsList.map((e) => e.toString()).toList(),
      data: dataList
          .map((row) => (row as List<dynamic>)
              .map((cell) => cell?.toString() ?? '')
              .toList())
          .toList(),
    );
  }
}

// 11. Soil Test Center
class SoilTest {
  final int id;
  final String title;
  final String description;
  final String municipalityName;
  final String? contactPerson;
  final String phoneNumber;
  final String? email;
  final String address;
  final String? cost;
  final String? duration;
  final String? requirements;
  final DateTime createdAt;
  final DateTime updatedAt;

  SoilTest({
    required this.id,
    required this.title,
    required this.description,
    required this.municipalityName,
    this.contactPerson,
    required this.phoneNumber,
    this.email,
    required this.address,
    this.cost,
    this.duration,
    this.requirements,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SoilTest.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return SoilTest(
      id: json['id'] as int? ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      municipalityName: (json['municipality_name'] as String?) ?? '',
      contactPerson: json['contact_person'] as String?,
      phoneNumber: (json['phone_number'] as String?) ?? '',
      email: json['email'] as String?,
      address: (json['address'] as String?) ?? '',
      cost: json['cost'] as String?,
      duration: json['duration'] as String?,
      requirements: json['requirements'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

