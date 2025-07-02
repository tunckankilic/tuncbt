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

  /// No description provided for @referralCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Referral Code?'**
  String get referralCodeTitle;

  /// No description provided for @referralCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'A referral code is a unique 8-character code used to join a team. If you want to join an existing team, enter the referral code you received from the team administrator. If you want to create your own team, you can leave this field empty.'**
  String get referralCodeDescription;

  /// No description provided for @referralCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Referral code is optional. If you want to create your own team, you can leave it empty.'**
  String get referralCodeOptional;

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

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again'**
  String get failedToSendMessage;

  /// No description provided for @failedToSendFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to send file'**
  String get failedToSendFile;

  /// No description provided for @gifSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'GIF sent successfully'**
  String get gifSentSuccessfully;

  /// No description provided for @failedToSendGIF.
  ///
  /// In en, this message translates to:
  /// **'Failed to send GIF'**
  String get failedToSendGIF;

  /// No description provided for @maximumRetryExceeded.
  ///
  /// In en, this message translates to:
  /// **'Maximum retry attempts exceeded'**
  String get maximumRetryExceeded;

  /// Title for joining an existing team
  ///
  /// In en, this message translates to:
  /// **'Join Team'**
  String get joinTeam;

  /// Title for creating a new team
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeam;

  /// Error message for missing required field
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldMissing;

  /// Error message for invalid password
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid password'**
  String get invalidPassword;

  /// Error message for password mismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Information message about becoming team admin after registration
  ///
  /// In en, this message translates to:
  /// **'After registration, you will be the administrator of your own team'**
  String get teamAdminInfo;

  /// No description provided for @creatingTeam.
  ///
  /// In en, this message translates to:
  /// **'Creating your team...\nPlease wait.'**
  String get creatingTeam;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @allWorkers.
  ///
  /// In en, this message translates to:
  /// **'All Workers'**
  String get allWorkers;

  /// No description provided for @teamNotFound.
  ///
  /// In en, this message translates to:
  /// **'Team not found'**
  String get teamNotFound;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this action'**
  String get permissionDenied;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @dataProcessing.
  ///
  /// In en, this message translates to:
  /// **'Data Processing'**
  String get dataProcessing;

  /// No description provided for @ageRestriction.
  ///
  /// In en, this message translates to:
  /// **'Age Restriction'**
  String get ageRestriction;

  /// No description provided for @ageRestrictionText.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 13 years old to use this app'**
  String get ageRestrictionText;

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legalNotice;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service and Privacy Policy'**
  String get acceptTerms;

  /// No description provided for @acceptDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'I consent to the processing of my personal data'**
  String get acceptDataProcessing;

  /// No description provided for @acceptAgeRestriction.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am at least 13 years old'**
  String get acceptAgeRestriction;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @notificationPermissionText.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to stay updated with your team\'s activities'**
  String get notificationPermissionText;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage Notifications'**
  String get manageNotifications;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Download a copy of your personal data'**
  String get exportDataDescription;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete My Data'**
  String get deleteData;

  /// No description provided for @deleteDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all your data from our servers'**
  String get deleteDataDescription;

  /// No description provided for @cookiePolicy.
  ///
  /// In en, this message translates to:
  /// **'Cookie Policy'**
  String get cookiePolicy;

  /// No description provided for @cookiePolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'We use cookies to improve your experience'**
  String get cookiePolicyDescription;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get groupDescription;

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembers;

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members available to add'**
  String get noMembers;

  /// No description provided for @selectMembers.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one member'**
  String get selectMembers;

  /// No description provided for @groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get groupCreated;

  /// No description provided for @groupCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating group'**
  String get groupCreationError;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noChats;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any group yet'**
  String get noGroups;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String memberCount(int count);

  /// No description provided for @groupChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Group chat feature coming soon'**
  String get groupChatComingSoon;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @deleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat?'**
  String get deleteChatConfirm;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @onlyAdminsCanMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Only group admins can assign new admins'**
  String get onlyAdminsCanMakeAdmin;

  /// No description provided for @newMembersAdded.
  ///
  /// In en, this message translates to:
  /// **'New members added'**
  String get newMembersAdded;

  /// No description provided for @newAdminAssigned.
  ///
  /// In en, this message translates to:
  /// **'New group admin assigned'**
  String get newAdminAssigned;

  /// No description provided for @groupCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get groupCreatedMessage;

  /// No description provided for @micPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission'**
  String get micPermissionTitle;

  /// No description provided for @micPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'We need microphone permission to send voice messages. Would you like to grant permission?'**
  String get micPermissionMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get notNow;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueAction;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @micPermissionSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to send voice messages. Please grant permission in settings.'**
  String get micPermissionSettingsMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'OPEN SETTINGS'**
  String get openSettings;

  /// No description provided for @recordingError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get recordingError;

  /// No description provided for @recordingStartError.
  ///
  /// In en, this message translates to:
  /// **'Could not start recording'**
  String get recordingStartError;

  /// No description provided for @recordingStopError.
  ///
  /// In en, this message translates to:
  /// **'Could not stop recording'**
  String get recordingStopError;

  /// No description provided for @filePickingError.
  ///
  /// In en, this message translates to:
  /// **'Error picking file'**
  String get filePickingError;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @messageDeletionError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting message'**
  String get messageDeletionError;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlocked;

  /// No description provided for @userBlockError.
  ///
  /// In en, this message translates to:
  /// **'Error blocking user'**
  String get userBlockError;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get userUnblocked;

  /// No description provided for @userUnblockError.
  ///
  /// In en, this message translates to:
  /// **'Error unblocking user'**
  String get userUnblockError;

  /// No description provided for @onlyAdminsCanAdd.
  ///
  /// In en, this message translates to:
  /// **'Only group admins can add members'**
  String get onlyAdminsCanAdd;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'New members added'**
  String get memberAdded;

  /// No description provided for @onlyAdminsCanRemove.
  ///
  /// In en, this message translates to:
  /// **'Only group administrators can remove members'**
  String get onlyAdminsCanRemove;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'A member was removed from the group'**
  String get memberRemoved;

  /// No description provided for @onlyAdminsCanPromote.
  ///
  /// In en, this message translates to:
  /// **'Only group administrators can promote new administrators'**
  String get onlyAdminsCanPromote;

  /// No description provided for @adminAssigned.
  ///
  /// In en, this message translates to:
  /// **'New group admin assigned'**
  String get adminAssigned;

  /// No description provided for @systemMessageNewMembers.
  ///
  /// In en, this message translates to:
  /// **'New members added'**
  String get systemMessageNewMembers;

  /// No description provided for @systemMessageMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'A member was removed'**
  String get systemMessageMemberRemoved;

  /// No description provided for @systemMessageNewAdmin.
  ///
  /// In en, this message translates to:
  /// **'New group admin assigned'**
  String get systemMessageNewAdmin;

  /// No description provided for @systemMessageGroupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get systemMessageGroupCreated;

  /// No description provided for @teamCreationDate.
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get teamCreationDate;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @memberManagement.
  ///
  /// In en, this message translates to:
  /// **'Member Management'**
  String get memberManagement;

  /// No description provided for @teamMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String teamMemberCount(int count);

  /// No description provided for @teamMembersLowercase.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get teamMembersLowercase;

  /// No description provided for @chooseYourJob.
  ///
  /// In en, this message translates to:
  /// **'Choose your Job'**
  String get chooseYourJob;

  /// No description provided for @noTeamYet.
  ///
  /// In en, this message translates to:
  /// **'You are not in a team yet'**
  String get noTeamYet;

  /// No description provided for @tasksRequireTeam.
  ///
  /// In en, this message translates to:
  /// **'You need to join a team to view tasks'**
  String get tasksRequireTeam;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @dataCollection.
  ///
  /// In en, this message translates to:
  /// **'Data Collection and Usage'**
  String get dataCollection;

  /// No description provided for @dataCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Our app collects and processes some of your personal data to provide better service. This data includes:\n\n• Name and email address\n• Profile picture\n• Phone number\n• Team and task information\n• Usage statistics'**
  String get dataCollectionDesc;

  /// No description provided for @dataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get dataSecurity;

  /// No description provided for @dataSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored securely and encrypted using Firebase infrastructure. Only authorized personnel can access your data.'**
  String get dataSecurityDesc;

  /// No description provided for @dataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get dataSharing;

  /// No description provided for @dataSharingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is not shared with third parties. Only necessary information is shared between team members.'**
  String get dataSharingDesc;

  /// No description provided for @dataDeletion.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion'**
  String get dataDeletion;

  /// No description provided for @dataDeletionDesc.
  ///
  /// In en, this message translates to:
  /// **'When you delete your account, all your personal data and related content (messages, comments, tasks) are permanently deleted.'**
  String get dataDeletionDesc;

  /// No description provided for @cookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get cookies;

  /// No description provided for @cookiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Our app may use cookies to provide a better user experience.'**
  String get cookiesDesc;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactInfo;

  /// No description provided for @contactInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'For questions about our privacy policy, you can reach us at support@tuncbt.com'**
  String get contactInfoDesc;

  /// No description provided for @lastUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdatedAt(String date);

  /// No description provided for @termsAgeRestriction.
  ///
  /// In en, this message translates to:
  /// **'Age Restriction'**
  String get termsAgeRestriction;

  /// No description provided for @termsAgeRestrictionDesc.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 13 years old to use this app. If you are under 13, you must use it under the supervision of a parent or legal guardian.'**
  String get termsAgeRestrictionDesc;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @accountSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for your account security. Do not share your password with anyone and keep it secure.'**
  String get accountSecurityDesc;

  /// No description provided for @unacceptableBehavior.
  ///
  /// In en, this message translates to:
  /// **'Unacceptable Behavior'**
  String get unacceptableBehavior;

  /// No description provided for @unacceptableBehaviorDesc.
  ///
  /// In en, this message translates to:
  /// **'• Illegal content sharing\n• Spam or unwanted content\n• Harassment or bullying\n• Sharing others\' personal data without permission\n• System abuse'**
  String get unacceptableBehaviorDesc;

  /// No description provided for @contentRights.
  ///
  /// In en, this message translates to:
  /// **'Content Rights'**
  String get contentRights;

  /// No description provided for @contentRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'You must confirm that you own the rights to the content you share or have the right to share it.'**
  String get contentRightsDesc;

  /// No description provided for @serviceChanges.
  ///
  /// In en, this message translates to:
  /// **'Service Changes'**
  String get serviceChanges;

  /// No description provided for @serviceChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify, suspend, or terminate our services without prior notice.'**
  String get serviceChangesDesc;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @disclaimerDesc.
  ///
  /// In en, this message translates to:
  /// **'The application is provided \'as is\'. We do not guarantee that it will operate without interruption or errors.'**
  String get disclaimerDesc;

  /// No description provided for @termsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get termsContact;

  /// No description provided for @termsContactDesc.
  ///
  /// In en, this message translates to:
  /// **'For questions about terms of service, you can reach us at support@tuncbt.com'**
  String get termsContactDesc;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @sendWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send WhatsApp Message'**
  String get sendWhatsApp;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get startChat;

  /// No description provided for @whatsAppError.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get whatsAppError;

  /// No description provided for @emailError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email application'**
  String get emailError;

  /// No description provided for @emailSubject.
  ///
  /// In en, this message translates to:
  /// **'TuncBT - Contact'**
  String get emailSubject;

  /// No description provided for @emailBody.
  ///
  /// In en, this message translates to:
  /// **'Hello {name},\n\n'**
  String emailBody(String name);

  /// No description provided for @profile_image_size_error.
  ///
  /// In en, this message translates to:
  /// **'Profile image size cannot be larger than 5MB'**
  String get profile_image_size_error;

  /// No description provided for @invalid_image_format.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format. Only image files are allowed'**
  String get invalid_image_format;

  /// No description provided for @profile_image_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload profile image. Please try again'**
  String get profile_image_upload_failed;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again'**
  String get sessionExpired;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Unable to access your user information. Please log in again'**
  String get userNotFoundError;

  /// No description provided for @unexpectedErrorWithAction.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please refresh the page and try again'**
  String get unexpectedErrorWithAction;

  /// No description provided for @errorTitleChat.
  ///
  /// In en, this message translates to:
  /// **'Message Error'**
  String get errorTitleChat;

  /// No description provided for @errorTitleAuth.
  ///
  /// In en, this message translates to:
  /// **'Login Error'**
  String get errorTitleAuth;

  /// No description provided for @errorTitleGroup.
  ///
  /// In en, this message translates to:
  /// **'Group Operation Failed'**
  String get errorTitleGroup;

  /// No description provided for @errorTitleUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload Error'**
  String get errorTitleUpload;

  /// No description provided for @errorTitleNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorTitleNetwork;

  /// No description provided for @noPermissionToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to send this message'**
  String get noPermissionToSendMessage;

  /// No description provided for @chatRoomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Chat room not found'**
  String get chatRoomNotFound;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get networkError;

  /// No description provided for @failedToRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member from group'**
  String get failedToRemoveMember;

  /// No description provided for @failedToPromoteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Failed to promote user to admin'**
  String get failedToPromoteAdmin;
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
