class IdCardVerificationModel {
  final bool verified;
  final String message;
  final VerificationDetails? details;

  IdCardVerificationModel({
    required this.verified,
    required this.message,
    this.details,
  });

  factory IdCardVerificationModel.fromJson(Map<String, dynamic> json) {
    return IdCardVerificationModel(
      verified: json['verified'] ?? false,
      message: json['message'] ?? '',
      details: json['details'] != null
          ? VerificationDetails.fromJson(json['details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verified': verified,
      'message': message,
      'details': details?.toJson(),
    };
  }
}

class VerificationDetails {
  final ExtractedCnicDetails? extractedCnicDetails;
  final MatchDetails? matchDetails;
  final BusinessOwnerInfo? businessOwnerInfo;

  VerificationDetails({
    this.extractedCnicDetails,
    this.matchDetails,
    this.businessOwnerInfo,
  });

  factory VerificationDetails.fromJson(Map<String, dynamic> json) {
    return VerificationDetails(
      extractedCnicDetails: json['extracted_cnic_details'] != null
          ? ExtractedCnicDetails.fromJson(json['extracted_cnic_details'])
          : null,
      matchDetails: json['match_details'] != null
          ? MatchDetails.fromJson(json['match_details'])
          : null,
      businessOwnerInfo: json['business_owner_info'] != null
          ? BusinessOwnerInfo.fromJson(json['business_owner_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extracted_cnic_details': extractedCnicDetails?.toJson(),
      'match_details': matchDetails?.toJson(),
      'business_owner_info': businessOwnerInfo?.toJson(),
    };
  }
}

class ExtractedCnicDetails {
  final String name;
  final String cnicNumber;
  final String dateOfBirth;
  final String gender;
  final String? otherInfo;

  ExtractedCnicDetails({
    required this.name,
    required this.cnicNumber,
    required this.dateOfBirth,
    required this.gender,
    this.otherInfo,
  });

  factory ExtractedCnicDetails.fromJson(Map<String, dynamic> json) {
    return ExtractedCnicDetails(
      name: json['name'] ?? '',
      cnicNumber: json['cnic_number'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      otherInfo: json['other_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cnic_number': cnicNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'other_info': otherInfo,
    };
  }
}

class MatchDetails {
  final bool nameMatch;
  final bool dobMatch;
  final bool genderMatch;
  final bool overallMatch;

  MatchDetails({
    required this.nameMatch,
    required this.dobMatch,
    required this.genderMatch,
    required this.overallMatch,
  });

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    return MatchDetails(
      nameMatch: json['name_match'] ?? false,
      dobMatch: json['dob_match'] ?? false,
      genderMatch: json['gender_match'] ?? false,
      overallMatch: json['overall_match'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_match': nameMatch,
      'dob_match': dobMatch,
      'gender_match': genderMatch,
      'overall_match': overallMatch,
    };
  }
}

class BusinessOwnerInfo {
  final String name;
  final String dateOfBirth;
  final String gender;
  final String phone;

  BusinessOwnerInfo({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
  });

  factory BusinessOwnerInfo.fromJson(Map<String, dynamic> json) {
    return BusinessOwnerInfo(
      name: json['name'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'phone': phone,
    };
  }
}

