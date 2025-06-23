// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'TuncBT';

  @override
  String get language => 'Dil';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get cancel => 'İptal';

  @override
  String get ok => 'Tamam';

  @override
  String get tasks => 'Görevler';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get create => 'Oluştur';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginNoAccount => 'Hesabınız yok mu?';

  @override
  String get loginResetPassword => 'Şifremi Unuttum';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerName => 'Ad Soyad';

  @override
  String get registerEmail => 'E-posta Adresi';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerPhone => 'Telefon Numarası';

  @override
  String get registerPosition => 'Şirketteki Pozisyon';

  @override
  String get registerHasAccount => 'Already have an account?';

  @override
  String get forgotPasswordTitle => 'Şifremi Unuttum';

  @override
  String get forgotPasswordSubtitle =>
      'Şifrenizi sıfırlamak için e-posta adresinizi girin';

  @override
  String get forgotPasswordEmail => 'E-posta Adresi';

  @override
  String get forgotPasswordReset => 'Şifremi Sıfırla';

  @override
  String get forgotPasswordBackToLogin => 'Giriş Ekranına Dön';

  @override
  String get taskTitle => 'Görev Başlığı';

  @override
  String get taskDescription => 'Görev Açıklaması';

  @override
  String get taskDeadline => 'Son Tarih';

  @override
  String get taskCategory => 'Görev Kategorisi';

  @override
  String get uploadTask => 'Görev Yükle';

  @override
  String get addComment => 'Yorum Ekle';

  @override
  String get taskDone => 'Görev Tamamlandı';

  @override
  String get taskNotDone => 'Görev Devam Ediyor';

  @override
  String get deleteTask => 'Görevi Sil';

  @override
  String get deleteTaskConfirm =>
      'Bu görevi silmek istediğinizden emin misiniz?';

  @override
  String get taskDeleted => 'Görev başarıyla silindi';

  @override
  String get taskDeleteError => 'Görev silinirken bir hata oluştu';

  @override
  String get taskUploadSuccess => 'Görev yüklendi ve bildirim oluşturuldu';

  @override
  String get taskUploadError => 'Görev yüklenirken bir hata oluştu';

  @override
  String get noTasks => 'Henüz ekip görevi yok';

  @override
  String get addTaskHint => 'Yeni görev eklemek için + butonuna tıklayın';

  @override
  String get allFieldsRequired => 'Tüm alanlar zorunludur';

  @override
  String get fieldRequired => 'Bu alan zorunludur';

  @override
  String get teamTasks => 'Ekip Görevleri';

  @override
  String get newTask => 'Yeni Görev';

  @override
  String get teamMembers => 'Ekip Üyeleri';

  @override
  String teamMembersCount(int count) {
    return '$count Üye';
  }

  @override
  String get noTeamMembers => 'Henüz ekip üyesi yok';

  @override
  String get inviteMembersHint =>
      'Ekibinize yeni üyeler eklemek için referans kodunuzu paylaşın';

  @override
  String get myAccount => 'Hesabım';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get teamName => 'Ekip Adı';

  @override
  String get referralCode => 'Referans Kodu';

  @override
  String get inviteMembers => 'Üye Davet Et';

  @override
  String get shareReferralCode => 'Referans Kodunu Paylaş';

  @override
  String get teamSettings => 'Ekip Ayarları';

  @override
  String get leaveTeam => 'Ekipten Ayrıl';

  @override
  String get leaveTeamConfirm =>
      'Ekipten ayrılmak istediğinizden emin misiniz?';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountConfirm =>
      'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get jobInformation => 'İş Bilgileri';

  @override
  String get contactInformation => 'İletişim Bilgileri';

  @override
  String get teamInformation => 'Ekip Bilgileri';

  @override
  String get position => 'Pozisyon';

  @override
  String joinedDate(String date) {
    return 'Katılım: $date';
  }

  @override
  String get noName => 'İsim Yok';

  @override
  String get editName => 'İsmi Düzenle';

  @override
  String get enterName => 'İsminizi girin';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get messages => 'Mesajlar';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get contact => 'İletişim';

  @override
  String get commentActions => 'Yorum İşlemleri';

  @override
  String get replyToComment => 'Yorumu Yanıtla';

  @override
  String get close => 'Kapat';

  @override
  String get leave => 'Ayrıl';

  @override
  String get loginRequired => 'Giriş yapmanız gerekiyor';

  @override
  String get userNotFound => 'Kullanıcı bulunamadı';

  @override
  String get referralCodeTitle => 'Referans Kodu Nedir?';

  @override
  String get referralCodeDescription =>
      'Referans kodu, mevcut bir kullanıcıdan aldığınız 8 karakterlik özel bir koddur. Bu kod ile sisteme kayıt olarak ekstra avantajlardan yararlanabilirsiniz.';

  @override
  String get authErrorUserNotFound =>
      'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';

  @override
  String get authErrorWrongPassword => 'Hatalı şifre. Lütfen tekrar deneyin';

  @override
  String get authErrorInvalidEmail => 'Geçersiz e-posta adresi';

  @override
  String get authErrorUserDisabled => 'Bu hesap devre dışı bırakıldı';

  @override
  String get authErrorEmailInUse => 'Bu e-posta adresi zaten kullanımda';

  @override
  String get authErrorOperationNotAllowed =>
      'Bu işleme şu anda izin verilmiyor';

  @override
  String get authErrorWeakPassword =>
      'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin';

  @override
  String get authErrorNetworkFailed =>
      'Ağ bağlantı hatası. Lütfen internet bağlantınızı kontrol edin';

  @override
  String get authErrorTooManyRequests =>
      'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin';

  @override
  String get authErrorInvalidCredential => 'Geçersiz kimlik bilgileri';

  @override
  String get authErrorAccountExists =>
      'Bu e-posta adresiyle farklı bir giriş yöntemi kullanan bir hesap zaten var';

  @override
  String get authErrorInvalidVerificationCode => 'Geçersiz doğrulama kodu';

  @override
  String get authErrorInvalidVerificationId => 'Geçersiz doğrulama ID\'si';

  @override
  String get authErrorQuotaExceeded =>
      'Kota aşıldı. Lütfen daha sonra tekrar deneyin';

  @override
  String get authErrorCredentialInUse =>
      'Bu kimlik bilgileri başka bir hesapla ilişkilendirilmiş';

  @override
  String get authErrorRequiresRecentLogin =>
      'Bu işlem için yakın zamanda giriş yapmanız gerekiyor. Lütfen çıkış yapıp tekrar giriş yapın';

  @override
  String get authErrorGeneric => 'Bir hata oluştu. Lütfen tekrar deneyin';

  @override
  String get notInTeam => 'Henüz bir ekibe üye değilsiniz';

  @override
  String get addMember => 'Üye Ekle';

  @override
  String teamJoinDate(String date) {
    return 'Katılım: $date';
  }

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get noPermissionToDelete => 'Bu işlemi yapmak için yetkiniz yok';
}
