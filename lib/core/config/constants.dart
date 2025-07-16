import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  // Firestore koleksiyon isimleri
  static const String teamsCollection = 'teams';
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

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

  // Modern Light Theme Colors - Material Design 3 Inspired
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color onPrimaryColor = Color(0xFFFFFFFF);
  static const Color primaryContainerColor = Color(0xFFEADDFF);
  static const Color onPrimaryContainerColor = Color(0xFF21005D);

  static const Color secondaryColor = Color(0xFF625B71);
  static const Color onSecondaryColor = Color(0xFFFFFFFF);
  static const Color secondaryContainerColor = Color(0xFFE8DEF8);
  static const Color onSecondaryContainerColor = Color(0xFF1D192B);

  static const Color tertiaryColor = Color(0xFF7D5260);
  static const Color onTertiaryColor = Color(0xFFFFFFFF);
  static const Color tertiaryContainerColor = Color(0xFFFFD8E4);
  static const Color onTertiaryContainerColor = Color(0xFF31111D);

  static const Color surfaceColor = Color(0xFFFEF7FF);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color surfaceVariantColor = Color(0xFFE7E0EC);
  static const Color onSurfaceVariantColor = Color(0xFF49454F);

  static const Color backgroundColor = Color(0xFFFEF7FF);
  static const Color onBackgroundColor = Color(0xFF1C1B1F);

  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onErrorColor = Color(0xFFFFFFFF);
  static const Color errorContainerColor = Color(0xFFFFDAD6);
  static const Color onErrorContainerColor = Color(0xFF410002);

  static const Color outlineColor = Color(0xFF79747E);
  static const Color outlineVariantColor = Color(0xFFCAC4D0);
  static const Color shadowColor = Color(0xFF000000);
  static const Color scrimColor = Color(0xFF000000);
  static const Color inverseSurfaceColor = Color(0xFF313033);
  static const Color inverseOnSurfaceColor = Color(0xFFF4EFF4);
  static const Color inversePrimaryColor = Color(0xFFD0BCFF);

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFFD0BCFF);
  static const Color darkOnPrimaryColor = Color(0xFF381E72);
  static const Color darkPrimaryContainerColor = Color(0xFF4F378B);
  static const Color darkOnPrimaryContainerColor = Color(0xFFEADDFF);

  static const Color darkSecondaryColor = Color(0xFFCCC2DC);
  static const Color darkOnSecondaryColor = Color(0xFF332D41);
  static const Color darkSecondaryContainerColor = Color(0xFF4A4458);
  static const Color darkOnSecondaryContainerColor = Color(0xFFE8DEF8);

  static const Color darkTertiaryColor = Color(0xFFEFB8C8);
  static const Color darkOnTertiaryColor = Color(0xFF492532);
  static const Color darkTertiaryContainerColor = Color(0xFF633B48);
  static const Color darkOnTertiaryContainerColor = Color(0xFFFFD8E4);

  static const Color darkSurfaceColor = Color(0xFF1C1B1F);
  static const Color darkOnSurfaceColor = Color(0xFFE6E1E5);
  static const Color darkSurfaceVariantColor = Color(0xFF49454F);
  static const Color darkOnSurfaceVariantColor = Color(0xFFCAC4D0);

  static const Color darkBackgroundColor = Color(0xFF1C1B1F);
  static const Color darkOnBackgroundColor = Color(0xFFE6E1E5);

  static const Color darkErrorColor = Color(0xFFFFB4AB);
  static const Color darkOnErrorColor = Color(0xFF690005);
  static const Color darkErrorContainerColor = Color(0xFF93000A);
  static const Color darkOnErrorContainerColor = Color(0xFFFFDAD6);

  static const Color darkOutlineColor = Color(0xFF938F99);
  static const Color darkOutlineVariantColor = Color(0xFF49454F);
  static const Color darkShadowColor = Color(0xFF000000);
  static const Color darkScrimColor = Color(0xFF000000);
  static const Color darkInverseSurfaceColor = Color(0xFFE6E1E5);
  static const Color darkInverseOnSurfaceColor = Color(0xFF313033);
  static const Color darkInversePrimaryColor = Color(0xFF6750A4);

  // Legacy colors for backward compatibility
  static Color darkBlue = const Color(0xFF00325A);
  static const Color accentColor = Color(0xFF6750A4);
  static const Color textColor = Color(0xFF1C1B1F);
  static const Color lightTextColor = Color(0xFF79747E);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color teamAdminColor = Color(0xFF6750A4);
  static const Color teamMemberColor = Color(0xFF4CAF50);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6750A4),
    Color(0xFF8E71C7),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF625B71),
    Color(0xFF7D7193),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFFEF7FF),
    Color(0xFFF4EFF4),
  ];

  static const List<Color> darkPrimaryGradient = [
    Color(0xFFD0BCFF),
    Color(0xFFB794F6),
  ];

  static const List<Color> darkSecondaryGradient = [
    Color(0xFFCCC2DC),
    Color(0xFFB8AED8),
  ];

  static const List<Color> darkBackgroundGradient = [
    Color(0xFF1C1B1F),
    Color(0xFF2D2C30),
  ];
}

