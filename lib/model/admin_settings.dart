class AdminSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final String theme;
  final bool twoFactorEnabled;

  AdminSettings({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.theme,
    required this.twoFactorEnabled,
  });

  AdminSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    String? theme,
    bool? twoFactorEnabled,
  }) {
    return AdminSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      theme: theme ?? this.theme,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }

  factory AdminSettings.fromJson(Map<String, dynamic> json) {
    return AdminSettings(
      pushNotifications: json['pushNotifications'] ?? false,
      emailNotifications: json['emailNotifications'] ?? false,
      theme: json['theme'] ?? 'light',
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'theme': theme,
      'twoFactorEnabled': twoFactorEnabled,
    };
  }
}
