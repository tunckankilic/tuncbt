enum TeamRole {
  admin,
  manager,
  member;

  String get name {
    switch (this) {
      case TeamRole.admin:
        return 'admin';
      case TeamRole.manager:
        return 'manager';
      case TeamRole.member:
        return 'member';
    }
  }

  static TeamRole fromString(String value) {
    print('TeamRole.fromString - Input value: $value');
    try {
      final normalizedValue = value.toLowerCase().trim();
      final role = TeamRole.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == normalizedValue,
        orElse: () => TeamRole.member,
      );
      print('TeamRole.fromString - Converted to: $role');
      return role;
    } catch (e) {
      print('TeamRole.fromString - Error: $e, defaulting to member');
      return TeamRole.member;
    }
  }

  @override
  String toString() {
    return name.toLowerCase();
  }
}