class AppTheme {
  // Light Theme Colors
  static Color primaryColor = Constants.primaryColor;
  static Color onPrimaryColor = Constants.onPrimaryColor;
  static Color primaryContainerColor = Constants.primaryContainerColor;
  static Color onPrimaryContainerColor = Constants.onPrimaryContainerColor;

  static Color secondaryColor = Constants.secondaryColor;
  static Color onSecondaryColor = Constants.onSecondaryColor;
  static Color secondaryContainerColor = Constants.secondaryContainerColor;
  static Color onSecondaryContainerColor = Constants.onSecondaryContainerColor;

  static Color tertiaryColor = Constants.tertiaryColor;
  static Color onTertiaryColor = Constants.onTertiaryColor;
  static Color tertiaryContainerColor = Constants.tertiaryContainerColor;
  static Color onTertiaryContainerColor = Constants.onTertiaryContainerColor;

  static Color surfaceColor = Constants.surfaceColor;
  static Color onSurfaceColor = Constants.onSurfaceColor;
  static Color surfaceVariantColor = Constants.surfaceVariantColor;
  static Color onSurfaceVariantColor = Constants.onSurfaceVariantColor;

  static Color backgroundColor = Constants.backgroundColor;
  static Color onBackgroundColor = Constants.onBackgroundColor;

  static Color errorColor = Constants.errorColor;
  static Color onErrorColor = Constants.onErrorColor;
  static Color errorContainerColor = Constants.errorContainerColor;
  static Color onErrorContainerColor = Constants.onErrorContainerColor;

  static Color outlineColor = Constants.outlineColor;
  static Color outlineVariantColor = Constants.outlineVariantColor;
  static Color shadowColor = Constants.shadowColor;
  static Color scrimColor = Constants.scrimColor;
  static Color inverseSurfaceColor = Constants.inverseSurfaceColor;
  static Color inverseOnSurfaceColor = Constants.inverseOnSurfaceColor;
  static Color inversePrimaryColor = Constants.inversePrimaryColor;

