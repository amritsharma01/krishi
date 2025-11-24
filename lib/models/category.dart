class Category {
  final int id;
  final String name;
  final String? nameEn;
  final String? nameNe;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameNe,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['created_at'];
    return Category(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
      nameNe: json['name_ne'] as String?,
      createdAt: createdAtValue != null
          ? DateTime.parse(createdAtValue as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'name_ne': nameNe,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String localizedName(bool isNepali) {
    if (isNepali && nameNe != null && nameNe!.trim().isNotEmpty) {
      return nameNe!;
    }
    if (!isNepali && nameEn != null && nameEn!.trim().isNotEmpty) {
      return nameEn!;
    }
    if (!isNepali && name.trim().isNotEmpty) {
      return name;
    }
    // Fallback to whichever value is available
    return nameEn?.isNotEmpty == true
        ? nameEn!
        : (nameNe?.isNotEmpty == true ? nameNe! : name);
  }
}

