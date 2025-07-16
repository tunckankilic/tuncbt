import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/models/team_member.dart';

class FirebaseListenerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream subscriptions map to manage all active listeners
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  // Data streams
  final RxList<Map<String, dynamic>> teamTasks = <Map<String, dynamic>>[].obs;
  final RxList<UserModel> teamMembers = <UserModel>[].obs;
  final RxMap<String, bool> userOnlineStatus = <String, bool>{}.obs;

  // Current team ID being listened to
  String? _currentTeamId;

  @override
  void onClose() {
    // Cancel all active subscriptions to prevent memory leaks
    _cancelAllSubscriptions();
    super.onClose();
  }

  // Setup listeners for a specific team
  Future<void> setupTeamListeners(String teamId) async {
    if (_currentTeamId == teamId) {
      // Already listening to this team
      return;
    }

    print('FirebaseListenerService: Setting up listeners for team: $teamId');

    // Cancel existing listeners
    _cancelAllSubscriptions();
    _currentTeamId = teamId;

    // Setup new listeners
    _setupTasksListener(teamId);
    _setupTeamMembersListener(teamId);
  }

  // Setup tasks listener for a team
  void _setupTasksListener(String teamId) {
    final subscriptionKey = 'tasks_$teamId';

    _activeSubscriptions[subscriptionKey] = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        try {
          final tasks = snapshot.docs.map((doc) {
            final data = doc.data();
            data['taskId'] = doc.id;
            // Add default values for missing fields
            data['teamId'] = data['teamId'] ?? teamId;
            data['taskTitle'] = data['taskTitle'] ?? '';
            data['taskDescription'] = data['taskDescription'] ?? '';
            data['taskCategory'] = data['taskCategory'] ?? 'Genel';
            data['uploadedBy'] = data['uploadedBy'] ?? '';
            data['isDone'] = data['isDone'] ?? false;
            data['createdAt'] = data['createdAt'] ?? Timestamp.now();
            data['taskComments'] = data['taskComments'] ?? [];
            return data;
          }).toList();

          teamTasks.value = tasks;
          print(
              'FirebaseListenerService: Updated ${tasks.length} tasks for team $teamId');
        } catch (e) {
          print('FirebaseListenerService: Error processing tasks snapshot: $e');
        }
      },
      onError: (error) {
        print('FirebaseListenerService: Tasks listener error: $error');
      },
    );
  }

  // Setup team members listener
  void _setupTeamMembersListener(String teamId) {
    final subscriptionKey = 'members_$teamId';

    _activeSubscriptions[subscriptionKey] = _firestore
        .collection('team_members')
        .where('teamId', isEqualTo: teamId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
      (snapshot) async {
        try {
          final List<UserModel> members = [];

          for (var doc in snapshot.docs) {
            final teamMember = TeamMember.fromJson(doc.data());
            final userDoc = await _firestore
                .collection('users')
                .doc(teamMember.userId)
                .get();

            if (userDoc.exists) {
              final userData = UserModel.fromFirestore(userDoc);
              members.add(userData);
            }
          }

          teamMembers.value = members;
          print(
              'FirebaseListenerService: Updated ${members.length} team members');

          // Setup user status listeners for team members
          _setupUserStatusListeners(members);
        } catch (e) {
          print(
              'FirebaseListenerService: Error processing team members snapshot: $e');
        }
      },
      onError: (error) {
        print('FirebaseListenerService: Team members listener error: $error');
      },
    );
  }

  // Setup user status listeners for team members
  void _setupUserStatusListeners(List<UserModel> members) {
    // Cancel existing user status listeners
    _cancelUserStatusListeners();

    for (final member in members) {
      final subscriptionKey = 'user_status_${member.id}';

      _activeSubscriptions[subscriptionKey] =
          _firestore.collection('users').doc(member.id).snapshots().listen(
        (doc) {
          if (doc.exists) {
            final userData = doc.data() as Map<String, dynamic>;
            bool isOnline = userData['isOnline'] ?? false;

            // Check last seen time for more accurate status
            final lastSeen = userData['lastSeen'] as Timestamp?;
            if (lastSeen != null) {
              final lastSeenTime = lastSeen.toDate();
              final currentTime = DateTime.now();

              // If last seen is more than 5 minutes ago, consider offline
              if (currentTime.difference(lastSeenTime).inMinutes > 5) {
                isOnline = false;
              }
            }

            userOnlineStatus[member.id] = isOnline;
          }
        },
        onError: (error) {
          print(
              'FirebaseListenerService: User status listener error for ${member.id}: $error');
        },
      );
    }
  }

  // Setup user status listener for a specific user (for chat)
  void setupUserStatusListener(String userId) {
    final subscriptionKey = 'user_status_$userId';

    // Don't create duplicate listeners
    if (_activeSubscriptions.containsKey(subscriptionKey)) {
      return;
    }

    _activeSubscriptions[subscriptionKey] =
        _firestore.collection('users').doc(userId).snapshots().listen(
      (doc) {
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          bool isOnline = userData['isOnline'] ?? false;

          // Check last seen time
          final lastSeen = userData['lastSeen'] as Timestamp?;
          if (lastSeen != null) {
            final lastSeenTime = lastSeen.toDate();
            final currentTime = DateTime.now();

            if (currentTime.difference(lastSeenTime).inMinutes > 5) {
              isOnline = false;
            }
          }

          userOnlineStatus[userId] = isOnline;
        }
      },
      onError: (error) {
        print(
            'FirebaseListenerService: User status listener error for $userId: $error');
      },
    );
  }

  // Cancel all subscriptions
  void _cancelAllSubscriptions() {
    for (final subscription in _activeSubscriptions.values) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
    print('FirebaseListenerService: Cancelled all subscriptions');
  }

  // Cancel user status listeners only
  void _cancelUserStatusListeners() {
    final statusSubscriptionKeys = _activeSubscriptions.keys
        .where((key) => key.startsWith('user_status_'))
        .toList();

    for (final key in statusSubscriptionKeys) {
      _activeSubscriptions[key]?.cancel();
      _activeSubscriptions.remove(key);
    }
  }

  // Cancel specific subscription
  void cancelSubscription(String subscriptionKey) {
    final subscription = _activeSubscriptions[subscriptionKey];
    if (subscription != null) {
      subscription.cancel();
      _activeSubscriptions.remove(subscriptionKey);
      print(
          'FirebaseListenerService: Cancelled subscription: $subscriptionKey');
    }
  }

  // Clear team listeners
  void clearTeamListeners() {
    _cancelAllSubscriptions();
    _currentTeamId = null;
    teamTasks.clear();
    teamMembers.clear();
    userOnlineStatus.clear();
  }

  // Get filtered tasks
  List<Map<String, dynamic>> getFilteredTasks({
    String? category,
    bool? isDone,
    String? searchQuery,
  }) {
    var tasks = teamTasks.toList();

    if (category != null &&
        category.isNotEmpty &&
        category != 'All' &&
        category != 'Tümü') {
      tasks = tasks.where((task) => task['taskCategory'] == category).toList();
    }

    if (isDone != null) {
      tasks = tasks.where((task) => task['isDone'] == isDone).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      tasks = tasks.where((task) {
        final title = (task['taskTitle'] ?? '').toString().toLowerCase();
        final description =
            (task['taskDescription'] ?? '').toString().toLowerCase();
        final category = (task['taskCategory'] ?? '').toString().toLowerCase();
        return title.contains(lowercaseQuery) ||
            description.contains(lowercaseQuery) ||
            category.contains(lowercaseQuery);
      }).toList();
    }

    return tasks;
  }

  // Get user online status
  bool isUserOnline(String userId) {
    return userOnlineStatus[userId] ?? false;
  }

  // Get active subscriptions count (for debugging)
  int get activeSubscriptionsCount => _activeSubscriptions.length;

  // Get current team ID
  String? get currentTeamId => _currentTeamId;

  // Debug method
  void debugPrintActiveSubscriptions() {
    print(
        'FirebaseListenerService: Active subscriptions (${_activeSubscriptions.length}):');
    for (final key in _activeSubscriptions.keys) {
      print('  - $key');
    }
  }
}
