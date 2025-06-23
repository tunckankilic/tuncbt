import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:tuncbt/core/constants/firebase_constants.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockUser normalUser;
  late MockUser adminUser;
  late String teamId;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    normalUser = MockUser(
      uid: 'user1',
      email: 'user1@example.com',
    );
    adminUser = MockUser(
      uid: 'admin1',
      email: 'admin1@example.com',
    );
    teamId = 'team1';

    // Test verilerini oluştur
    await firestore.collection(FirebaseCollections.teams).doc(teamId).set({
      FirebaseFields.teamName: 'Test Team',
      FirebaseFields.memberCount: 2,
      FirebaseFields.createdBy: adminUser.uid,
      FirebaseFields.createdAt: DateTime.now(),
    });

    await firestore
        .collection(FirebaseCollections.users)
        .doc(adminUser.uid)
        .set({
      FirebaseFields.email: adminUser.email,
      FirebaseFields.name: 'Admin User',
      FirebaseFields.teamId: teamId,
      FirebaseFields.teamRole: 'admin',
      FirebaseFields.isActive: true,
    });

    await firestore
        .collection(FirebaseCollections.users)
        .doc(normalUser.uid)
        .set({
      FirebaseFields.email: normalUser.email,
      FirebaseFields.name: 'Normal User',
      FirebaseFields.teamId: teamId,
      FirebaseFields.teamRole: 'member',
      FirebaseFields.isActive: true,
    });

    await firestore
        .collection(FirebaseCollections.teams)
        .doc(teamId)
        .collection(FirebaseCollections.teamMembers)
        .doc(adminUser.uid)
        .set({
      FirebaseFields.role: 'admin',
      FirebaseFields.joinedAt: DateTime.now(),
    });

    await firestore
        .collection(FirebaseCollections.teams)
        .doc(teamId)
        .collection(FirebaseCollections.teamMembers)
        .doc(normalUser.uid)
        .set({
      FirebaseFields.role: 'member',
      FirebaseFields.joinedAt: DateTime.now(),
    });
  });

  group('User Collection Rules', () {
    test('authenticated user can read their own data', () async {
      final result = await firestore
          .collection(FirebaseCollections.users)
          .doc(normalUser.uid)
          .get();
      expect(result.exists, isTrue);
    });

    test('authenticated user can read team member data', () async {
      final result = await firestore
          .collection(FirebaseCollections.users)
          .doc(adminUser.uid)
          .get();
      expect(result.exists, isTrue);
    });

    test('user cannot read data from different team', () async {
      final otherUser = MockUser(uid: 'other1', email: 'other1@example.com');
      await firestore
          .collection(FirebaseCollections.users)
          .doc(otherUser.uid)
          .set({
        FirebaseFields.email: otherUser.email,
        FirebaseFields.name: 'Other User',
        FirebaseFields.teamId: 'otherTeam',
        FirebaseFields.teamRole: 'member',
        FirebaseFields.isActive: true,
      });

      expect(
        () async => await firestore
            .collection(FirebaseCollections.users)
            .doc(otherUser.uid)
            .get(),
        throwsA(anything),
      );
    });
  });

  group('Team Collection Rules', () {
    test('team member can read team data', () async {
      final result = await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .get();
      expect(result.exists, isTrue);
    });

    test('admin can update team data', () async {
      await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .update({FirebaseFields.teamName: 'Updated Team Name'});

      final result = await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .get();
      expect(
          result.data()?[FirebaseFields.teamName], equals('Updated Team Name'));
    });

    test('normal member cannot update team data', () {
      expect(
        () async => await firestore
            .collection(FirebaseCollections.teams)
            .doc(teamId)
            .update({FirebaseFields.teamName: 'Should Not Update'}),
        throwsA(anything),
      );
    });
  });

  group('Task Collection Rules', () {
    late String taskId;

    setUp(() async {
      taskId = 'task1';
      await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .set({
        FirebaseFields.title: 'Test Task',
        FirebaseFields.description: 'Test Description',
        FirebaseFields.assignedTo: normalUser.uid,
        FirebaseFields.status: 'pending',
        FirebaseFields.createdAt: DateTime.now(),
      });
    });

    test('team member can read tasks', () async {
      final result = await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .get();
      expect(result.exists, isTrue);
    });

    test('assigned user can update task status', () async {
      await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .update({FirebaseFields.status: 'completed'});

      final result = await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .get();
      expect(result.data()?[FirebaseFields.status], equals('completed'));
    });

    test('non-assigned user cannot update task', () {
      final otherUser = MockUser(uid: 'other2', email: 'other2@example.com');
      expect(
        () async => await firestore
            .collection(FirebaseCollections.teams)
            .doc(teamId)
            .collection(FirebaseCollections.tasks)
            .doc(taskId)
            .update({FirebaseFields.status: 'should not update'}),
        throwsA(anything),
      );
    });
  });

  group('Comment Collection Rules', () {
    late String taskId;
    late String commentId;

    setUp(() async {
      taskId = 'task1';
      commentId = 'comment1';
      await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .collection(FirebaseCollections.comments)
          .doc(commentId)
          .set({
        FirebaseFields.content: 'Test Comment',
        FirebaseFields.userId: normalUser.uid,
        FirebaseFields.createdAt: DateTime.now(),
      });
    });

    test('team member can read comments', () async {
      final result = await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .collection(FirebaseCollections.comments)
          .doc(commentId)
          .get();
      expect(result.exists, isTrue);
    });

    test('comment owner can update their comment', () async {
      await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .collection(FirebaseCollections.comments)
          .doc(commentId)
          .update({FirebaseFields.content: 'Updated Comment'});

      final result = await firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .collection(FirebaseCollections.tasks)
          .doc(taskId)
          .collection(FirebaseCollections.comments)
          .doc(commentId)
          .get();
      expect(result.data()?[FirebaseFields.content], equals('Updated Comment'));
    });

    test('other users cannot update comment', () {
      final otherUser = MockUser(uid: 'other3', email: 'other3@example.com');
      expect(
        () async => await firestore
            .collection(FirebaseCollections.teams)
            .doc(teamId)
            .collection(FirebaseCollections.tasks)
            .doc(taskId)
            .collection(FirebaseCollections.comments)
            .doc(commentId)
            .update({FirebaseFields.content: 'should not update'}),
        throwsA(anything),
      );
    });
  });
}
