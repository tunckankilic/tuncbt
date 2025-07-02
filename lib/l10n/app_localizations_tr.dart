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
  String get loginTitle => 'Giriş Yap';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginNoAccount => 'Hesabınız yok mu?';

  @override
  String get loginResetPassword => 'Şifremi Unuttum';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get registerName => 'Ad Soyad';

  @override
  String get registerEmail => 'E-posta Adresi';

  @override
  String get registerPassword => 'Şifre';

  @override
  String get registerConfirmPassword => 'Şifre Tekrar';

  @override
  String get registerPhone => 'Telefon Numarası';

  @override
  String get registerPosition => 'Şirketteki Pozisyon';

  @override
  String get registerHasAccount => 'Zaten hesabınız var mı?';

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
  String get referralCodeTitle => 'Referans Kodu Nedir?';

  @override
  String get referralCodeDescription =>
      'Referans kodu, bir takıma katılmak için kullanılan 8 karakterlik özel bir koddur. Eğer bir takıma katılmak istiyorsanız, takım yöneticisinden alacağınız referans kodunu giriniz. Eğer kendi takımınızı oluşturmak istiyorsanız bu alanı boş bırakabilirsiniz.';

  @override
  String get referralCodeOptional =>
      'Referans kodu opsiyoneldir. Eğer kendi takımınızı oluşturmak istiyorsanız boş bırakabilirsiniz.';

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

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get failedToSendMessage =>
      'Mesaj gönderilemedi. Lütfen tekrar deneyin';

  @override
  String get failedToSendFile => 'Dosya gönderilemedi';

  @override
  String get gifSentSuccessfully => 'GIF başarıyla gönderildi';

  @override
  String get failedToSendGIF => 'GIF gönderilemedi';

  @override
  String get maximumRetryExceeded => 'Maksimum yeniden deneme sayısı aşıldı';

  @override
  String get joinTeam => 'Takıma Katıl';

  @override
  String get createTeam => 'Takım Oluştur';

  @override
  String get fieldMissing => 'Bu alan zorunludur';

  @override
  String get invalidPassword => 'Lütfen geçerli bir şifre girin';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get teamAdminInfo =>
      'Kaydolduktan sonra kendi takımınızın yöneticisi olacaksınız';

  @override
  String get creatingTeam => 'Takımınız oluşturuluyor...\nLütfen bekleyin.';

  @override
  String get email => 'E-posta';

  @override
  String get name => 'Ad Soyad';

  @override
  String get phoneNumber => 'Telefon Numarası';

  @override
  String get allWorkers => 'Tüm Çalışanlar';

  @override
  String get teamNotFound => 'Takım bulunamadı';

  @override
  String get permissionDenied => 'Bu işlem için yetkiniz bulunmamaktadır';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfService => 'Kullanım Şartları';

  @override
  String get dataProcessing => 'Veri İşleme';

  @override
  String get ageRestriction => 'Yaş Sınırlaması';

  @override
  String get ageRestrictionText =>
      'Bu uygulamayı kullanmak için en az 13 yaşında olmalısınız';

  @override
  String get legalNotice => 'Yasal Bildirim';

  @override
  String get acceptTerms =>
      'Kullanım Şartları ve Gizlilik Politikasını kabul ediyorum';

  @override
  String get acceptDataProcessing =>
      'Kişisel verilerimin işlenmesine onay veriyorum';

  @override
  String get acceptAgeRestriction => '13 yaşından büyük olduğumu onaylıyorum';

  @override
  String get notificationPermission => 'Bildirim İzni';

  @override
  String get notificationPermissionText =>
      'Ekibinizin aktivitelerinden haberdar olmak için bildirimlere izin verin';

  @override
  String get manageNotifications => 'Bildirimleri Yönet';

  @override
  String get exportData => 'Verilerimi İndir';

  @override
  String get exportDataDescription =>
      'Kişisel verilerinizin bir kopyasını indirin';

  @override
  String get deleteData => 'Verilerimi Sil';

  @override
  String get deleteDataDescription =>
      'Tüm verilerinizi sunucularımızdan kalıcı olarak silin';

  @override
  String get cookiePolicy => 'Çerez Politikası';

  @override
  String get cookiePolicyDescription =>
      'Deneyiminizi iyileştirmek için çerezler kullanıyoruz';

  @override
  String get contactSupport => 'Destek İle İletişime Geç';

  @override
  String lastUpdated(String date) {
    return 'Son güncelleme: $date';
  }

  @override
  String get chats => 'Sohbetler';

  @override
  String get groups => 'Gruplar';

  @override
  String get newChat => 'Yeni Sohbet';

  @override
  String get newGroup => 'Yeni Grup';

  @override
  String get createGroup => 'Grup Oluştur';

  @override
  String get groupName => 'Grup Adı';

  @override
  String get groupDescription => 'Açıklama (İsteğe bağlı)';

  @override
  String get groupMembers => 'Üyeler';

  @override
  String get noMembers => 'Eklenebilecek üye bulunamadı';

  @override
  String get selectMembers => 'En az bir üye seçmelisiniz';

  @override
  String get groupCreated => 'Grup başarıyla oluşturuldu';

  @override
  String get groupCreationError => 'Grup oluşturulurken bir hata oluştu';

  @override
  String get noChats => 'Henüz mesajınız yok';

  @override
  String get noGroups => 'Henüz bir gruba üye değilsiniz';

  @override
  String memberCount(int count) {
    return '$count üye';
  }

  @override
  String get groupChatComingSoon => 'Grup sohbeti özelliği yakında eklenecek';

  @override
  String get deleteChat => 'Sohbeti Sil';

  @override
  String get deleteChatConfirm =>
      'Bu sohbeti silmek istediğinizden emin misiniz?';

  @override
  String get block => 'Engelle';

  @override
  String get unblock => 'Engeli Kaldır';

  @override
  String get onlyAdminsCanMakeAdmin =>
      'Yalnızca grup adminleri yeni admin atayabilir';

  @override
  String get newMembersAdded => 'Yeni üyeler eklendi';

  @override
  String get newAdminAssigned => 'Yeni grup admini atandı';

  @override
  String get groupCreatedMessage => 'Grup oluşturuldu';

  @override
  String get micPermissionTitle => 'Mikrofon İzni';

  @override
  String get micPermissionMessage =>
      'Sesli mesaj göndermek için mikrofon iznine ihtiyacımız var. İzin vermek ister misiniz?';

  @override
  String get notNow => 'ŞİMDİ DEĞİL';

  @override
  String get continueAction => 'DEVAM ET';

  @override
  String get permissionRequired => 'İzin Gerekli';

  @override
  String get micPermissionSettingsMessage =>
      'Sesli mesaj göndermek için mikrofon izni gerekli. Lütfen ayarlardan izin verin.';

  @override
  String get openSettings => 'AYARLARI AÇ';

  @override
  String get recordingError => 'Hata';

  @override
  String get recordingStartError => 'Kayıt başlatılamadı';

  @override
  String get recordingStopError => 'Kayıt durdurulamadı';

  @override
  String get filePickingError => 'Dosya seçilirken bir hata oluştu';

  @override
  String get attachments => 'Ekler';

  @override
  String get photo => 'Fotoğraf';

  @override
  String get video => 'Video';

  @override
  String get messageDeletionError => 'Mesaj silinirken bir hata oluştu';

  @override
  String get userBlocked => 'Kullanıcı engellendi';

  @override
  String get userBlockError => 'Kullanıcı engellenirken bir hata oluştu';

  @override
  String get userUnblocked => 'Kullanıcının engeli kaldırıldı';

  @override
  String get userUnblockError =>
      'Kullanıcının engeli kaldırılırken bir hata oluştu';

  @override
  String get onlyAdminsCanAdd => 'Yalnızca grup yöneticileri üye ekleyebilir';

  @override
  String get memberAdded => 'Yeni üyeler eklendi';

  @override
  String get onlyAdminsCanRemove =>
      'Üyeleri yalnızca grup yöneticileri çıkarabilir';

  @override
  String get memberRemoved => 'Bir üye gruptan çıkarıldı';

  @override
  String get onlyAdminsCanPromote =>
      'Yeni yönetici atamasını yalnızca grup yöneticileri yapabilir';

  @override
  String get adminAssigned => 'Yeni grup yöneticisi atandı';

  @override
  String get systemMessageNewMembers => 'Yeni üyeler eklendi';

  @override
  String get systemMessageMemberRemoved => 'Bir üye çıkarıldı';

  @override
  String get systemMessageNewAdmin => 'Yeni grup yöneticisi atandı';

  @override
  String get systemMessageGroupCreated => 'Grup oluşturuldu';

  @override
  String get teamCreationDate => 'Oluşturulma Tarihi';

  @override
  String get dangerZone => 'Tehlikeli Bölge';

  @override
  String get memberManagement => 'Üye Yönetimi';

  @override
  String teamMemberCount(int count) {
    return '$count üye';
  }

  @override
  String get teamMembersLowercase => 'üye';

  @override
  String get chooseYourJob => 'İş Pozisyonunuzu Seçin';

  @override
  String get noTeamYet => 'Henüz bir takıma ait değilsiniz';

  @override
  String get tasksRequireTeam =>
      'Görevleri görüntülemek için bir takıma katılmanız gerekiyor';

  @override
  String get deleteComment => 'Yorumu Sil';

  @override
  String get deleteCommentConfirm =>
      'Bu yorumu silmek istediğinizden emin misiniz?';

  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(int minutes) {
    return '$minutes dakika önce';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours saat önce';
  }

  @override
  String daysAgo(int days) {
    return '$days gün önce';
  }

  @override
  String get dataCollection => 'Veri Toplama ve Kullanım';

  @override
  String get dataCollectionDesc =>
      'Uygulamamız, size daha iyi hizmet verebilmek için bazı kişisel verilerinizi toplar ve işler. Bu veriler şunları içerir:\n\n• İsim ve e-posta adresi\n• Profil fotoğrafı\n• Telefon numarası\n• Takım ve görev bilgileri\n• Kullanım istatistikleri';

  @override
  String get dataSecurity => 'Veri Güvenliği';

  @override
  String get dataSecurityDesc =>
      'Verileriniz Firebase altyapısı kullanılarak güvenli bir şekilde saklanır ve şifrelenir. Verilerinize sadece yetkili kişiler erişebilir.';

  @override
  String get dataSharing => 'Veri Paylaşımı';

  @override
  String get dataSharingDesc =>
      'Verileriniz üçüncü taraflarla paylaşılmaz. Sadece takım üyeleri arasında gerekli bilgiler paylaşılır.';

  @override
  String get dataDeletion => 'Veri Silme';

  @override
  String get dataDeletionDesc =>
      'Hesabınızı sildiğinizde, tüm kişisel verileriniz ve ilgili içerikler (mesajlar, yorumlar, görevler) kalıcı olarak silinir.';

  @override
  String get cookies => 'Çerezler';

  @override
  String get cookiesDesc =>
      'Uygulamamız, daha iyi bir kullanıcı deneyimi sağlamak için çerezler kullanabilir.';

  @override
  String get contactInfo => 'İletişim';

  @override
  String get contactInfoDesc =>
      'Gizlilik politikamız hakkında sorularınız için support@tuncbt.com adresinden bize ulaşabilirsiniz';

  @override
  String lastUpdatedAt(String date) {
    return 'Son güncelleme: $date';
  }

  @override
  String get termsAgeRestriction => 'Yaş Sınırlaması';

  @override
  String get termsAgeRestrictionDesc =>
      'Bu uygulamayı kullanmak için en az 13 yaşında olmanız gerekmektedir. 13 yaşından küçükseniz, ebeveyn veya yasal vasi gözetiminde kullanmanız gerekir.';

  @override
  String get accountSecurity => 'Hesap Güvenliği';

  @override
  String get accountSecurityDesc =>
      'Hesap güvenliğinizden siz sorumlusunuz. Şifrenizi kimseyle paylaşmayın ve güvenli bir şekilde saklayın.';

  @override
  String get unacceptableBehavior => 'Kabul Edilemez Davranışlar';

  @override
  String get unacceptableBehaviorDesc =>
      '• Yasadışı içerik paylaşımı\n• Spam veya istenmeyen içerik\n• Taciz veya zorbalık\n• Başkalarının kişisel verilerini izinsiz paylaşma\n• Sistemin kötüye kullanımı';

  @override
  String get contentRights => 'İçerik Hakları';

  @override
  String get contentRightsDesc =>
      'Paylaştığınız içeriklerin haklarının size ait olduğunu veya paylaşma hakkına sahip olduğunuzu teyit etmelisiniz.';

  @override
  String get serviceChanges => 'Hizmet Değişiklikleri';

  @override
  String get serviceChangesDesc =>
      'Hizmetlerimizi önceden haber vermeksizin değiştirme, askıya alma veya sonlandırma hakkını saklı tutarız.';

  @override
  String get disclaimer => 'Sorumluluk Reddi';

  @override
  String get disclaimerDesc =>
      'Uygulama \'olduğu gibi\' sunulmaktadır. Kesintisiz veya hatasız çalışacağına dair garanti vermiyoruz.';

  @override
  String get termsContact => 'İletişim';

  @override
  String get termsContactDesc =>
      'Kullanım şartları hakkında sorularınız için support@tuncbt.com adresinden bize ulaşabilirsiniz.';

  @override
  String get sendEmail => 'E-posta Gönder';

  @override
  String get sendWhatsApp => 'WhatsApp\'ta Mesaj Gönder';

  @override
  String get startChat => 'Sohbet Başlat';

  @override
  String get whatsAppError => 'WhatsApp açılamadı';

  @override
  String get emailError => 'E-posta uygulaması açılamadı';

  @override
  String get emailSubject => 'TuncBT - İletişim';

  @override
  String emailBody(String name) {
    return 'Merhaba $name,\n\n';
  }

  @override
  String get profile_image_size_error =>
      'Profil resmi boyutu 5MB\'dan büyük olamaz';

  @override
  String get invalid_image_format =>
      'Geçersiz dosya formatı. Sadece resim dosyaları yüklenebilir';

  @override
  String get profile_image_upload_failed =>
      'Profil resmi yüklenirken bir hata oluştu. Lütfen tekrar deneyin';

  @override
  String get sessionExpired =>
      'Oturumunuz sona erdi. Lütfen tekrar giriş yapın';

  @override
  String get userNotFoundError =>
      'Kullanıcı bilgilerinize ulaşılamadı. Lütfen tekrar giriş yapın';

  @override
  String get unexpectedErrorWithAction =>
      'Beklenmeyen bir hata oluştu. Lütfen sayfayı yenileyip tekrar deneyin';

  @override
  String get errorTitleChat => 'Mesaj Hatası';

  @override
  String get errorTitleAuth => 'Giriş Hatası';

  @override
  String get errorTitleGroup => 'Grup İşlemi Başarısız';

  @override
  String get errorTitleUpload => 'Yükleme Hatası';

  @override
  String get errorTitleNetwork => 'Bağlantı Hatası';

  @override
  String get noPermissionToSendMessage => 'Bu mesajı gönderme yetkiniz yok';

  @override
  String get chatRoomNotFound => 'Sohbet odası bulunamadı';

  @override
  String get networkError => 'İnternet bağlantınızı kontrol edin';

  @override
  String get failedToRemoveMember => 'Üye gruptan çıkarılamadı';

  @override
  String get failedToPromoteAdmin => 'Yönetici ataması yapılamadı';
}
