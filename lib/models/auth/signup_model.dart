class SignUpModel {
  final String email;
  final String name;
  final String password;
  final String role;
  final PotentialBusinessProfile? potentialBusinessProfile;

  SignUpModel({
    required this.email,
    required this.name,
    required this.password,
    this.potentialBusinessProfile,
  }) : role = "business_owner";

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      password: json['password'] ?? '',
      potentialBusinessProfile: json['potential_business_profile'] != null
          ? PotentialBusinessProfile.fromJson(json['potential_business_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "name": name,
      "password": password,
      "role": role,
      "potential_business_profile": potentialBusinessProfile?.toJson(),
    };
  }
}

// -------------------------------------------------------------
// NESTED MODEL FOR potential_business_profile
// -------------------------------------------------------------
class PotentialBusinessProfile {
  final String defaultCity;
  final String defaultState;
  final int defaultRadiusMiles;

  PotentialBusinessProfile({
    required this.defaultCity,
    required this.defaultState,
    required this.defaultRadiusMiles,
  });

  factory PotentialBusinessProfile.fromJson(Map<String, dynamic> json) {
    return PotentialBusinessProfile(
      defaultCity: json['default_city'] ?? '',
      defaultState: json['default_state'] ?? '',
      defaultRadiusMiles: json['default_radius_miles'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "default_city": defaultCity,
      "default_state": defaultState,
      "default_radius_miles": defaultRadiusMiles,
    };
  }
}
