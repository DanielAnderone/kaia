class AdminProfile {
  final String name;
  final String phoneNumber;
  final String dateOfBirth;
  final String profileImage;

  AdminProfile({
    required this.name,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.profileImage,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      profileImage: json['profile_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone_number': phoneNumber,
    'date_of_birth': dateOfBirth,
    'profile_image': profileImage,
  };
}
