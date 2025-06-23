/// Firebase koleksiyon yolları
class FirebaseCollections {
  static const String users = 'users';
  static const String teams = 'teams';
  static const String teamMembers = 'team_members';
  static const String tasks = 'tasks';
  static const String comments = 'comments';
  static const String chats = 'chats';
  static const String messages = 'messages';
}

/// Firebase alan adları
class FirebaseFields {
  // Ortak alanlar
  static const String id = 'id';
  static const String createdAt = 'createdAt';
  static const String isActive = 'isActive';

  // Kullanıcı alanları
  static const String name = 'name';
  static const String email = 'email';
  static const String imageUrl = 'imageUrl';
  static const String phoneNumber = 'phoneNumber';
  static const String position = 'position';
  static const String isOnline = 'isOnline';
  static const String teamId = 'teamId';
  static const String teamRole = 'teamRole';
  static const String hasTeam = 'hasTeam';
  static const String invitedBy = 'invitedBy';

  // Takım alanları
  static const String teamName = 'teamName';
  static const String referralCode = 'referralCode';
  static const String createdBy = 'createdBy';
  static const String memberCount = 'memberCount';

  // Takım üyeliği alanları
  static const String userId = 'userId';
  static const String joinedAt = 'joinedAt';
  static const String role = 'role';
}

/// Firebase hata kodları ve mesajları
class FirebaseErrorCodes {
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String invalidEmail = 'invalid-email';
  static const String userDisabled = 'user-disabled';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String weakPassword = 'weak-password';
  static const String networkRequestFailed = 'network-request-failed';
  static const String tooManyRequests = 'too-many-requests';
  static const String invalidCredential = 'invalid-credential';
  static const String requiresRecentLogin = 'requires-recent-login';

  static String getErrorMessage(String code) {
    switch (code) {
      case userNotFound:
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      case wrongPassword:
        return 'Hatalı şifre. Lütfen tekrar deneyin.';
      case invalidEmail:
        return 'Geçersiz e-posta adresi.';
      case userDisabled:
        return 'Bu hesap devre dışı bırakılmış.';
      case emailAlreadyInUse:
        return 'Bu e-posta adresi zaten kullanımda.';
      case operationNotAllowed:
        return 'Bu işlem şu anda izin verilmiyor.';
      case weakPassword:
        return 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      case networkRequestFailed:
        return 'Ağ bağlantı hatası. İnternet bağlantınızı kontrol edin.';
      case tooManyRequests:
        return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
      case invalidCredential:
        return 'Geçersiz kimlik bilgileri.';
      case requiresRecentLogin:
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
