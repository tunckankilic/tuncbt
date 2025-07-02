// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TuncBT';

  @override
  String get language => 'Language';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get tasks => 'Tasks';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginResetPassword => 'Forgot Password';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerName => 'Full Name';

  @override
  String get registerEmail => 'Email Address';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerPhone => 'Phone Number';

  @override
  String get registerPosition => 'Position in Company';

  @override
  String get registerHasAccount => 'Already have an account?';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address to reset your password';

  @override
  String get forgotPasswordEmail => 'Email Address';

  @override
  String get forgotPasswordReset => 'Reset Password';

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskDescription => 'Task Description';

  @override
  String get taskDeadline => 'Deadline';

  @override
  String get taskCategory => 'Task Category';

  @override
  String get uploadTask => 'Upload Task';

  @override
  String get addComment => 'Add Comment';

  @override
  String get taskDone => 'Task Completed';

  @override
  String get taskNotDone => 'Task In Progress';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get deleteTaskConfirm => 'Are you sure you want to delete this task?';

  @override
  String get taskDeleted => 'Task successfully deleted';

  @override
  String get taskDeleteError => 'An error occurred while deleting the task';

  @override
  String get taskUploadSuccess => 'Task uploaded and notification created';

  @override
  String get taskUploadError => 'An error occurred while uploading the task';

  @override
  String get noTasks => 'No team tasks yet';

  @override
  String get addTaskHint => 'Click the + button to add a new task';

  @override
  String get allFieldsRequired => 'All fields are required';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get teamTasks => 'Team Tasks';

  @override
  String get newTask => 'New Task';

  @override
  String get teamMembers => 'Team Members';

  @override
  String teamMembersCount(int count) {
    return '$count Members';
  }

  @override
  String get noTeamMembers => 'No team members yet';

  @override
  String get inviteMembersHint =>
      'Share your referral code to add new members to your team';

  @override
  String get myAccount => 'My Account';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get teamName => 'Team Name';

  @override
  String get referralCode => 'Referral Code';

  @override
  String get referralCodeTitle => 'What is Referral Code?';

  @override
  String get referralCodeDescription =>
      'A referral code is a unique 8-character code used to join a team. If you want to join an existing team, enter the referral code you received from the team administrator. If you want to create your own team, you can leave this field empty.';

  @override
  String get referralCodeOptional =>
      'Referral code is optional. If you want to create your own team, you can leave it empty.';

  @override
  String get inviteMembers => 'Invite Members';

  @override
  String get shareReferralCode => 'Share Referral Code';

  @override
  String get teamSettings => 'Team Settings';

  @override
  String get leaveTeam => 'Leave Team';

  @override
  String get leaveTeamConfirm => 'Are you sure you want to leave the team?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get jobInformation => 'Job Information';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get teamInformation => 'Team Information';

  @override
  String get position => 'Position';

  @override
  String joinedDate(String date) {
    return 'Joined: $date';
  }

  @override
  String get noName => 'No Name';

  @override
  String get editName => 'Edit Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get messages => 'Messages';

  @override
  String get notifications => 'Notifications';

  @override
  String get contact => 'Contact';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get close => 'Close';

  @override
  String get leave => 'Leave';

  @override
  String get loginRequired => 'Login required';

  @override
  String get userNotFound => 'User not found';

  @override
  String get authErrorUserNotFound => 'No user found with this email address';

  @override
  String get authErrorWrongPassword => 'Incorrect password. Please try again';

  @override
  String get authErrorInvalidEmail => 'Invalid email address';

  @override
  String get authErrorUserDisabled => 'This account has been disabled';

  @override
  String get authErrorEmailInUse => 'This email address is already in use';

  @override
  String get authErrorOperationNotAllowed =>
      'This operation is not allowed at the moment';

  @override
  String get authErrorWeakPassword =>
      'The password is too weak. Please choose a stronger password';

  @override
  String get authErrorNetworkFailed =>
      'Network connection error. Please check your internet connection';

  @override
  String get authErrorTooManyRequests =>
      'Too many failed login attempts. Please try again later';

  @override
  String get authErrorInvalidCredential => 'Invalid credentials';

  @override
  String get authErrorAccountExists =>
      'An account already exists with this email using a different sign-in method';

  @override
  String get authErrorInvalidVerificationCode => 'Invalid verification code';

  @override
  String get authErrorInvalidVerificationId => 'Invalid verification ID';

  @override
  String get authErrorQuotaExceeded => 'Quota exceeded. Please try again later';

  @override
  String get authErrorCredentialInUse =>
      'These credentials are already associated with another account';

  @override
  String get authErrorRequiresRecentLogin =>
      'This operation requires a recent login. Please log out and log in again';

  @override
  String get authErrorGeneric => 'An error occurred. Please try again';

  @override
  String get notInTeam => 'You are not a member of any team yet';

  @override
  String get addMember => 'Add Member';

  @override
  String teamJoinDate(String date) {
    return 'Joined: $date';
  }

  @override
  String get signUp => 'Sign Up';

  @override
  String get noPermissionToDelete =>
      'You don\'t have permission to perform this action';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get maximumRetryExceeded => 'Maximum retry attempts exceeded';

  @override
  String get joinTeam => 'Join Team';

  @override
  String get createTeam => 'Create Team';

  @override
  String get fieldMissing => 'This field is required';

  @override
  String get invalidPassword => 'Please enter a valid password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get teamAdminInfo =>
      'After registration, you will be the administrator of your own team';

  @override
  String get creatingTeam => 'Creating your team...\nPlease wait.';

  @override
  String get email => 'Email';

  @override
  String get name => 'Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get allWorkers => 'All Workers';

  @override
  String get teamNotFound => 'Team not found';

  @override
  String get permissionDenied => 'You don\'t have permission for this action';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get dataProcessing => 'Data Processing';

  @override
  String get ageRestriction => 'Age Restriction';

  @override
  String get ageRestrictionText =>
      'You must be at least 13 years old to use this app';

  @override
  String get legalNotice => 'Legal Notice';

  @override
  String get acceptTerms => 'I accept the Terms of Service and Privacy Policy';

  @override
  String get acceptDataProcessing =>
      'I consent to the processing of my personal data';

  @override
  String get acceptAgeRestriction =>
      'I confirm that I am at least 13 years old';

  @override
  String get notificationPermission => 'Notification Permission';

  @override
  String get notificationPermissionText =>
      'Allow notifications to stay updated with your team\'s activities';

  @override
  String get manageNotifications => 'Manage Notifications';

  @override
  String get exportData => 'Export My Data';

  @override
  String get exportDataDescription => 'Download a copy of your personal data';

  @override
  String get deleteData => 'Delete My Data';

  @override
  String get deleteDataDescription =>
      'Permanently delete all your data from our servers';

  @override
  String get cookiePolicy => 'Cookie Policy';

  @override
  String get cookiePolicyDescription =>
      'We use cookies to improve your experience';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String lastUpdated(String date) {
    return 'Last Updated: $date';
  }
}
