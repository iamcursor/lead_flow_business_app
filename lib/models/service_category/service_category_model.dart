class ServiceCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final String image;
  final bool isActive;
  final int displayOrder;
  final int subCategoriesCount;
  final String createdAt;
  final String updatedAt;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.image,
    required this.isActive,
    required this.displayOrder,
    required this.subCategoriesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      description: json["description"] ?? "",
      icon: json["icon"] ?? "",
      image: json["image"] ?? "",
      isActive: json["is_active"] ?? false,
      displayOrder: json["display_order"] ?? 0,
      subCategoriesCount: json["sub_categories_count"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "slug": slug,
      "description": description,
      "icon": icon,
      "image": image,
      "is_active": isActive,
      "display_order": displayOrder,
      "sub_categories_count": subCategoriesCount,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

