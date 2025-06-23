/// Firebase koleksiyon adları
class FirebaseCollections {
  static const String users = 'users';
  static const String teams = 'teams';
  static const String teamMembers = 'teamMembers';
  static const String tasks = 'tasks';
  static const String comments = 'comments';
  static const String referrals = 'referrals';
  static const String notifications = 'notifications';
}

/// Firebase alan adları
class FirebaseFields {
  // Genel alanlar
  static const String id = 'id';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String isActive = 'isActive';

  // Kullanıcı alanları
  static const String email = 'email';
  static const String name = 'name';
  static const String photoUrl = 'photoUrl';
  static const String teamId = 'teamId';
  static const String teamRole = 'teamRole';
  static const String phoneNumber = 'phoneNumber';
  static const String position = 'position';
  static const String fcmToken = 'fcmToken';

  // Takım alanları
  static const String teamName = 'teamName';
  static const String memberCount = 'memberCount';
  static const String createdBy = 'createdBy';
  static const String referralCode = 'referralCode';

  // Üyelik alanları
  static const String userId = 'userId';
  static const String role = 'role';
  static const String joinedAt = 'joinedAt';
  static const String invitedBy = 'invitedBy';

  // Görev alanları
  static const String title = 'title';
  static const String description = 'description';
  static const String deadline = 'deadline';
  static const String status = 'status';
  static const String assignedTo = 'assignedTo';
  static const String category = 'category';

  // Yorum alanları
  static const String taskId = 'taskId';
  static const String content = 'content';
  static const String attachments = 'attachments';

  // Referans kodu alanları
  static const String code = 'code';
  static const String expiresAt = 'expiresAt';
  static const String usedBy = 'usedBy';
  static const String usedAt = 'usedAt';
}

/// Firebase hata kodları
class FirebaseErrorCodes {
  static String getErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Bu işlem için yetkiniz bulunmamaktadır.';
      case 'not-found':
        return 'İstenen kaynak bulunamadı.';
      case 'already-exists':
        return 'Bu kayıt zaten mevcut.';
      case 'invalid-argument':
        return 'Geçersiz parametre.';
      case 'resource-exhausted':
        return 'Kaynak sınırına ulaşıldı.';
      case 'failed-precondition':
        return 'İşlem ön koşulları sağlanmadı.';
      case 'aborted':
        return 'İşlem iptal edildi.';
      case 'out-of-range':
        return 'Değer aralık dışında.';
      case 'unimplemented':
        return 'Bu özellik henüz uygulanmadı.';
      case 'internal':
        return 'Dahili bir hata oluştu.';
      case 'unavailable':
        return 'Servis şu anda kullanılamıyor.';
      case 'data-loss':
        return 'Kurtarılamaz veri kaybı.';
      case 'unauthenticated':
        return 'Kimlik doğrulama gerekli.';
      default:
        return 'Beklenmeyen bir hata oluştu.';
    }
  }
}