  // Legacy properties for backward compatibility
  static Color accentColor = Constants.accentColor;
  static Color textColor = Constants.textColor;
  static Color lightTextColor = Constants.lightTextColor;
  static Color successColor = Constants.successColor;
  static Color warningColor = Constants.warningColor;
  static Color teamAdminColor = Constants.teamAdminColor;
  static Color teamMemberColor = Constants.teamMemberColor;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        primaryContainer: primaryContainerColor,
        onPrimaryContainer: onPrimaryContainerColor,
        secondary: secondaryColor,
        onSecondary: onSecondaryColor,
        secondaryContainer: secondaryContainerColor,
        onSecondaryContainer: onSecondaryContainerColor,
        tertiary: tertiaryColor,
        onTertiary: onTertiaryColor,
        tertiaryContainer: tertiaryContainerColor,
        onTertiaryContainer: onTertiaryContainerColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        surfaceVariant: surfaceVariantColor,
        onSurfaceVariant: onSurfaceVariantColor,
        background: backgroundColor,
        onBackground: onBackgroundColor,
        error: errorColor,
        onError: onErrorColor,
        errorContainer: errorContainerColor,
        onErrorContainer: onErrorContainerColor,
        outline: outlineColor,
        outlineVariant: outlineVariantColor,
        shadow: shadowColor,
        scrim: scrimColor,
        inverseSurface: inverseSurfaceColor,
        onInverseSurface: inverseOnSurfaceColor,
        inversePrimary: inversePrimaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: onBackgroundColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: onBackgroundColor,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: onBackgroundColor,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onBackgroundColor,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onBackgroundColor,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onBackgroundColor,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onBackgroundColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onBackgroundColor,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariantColor,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onBackgroundColor,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onBackgroundColor,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariantColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          color: onBackgroundColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: onBackgroundColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: onPrimaryColor,
          backgroundColor: primaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: onPrimaryColor,
          backgroundColor: primaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(color: outlineColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: surfaceColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantColor.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: onSurfaceVariantColor),
        hintStyle: GoogleFonts.poppins(color: onSurfaceVariantColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: onSurfaceVariantColor,
        elevation: 3,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        textColor: onSurfaceColor,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariantColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Constants.darkPrimaryColor,
        onPrimary: Constants.darkOnPrimaryColor,
        primaryContainer: Constants.darkPrimaryContainerColor,
        onPrimaryContainer: Constants.darkOnPrimaryContainerColor,
        secondary: Constants.darkSecondaryColor,
        onSecondary: Constants.darkOnSecondaryColor,
        secondaryContainer: Constants.darkSecondaryContainerColor,
        onSecondaryContainer: Constants.darkOnSecondaryContainerColor,
        tertiary: Constants.darkTertiaryColor,
        onTertiary: Constants.darkOnTertiaryColor,
        tertiaryContainer: Constants.darkTertiaryContainerColor,
        onTertiaryContainer: Constants.darkOnTertiaryContainerColor,
        surface: Constants.darkSurfaceColor,
        onSurface: Constants.darkOnSurfaceColor,
        surfaceVariant: Constants.darkSurfaceVariantColor,
        onSurfaceVariant: Constants.darkOnSurfaceVariantColor,
        background: Constants.darkBackgroundColor,
        onBackground: Constants.darkOnBackgroundColor,
        error: Constants.darkErrorColor,
        onError: Constants.darkOnErrorColor,
        errorContainer: Constants.darkErrorContainerColor,
        onErrorContainer: Constants.darkOnErrorContainerColor,
        outline: Constants.darkOutlineColor,
        outlineVariant: Constants.darkOutlineVariantColor,
        shadow: Constants.darkShadowColor,
        scrim: Constants.darkScrimColor,
        inverseSurface: Constants.darkInverseSurfaceColor,
        onInverseSurface: Constants.darkInverseOnSurfaceColor,
        inversePrimary: Constants.darkInversePrimaryColor,
      ),
      scaffoldBackgroundColor: Constants.darkBackgroundColor,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: Constants.darkOnBackgroundColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: Constants.darkOnBackgroundColor,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: Constants.darkOnBackgroundColor,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Constants.darkOnBackgroundColor,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Constants.darkOnBackgroundColor,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Constants.darkOnBackgroundColor,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Constants.darkOnBackgroundColor,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Constants.darkOnBackgroundColor,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Constants.darkOnBackgroundColor,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Constants.darkOnBackgroundColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Constants.darkOnBackgroundColor,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Constants.darkOnSurfaceVariantColor,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Constants.darkOnBackgroundColor,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Constants.darkOnBackgroundColor,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Constants.darkOnSurfaceVariantColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          color: Constants.darkOnBackgroundColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Constants.darkOnBackgroundColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Constants.darkOnPrimaryColor,
          backgroundColor: Constants.darkPrimaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Constants.darkOnPrimaryColor,
          backgroundColor: Constants.darkPrimaryColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Constants.darkPrimaryColor,
          backgroundColor: Colors.transparent,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(color: Constants.darkOutlineColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: Constants.darkSurfaceColor,
        surfaceTintColor: Constants.darkSurfaceColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Constants.darkSurfaceVariantColor.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Constants.darkOutlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Constants.darkOutlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Constants.darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Constants.darkErrorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Constants.darkErrorColor, width: 2),
        ),
        labelStyle:
            GoogleFonts.poppins(color: Constants.darkOnSurfaceVariantColor),
        hintStyle:
            GoogleFonts.poppins(color: Constants.darkOnSurfaceVariantColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Constants.darkPrimaryColor,
        foregroundColor: Constants.darkOnPrimaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Constants.darkSurfaceColor,
        selectedItemColor: Constants.darkPrimaryColor,
        unselectedItemColor: Constants.darkOnSurfaceVariantColor,
        elevation: 3,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Constants.darkSurfaceColor,
        surfaceTintColor: Constants.darkSurfaceColor,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Constants.darkPrimaryColor,
        textColor: Constants.darkOnSurfaceColor,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Constants.darkOnSurfaceColor,
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Constants.darkOnSurfaceVariantColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
