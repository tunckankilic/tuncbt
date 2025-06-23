enum TeamRole {
  admin,
  member;

  String get name {
    switch (this) {
      case TeamRole.admin:
        return 'Admin';
      case TeamRole.member:
        return 'Member';
    }
  }

  static TeamRole fromString(String value) {
    return TeamRole.values.firstWhere(
      (role) => role.toString().split('.').last == value.toLowerCase(),
      orElse: () => TeamRole.member,
    );
  }
}
