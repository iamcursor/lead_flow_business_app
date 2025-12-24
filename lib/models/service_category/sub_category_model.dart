class SubCategoryModel {
  final String id;
  final String mainCategory;
  final String mainCategoryName;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final String image;
  final bool isActive;
  final int displayOrder;
  final String createdAt;
  final String updatedAt;

  SubCategoryModel({
    required this.id,
    required this.mainCategory,
    required this.mainCategoryName,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.image,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json["id"] ?? "",
      mainCategory: json["main_category"] ?? "",
      mainCategoryName: json["main_category_name"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      description: json["description"] ?? "",
      icon: json["icon"] ?? "",
      image: json["image"] ?? "",
      isActive: json["is_active"] ?? false,
      displayOrder: json["display_order"] ?? 0,
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "main_category": mainCategory,
      "main_category_name": mainCategoryName,
      "name": name,
      "slug": slug,
      "description": description,
      "icon": icon,
      "image": image,
      "is_active": isActive,
      "display_order": displayOrder,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

