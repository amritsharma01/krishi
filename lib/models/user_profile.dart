class UserProfile {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      fullName: (json['full_name'] as String?) ?? '',
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      profileImage: json['profile_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class User {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;
  final DateTime? dateJoined;
  final UserProfile? profile;
  final List<dynamic>? sellerProducts;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.isStaff,
    this.dateJoined,
    this.profile,
    this.sellerProducts,
  });

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      final last = lastName ?? '';
      return '$firstName $last'.trim();
    }
    if (profile?.fullName != null && profile!.fullName.isNotEmpty) {
      return profile!.fullName;
    }
    return email;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      email: (json['email'] as String?) ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      isStaff: json['is_staff'] as bool? ?? false,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'] as String)
          : null,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      sellerProducts: json['seller_products'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'date_joined': dateJoined?.toIso8601String(),
      'profile': profile?.toJson(),
      'seller_products': sellerProducts,
    };
  }
}

