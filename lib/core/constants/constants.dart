import 'package:flutter/material.dart';

class Constants {
  // Takım sistemi sabitleri
  static const int maxTeamSize = 50;
  static const int referralCodeLength = 8;

  static const List<String> teamRoles = [
    'Admin',
    'Member',
  ];

  // Takım hata mesajları
  static const String teamNameRequired = 'Takım adı boş olamaz';
  static const String teamNameTooShort = 'Takım adı en az 3 karakter olmalıdır';
  static const String teamNameTooLong =
      'Takım adı en fazla 50 karakter olabilir';
  static const String teamNotFound = 'Takım bulunamadı';
  static const String teamFull = 'Takım maksimum kapasiteye ulaştı';
  static const String invalidReferralCode = 'Geçersiz referral kodu';
  static const String userAlreadyInTeam = 'Kullanıcı zaten bir takıma üye';
  static const String userNotFound = 'Kullanıcı bulunamadı';

  static List<String> taskCategoryList = [
    'Business',
    'Programming',
    'Information Technology',
    'Human resources',
    'Marketing',
    'Design',
    'Accounting',
  ];

  static List<String> jobsList = [
    'Manager',
    'Team Leader',
    'Designer',
    'Web designer',
    'Full stack developer',
    'Mobile developer',
    'Marketing',
    'Digital marketing',
  ];

  // Renkler
  static Color darkBlue = const Color(0xFF00325A);
  static const Color primaryColor = Color(0xFF3A506B);
  static const Color secondaryColor = Color(0xFF5BC0BE);
  static const Color accentColor = Color(0xFFFCA311);
  static const Color backgroundColor = Color(0xFFF0F5F9);
  static const Color textColor = Color(0xFF1C2541);
  static const Color lightTextColor = Color(0xFFC5C3C6);
  static const Color successColor = Color(0xFF6FFFE9);
  static const Color warningColor = Color(0xFFFF9F1C);
  static const Color errorColor = Color(0xFFE71D36);
  static const Color teamAdminColor = Color(0xFF4A90E2);
  static const Color teamMemberColor = Color(0xFF7ED321);
}
