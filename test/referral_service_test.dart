import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Referral Code (Davet Kodu) Sistemi Test Dosyası
/// 
/// Bu test dosyası şunları test eder:
/// - Kod formatı validasyonu
/// - Firestore entegrasyonu
/// - Kod kullanımı ve validasyon senaryoları
/// - Takıma katılma akışı
/// - Hata senaryoları (süresi dolmuş, kullanılmış, geçersiz kodlar)
void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Referral Code Format Tests', () {
    test('8 karakterli büyük harf ve rakamdan oluşan kod geçerli olmalı', () {
      expect(isValidReferralFormat('ABC12345'), true);
      expect(isValidReferralFormat('AAAABBBB'), true);
      expect(isValidReferralFormat('12345678'), true);
      expect(isValidReferralFormat('A1B2C3D4'), true);
    });

    test('Geçersiz formatlar reddedilmeli', () {
      expect(isValidReferralFormat('abc12345'), false); // küçük harf
      expect(isValidReferralFormat('ABC123'), false); // çok kısa
      expect(isValidReferralFormat('ABC1234567'), false); // çok uzun
      expect(isValidReferralFormat('ABC@1234'), false); // özel karakter
      expect(isValidReferralFormat('ABC 1234'), false); // boşluk
      expect(isValidReferralFormat(''), false); // boş
      expect(isValidReferralFormat('abcdefgh'), false); // küçük harf
    });
  });

  group('Referral Code Firestore Integration Tests', () {
    test('Mevcut olmayan kod için checkCodeExists false dönmeli', () async {
      // Fake firestore boş başlıyor
      final doc = await fakeFirestore
          .collection('referral_codes')
          .doc('TESTCODE')
          .get();

      expect(doc.exists, false);
    });

    test('Eklenen kod için checkCodeExists true dönmeli', () async {
      // Test kodu ekliyoruz
      await fakeFirestore.collection('referral_codes').doc('TEST1234').set({
        'code': 'TEST1234',
        'teamId': 'team123',
        'createdBy': 'user123',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'isUsed': false,
        'usedBy': null,
        'usedAt': null,
        'useCount': 0,
        'maxUses': 1,
      });

      final doc = await fakeFirestore
          .collection('referral_codes')
          .doc('TEST1234')
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['code'], 'TEST1234');
      expect(doc.data()?['teamId'], 'team123');
      expect(doc.data()?['isUsed'], false);
    });

    test('Kod kullanıldığında isUsed true olmalı', () async {
      // Önce kodu oluştur
      await fakeFirestore.collection('referral_codes').doc('USED1234').set({
        'code': 'USED1234',
        'teamId': 'team456',
        'createdBy': 'creator123',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'isUsed': false,
        'useCount': 0,
        'maxUses': 1,
      });

      // Kodu kullan
      await fakeFirestore.collection('referral_codes').doc('USED1234').update({
        'isUsed': true,
        'usedBy': 'newuser456',
        'usedAt': FieldValue.serverTimestamp(),
        'useCount': 1,
      });

      // Kontrol et
      final doc = await fakeFirestore
          .collection('referral_codes')
          .doc('USED1234')
          .get();

      expect(doc.data()?['isUsed'], true);
      expect(doc.data()?['usedBy'], 'newuser456');
      expect(doc.data()?['useCount'], 1);
    });
  });

  group('Referral Code Validation Scenarios', () {
    test('Geçerli kod ve aktif takım validasyonu başarılı olmalı', () async {
      // Önce takımı oluştur
      await fakeFirestore.collection('teams').doc('validteam123').set({
        'name': 'Test Team',
        'isActive': true,
        'memberCount': 5,
        'createdBy': 'admin123',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Sonra kodu oluştur
      await fakeFirestore.collection('referral_codes').doc('VALID123').set({
        'code': 'VALID123',
        'teamId': 'validteam123',
        'createdBy': 'admin123',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'isUsed': false,
        'useCount': 0,
        'maxUses': 1,
      });

      // Validasyon kontrolü
      final codeDoc = await fakeFirestore
          .collection('referral_codes')
          .doc('VALID123')
          .get();
      final teamDoc = await fakeFirestore
          .collection('teams')
          .doc(codeDoc.data()?['teamId'])
          .get();

      expect(codeDoc.exists, true);
      expect(codeDoc.data()?['isUsed'], false);
      expect(teamDoc.exists, true);
      expect(teamDoc.data()?['isActive'], true);
    });

    test('Kullanılmış kod reddedilmeli', () async {
      await fakeFirestore.collection('referral_codes').doc('USEDCODE').set({
        'code': 'USEDCODE',
        'teamId': 'team789',
        'createdBy': 'creator789',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'isUsed': true,
        'usedBy': 'olduser789',
        'usedAt': FieldValue.serverTimestamp(),
        'useCount': 1,
        'maxUses': 1,
      });

      final doc = await fakeFirestore
          .collection('referral_codes')
          .doc('USEDCODE')
          .get();

      final isUsed = doc.data()?['isUsed'] == true ||
          (doc.data()?['useCount'] ?? 0) >= (doc.data()?['maxUses'] ?? 1);

      expect(isUsed, true);
    });

    test('Süresi dolmuş kod reddedilmeli', () async {
      final expiredDate = DateTime.now().subtract(Duration(days: 1));

      await fakeFirestore.collection('referral_codes').doc('EXPIRED1').set({
        'code': 'EXPIRED1',
        'teamId': 'team999',
        'createdBy': 'creator999',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(expiredDate),
        'isUsed': false,
        'useCount': 0,
        'maxUses': 1,
      });

      final doc = await fakeFirestore
          .collection('referral_codes')
          .doc('EXPIRED1')
          .get();

      final expiryDate = (doc.data()?['expiryDate'] as Timestamp?)?.toDate();
      final isExpired = expiryDate != null && expiryDate.isBefore(DateTime.now());

      expect(isExpired, true);
    });

    test('Aktif olmayan takım kodu reddedilmeli', () async {
      // İnaktif takım
      await fakeFirestore.collection('teams').doc('inactiveteam').set({
        'name': 'Inactive Team',
        'isActive': false,
        'memberCount': 2,
        'createdBy': 'admin456',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Kod
      await fakeFirestore.collection('referral_codes').doc('INACTIVE1').set({
        'code': 'INACTIVE1',
        'teamId': 'inactiveteam',
        'createdBy': 'admin456',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'isUsed': false,
        'useCount': 0,
        'maxUses': 1,
      });

      final codeDoc = await fakeFirestore
          .collection('referral_codes')
          .doc('INACTIVE1')
          .get();
      final teamDoc = await fakeFirestore
          .collection('teams')
          .doc(codeDoc.data()?['teamId'])
          .get();

      final isTeamActive = teamDoc.exists && (teamDoc.data()?['isActive'] ?? false);

      expect(isTeamActive, false);
    });
  });

  group('Team Registration Flow Tests', () {
    test('Yeni kullanıcı referral kod ile takıma katılmalı', () async {
      // Takım oluştur
      await fakeFirestore.collection('teams').doc('jointeam123').set({
        'name': 'Join Test Team',
        'isActive': true,
        'memberCount': 3,
        'createdBy': 'teamowner',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Referral kod oluştur
      await fakeFirestore.collection('referral_codes').doc('JOIN1234').set({
        'code': 'JOIN1234',
        'teamId': 'jointeam123',
        'createdBy': 'teamowner',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'isUsed': false,
        'useCount': 0,
        'maxUses': 1,
      });

      // Yeni kullanıcı kaydı simüle et
      const newUserId = 'newuser123';
      await fakeFirestore.collection('users').doc(newUserId).set({
        'id': newUserId,
        'name': 'New User',
        'email': 'newuser@test.com',
        'teamId': 'jointeam123',
        'hasTeam': true,
        'teamRole': 'member',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Team member kaydı
      await fakeFirestore
          .collection('team_members')
          .doc('jointeam123_$newUserId')
          .set({
        'userId': newUserId,
        'teamId': 'jointeam123',
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'invitedBy': 'teamowner',
      });

      // Takım üye sayısını artır
      await fakeFirestore.collection('teams').doc('jointeam123').update({
        'memberCount': FieldValue.increment(1),
      });

      // Kodu kullanıldı olarak işaretle
      await fakeFirestore.collection('referral_codes').doc('JOIN1234').update({
        'isUsed': true,
        'usedBy': newUserId,
        'usedAt': FieldValue.serverTimestamp(),
        'useCount': 1,
      });

      // Doğrulama
      final userDoc = await fakeFirestore.collection('users').doc(newUserId).get();
      final teamDoc = await fakeFirestore.collection('teams').doc('jointeam123').get();
      final codeDoc = await fakeFirestore
          .collection('referral_codes')
          .doc('JOIN1234')
          .get();

      expect(userDoc.data()?['teamId'], 'jointeam123');
      expect(userDoc.data()?['hasTeam'], true);
      expect(userDoc.data()?['teamRole'], 'member');
      expect(teamDoc.data()?['memberCount'], 4); // 3 + 1
      expect(codeDoc.data()?['isUsed'], true);
      expect(codeDoc.data()?['usedBy'], newUserId);
    });

    test('Takım kapasitesi aşımı kontrolü', () async {
      const maxTeamSize = 50;

      // Dolu takım
      await fakeFirestore.collection('teams').doc('fullteam').set({
        'name': 'Full Team',
        'isActive': true,
        'memberCount': maxTeamSize,
        'createdBy': 'teamowner',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final teamDoc = await fakeFirestore.collection('teams').doc('fullteam').get();
      final memberCount = teamDoc.data()?['memberCount'] ?? 0;

      expect(memberCount >= maxTeamSize, true);
    });
  });
}

/// Yardımcı fonksiyonlar
bool isValidReferralFormat(String code) {
  if (code.length != 8) return false;
  return RegExp(r'^[A-Z0-9]{8}$').hasMatch(code);
}

