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
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    }

    return Notice(
      id: _parseInt(json['id']),
      title: json['title'] as String,
      description: json['description'] as String,
      noticeType: json['notice_type'] as String,
      noticeTypeDisplay: json['notice_type_display'] as String,
      pdfFile: json['pdf_file'] as String?,
      image: json['image'] as String?,
      publishedDate: DateTime.parse(json['published_date'] as String),
      createdBy: _parseInt(json['created_by']),
      createdByEmail: json['created_by_email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      youtubeUrl: json['youtube_url'] as String,
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] as String,
      categoryDisplay: json['category_display'] as String,
      duration: json['duration'] as String,
      viewsCount: json['views_count'] as int,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: json['id'] as int,
      cropName: json['crop_name'] as String,
      cropType: json['crop_type'] as String,
      cropTypeDisplay: json['crop_type_display'] as String,
      plantingSeason: json['planting_season'] as String,
      harvestingSeason: json['harvesting_season'] as String,
      durationDays: json['duration_days'] as int,
      climateRequirement: json['climate_requirement'] as String,
      soilType: json['soil_type'] as String,
      waterRequirement: json['water_requirement'] as String,
      bestPractices: json['best_practices'] as String,
      commonPests: json['common_pests'] as String,
      image: json['image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: json['id'] as int,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      qualifications: json['qualifications'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      officeAddress: json['office_address'] as String,
      availableDays: json['available_days'] as String,
      availableHours: json['available_hours'] as String,
      consultationFee: json['consultation_fee'] as String,
      photo: json['photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      serviceType: json['service_type'] as String,
      serviceTypeDisplay: json['service_type_display'] as String,
      contactPerson: json['contact_person'] as String,
      phoneNumber: json['phone_number'] as String,
      alternatePhone: json['alternate_phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String,
      description: json['description'] as String,
      priceRange: json['price_range'] as String,
      deliveryAvailable: json['delivery_available'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: json['id'] as int,
      title: json['title'] as String,
      contactType: json['contact_type'] as String,
      contactTypeDisplay: json['contact_type_display'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

