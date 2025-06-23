import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en'),
    Locale('de')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'TuncBT'**
  String get appTitle;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Login button and screen title text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button and screen title text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// General cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// General confirmation button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Navigation label for tasks section
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Navigation label for user profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Navigation label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// General save operation button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// General delete operation button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// General edit operation button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// General create operation button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Title shown on login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// Label for email field in login form
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// Label for password field in login form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// Text shown when user doesn't have an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// Text for reset password button
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get loginResetPassword;

  /// Title shown on register screen
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// Label for name field in register form
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerName;

  /// Label for email field in register form
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get registerEmail;

  /// Label for password field in register form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// Label for phone number field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhone;

  /// Label for position field
  ///
  /// In en, this message translates to:
  /// **'Position in Company'**
  String get registerPosition;

  /// Text shown when user already has an account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHasAccount;

  /// Title shown on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// Subtitle shown on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to reset your password'**
  String get forgotPasswordSubtitle;

  /// Label for email field in forgot password form
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgotPasswordEmail;

  /// Text for reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordReset;

  /// Text for back to login button
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Task Description'**
  String get taskDescription;

  /// No description provided for @taskDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get taskDeadline;

  /// No description provided for @taskCategory.
  ///
  /// In en, this message translates to:
  /// **'Task Category'**
  String get taskCategory;

  /// No description provided for @uploadTask.
  ///
  /// In en, this message translates to:
  /// **'Upload Task'**
  String get uploadTask;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addComment;

  /// No description provided for @taskDone.
  ///
  /// In en, this message translates to:
  /// **'Task Completed'**
  String get taskDone;

  /// No description provided for @taskNotDone.
  ///
  /// In en, this message translates to:
  /// **'Task In Progress'**
  String get taskNotDone;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskConfirm;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task successfully deleted'**
  String get taskDeleted;

  /// No description provided for @taskDeleteError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the task'**
  String get taskDeleteError;

  /// No description provided for @taskUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task uploaded and notification created'**
  String get taskUploadSuccess;

  /// No description provided for @taskUploadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while uploading the task'**
  String get taskUploadError;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No team tasks yet'**
  String get noTasks;

  /// No description provided for @addTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Click the + button to add a new task'**
  String get addTaskHint;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get allFieldsRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @teamTasks.
  ///
  /// In en, this message translates to:
  /// **'Team Tasks'**
  String get teamTasks;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @teamMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Members'**
  String teamMembersCount(int count);

  /// No description provided for @noTeamMembers.
  ///
  /// In en, this message translates to:
  /// **'No team members yet'**
  String get noTeamMembers;

  /// No description provided for @inviteMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Share your referral code to add new members to your team'**
  String get inviteMembersHint;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get teamName;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCode;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// No description provided for @shareReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Share Referral Code'**
  String get shareReferralCode;

  /// No description provided for @teamSettings.
  ///
  /// In en, this message translates to:
  /// **'Team Settings'**
  String get teamSettings;

  /// No description provided for @leaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Leave Team'**
  String get leaveTeam;

  /// No description provided for @leaveTeamConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the team?'**
  String get leaveTeamConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @jobInformation.
  ///
  /// In en, this message translates to:
  /// **'Job Information'**
  String get jobInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @teamInformation.
  ///
  /// In en, this message translates to:
  /// **'Team Information'**
  String get teamInformation;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined: {date}'**
  String joinedDate(String date);

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @commentActions.
  ///
  /// In en, this message translates to:
  /// **'Comment Actions'**
  String get commentActions;

  /// No description provided for @replyToComment.
  ///
  /// In en, this message translates to:
  /// **'Reply to Comment'**
  String get replyToComment;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @referralCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'What is a Referral Code?'**
  String get referralCodeTitle;

  /// No description provided for @referralCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'A referral code is an 8-character special code you receive from an existing user. By registering with this code, you can benefit from extra advantages.'**
  String get referralCodeDescription;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email address'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed at the moment'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak. Please choose a stronger password'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your internet connection'**
  String get authErrorNetworkFailed;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many failed login attempts. Please try again later'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email using a different sign-in method'**
  String get authErrorAccountExists;

  /// No description provided for @authErrorInvalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get authErrorInvalidVerificationCode;

  /// No description provided for @authErrorInvalidVerificationId.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification ID'**
  String get authErrorInvalidVerificationId;

  /// No description provided for @authErrorQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Quota exceeded. Please try again later'**
  String get authErrorQuotaExceeded;

  /// No description provided for @authErrorCredentialInUse.
  ///
  /// In en, this message translates to:
  /// **'These credentials are already associated with another account'**
  String get authErrorCredentialInUse;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'This operation requires a recent login. Please log out and log in again'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again'**
  String get authErrorGeneric;

  /// No description provided for @notInTeam.
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any team yet'**
  String get notInTeam;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @teamJoinDate.
  ///
  /// In en, this message translates to:
  /// **'Joined: {date}'**
  String teamJoinDate(String date);

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @noPermissionToDelete.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action'**
  String get noPermissionToDelete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
