class BusinessProfileModel {
  final String gender;
  final String dateOfBirth;
  final String alternatePhone;
  final String businessName;
  final String tagline;
  final String description;
  final int yearsOfExperience;
  final String primaryServiceCategory;
  final String serviceCategories;
  final String servicesOffered;
  final String addressLine;
  final String city;
  final String state;
  final String postalCode;
  final String latitude;
  final String longitude;
  final String website;
  final String businessHours;
  final int maxLeadDistanceMiles;
  final bool autoRespondEnabled;
  final String autoRespondMessage;
  final String subscriptionTier;
  final String availabilityStatus;
  final String logo;
  final String gallery;
  final String idProofType;
  final String idProofFile;
  final String recentPhoto;
  final String baseServiceRate;

  BusinessProfileModel({
    required this.gender,
    required this.dateOfBirth,
    required this.alternatePhone,
    required this.businessName,
    required this.tagline,
    required this.description,
    required this.yearsOfExperience,
    required this.primaryServiceCategory,
    required this.serviceCategories,
    required this.servicesOffered,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.website,
    required this.businessHours,
    required this.maxLeadDistanceMiles,
    required this.autoRespondEnabled,
    required this.autoRespondMessage,
    required this.subscriptionTier,
    required this.availabilityStatus,
    required this.logo,
    required this.gallery,
    required this.idProofType,
    required this.idProofFile,
    required this.recentPhoto,
    required this.baseServiceRate,
  });

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      gender: json["gender"] ?? "",
      dateOfBirth: json["date_of_birth"] ?? "",
      alternatePhone: json["alternate_phone"] ?? "",
      businessName: json["business_name"] ?? "",
      tagline: json["tagline"] ?? "",
      description: json["description"] ?? "",
      yearsOfExperience: json["years_of_experience"] ?? 0,
      primaryServiceCategory: json["primary_service_category"] ?? "",
      serviceCategories: json["service_categories"] ?? "",
      servicesOffered: json["services_offered"] ?? "",
      addressLine: json["address_line"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      postalCode: json["postal_code"] ?? "",
      latitude: json["latitude"] ?? "",
      longitude: json["longitude"] ?? "",
      website: json["website"] ?? "",
      businessHours: json["business_hours"] ?? "",
      maxLeadDistanceMiles: json["max_lead_distance_miles"] ?? 0,
      autoRespondEnabled: json["auto_respond_enabled"] ?? false,
      autoRespondMessage: json["auto_respond_message"] ?? "",
      subscriptionTier: json["subscription_tier"] ?? "",
      availabilityStatus: json["availability_status"] ?? "",
      logo: json["logo"] ?? "",
      gallery: json["gallery"] ?? "",
      idProofType: json["id_proof_type"] ?? "",
      idProofFile: json["id_proof_file"] ?? "",
      recentPhoto: json["recent_photo"] ?? "",
      baseServiceRate: json["base_service_rate"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "gender": gender,
      "date_of_birth": dateOfBirth,
      "alternate_phone": alternatePhone,
      "business_name": businessName,
      "tagline": tagline,
      "description": description,
      "years_of_experience": yearsOfExperience,
      "primary_service_category": primaryServiceCategory,
      "service_categories": serviceCategories,
      "services_offered": servicesOffered,
      "address_line": addressLine,
      "city": city,
      "state": state,
      "postal_code": postalCode,
      "latitude": latitude,
      "longitude": longitude,
      "website": website,
      "business_hours": businessHours,
      "max_lead_distance_miles": maxLeadDistanceMiles,
      "auto_respond_enabled": autoRespondEnabled,
      "auto_respond_message": autoRespondMessage,
      "subscription_tier": subscriptionTier,
      "availability_status": availabilityStatus,
      "logo": logo,
      "gallery": gallery,
      "id_proof_type": idProofType,
      "id_proof_file": idProofFile,
      "recent_photo": recentPhoto,
      "base_service_rate": baseServiceRate,
    };
  }
}
