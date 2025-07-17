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

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Message shown when code is copied
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// Full name label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Error message shown when logout fails
  ///
  /// In en, this message translates to:
  /// **'Error occurred while logging out'**
  String get logoutError;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @registerHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHasAccount;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @registerName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get registerPhone;

  /// No description provided for @registerPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get registerPosition;

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeam;

  /// No description provided for @joinTeam.
  ///
  /// In en, this message translates to:
  /// **'Join Team'**
  String get joinTeam;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCode;

  /// No description provided for @referralCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get referralCodeOptional;

  /// No description provided for @referralCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Referral Code?'**
  String get referralCodeTitle;

  /// No description provided for @referralCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'A referral code allows you to join an existing team. If you don\'t have a referral code, you can create a new team.'**
  String get referralCodeDescription;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service and Privacy Policy'**
  String get acceptTerms;

  /// No description provided for @acceptDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'I accept the processing of my personal data'**
  String get acceptDataProcessing;

  /// No description provided for @acceptAgeRestriction.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am over 18 years old'**
  String get acceptAgeRestriction;

  /// No description provided for @notificationPermissionText.
  ///
  /// In en, this message translates to:
  /// **'I want to receive notifications'**
  String get notificationPermissionText;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @fieldMissing.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty'**
  String get fieldMissing;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 7 characters'**
  String get invalidPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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
  /// **'Task deleted successfully'**
  String get taskDeleted;

  /// No description provided for @taskDeleteError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the task'**
  String get taskDeleteError;

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

  /// No description provided for @noPermissionToDelete.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this action'**
  String get noPermissionToDelete;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @noTeamMembers.
  ///
  /// In en, this message translates to:
  /// **'No team members found'**
  String get noTeamMembers;

  /// No description provided for @inviteMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Invite team members to get started'**
  String get inviteMembersHint;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'TuncBT'**
  String get appTitle;

  /// Loading message when team data is being fetched
  ///
  /// In en, this message translates to:
  /// **'Loading team data...'**
  String get loadingTeamData;

  /// Loading state message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @loginResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get loginResetPassword;

  /// No description provided for @noTeamYet.
  ///
  /// In en, this message translates to:
  /// **'No Team Yet'**
  String get noTeamYet;

  /// No description provided for @tasksRequireTeam.
  ///
  /// In en, this message translates to:
  /// **'You need to be part of a team to manage tasks'**
  String get tasksRequireTeam;

  /// No description provided for @totalTasks.
  ///
  /// In en, this message translates to:
  /// **'Total Tasks'**
  String get totalTasks;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTasks;

  /// No description provided for @pendingTasks.
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get pendingTasks;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No Tasks Found'**
  String get noTasks;

  /// No description provided for @addTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to get started'**
  String get addTaskHint;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get noTitle;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No Description'**
  String get noDescription;

  /// No description provided for @termsAgeRestriction.
  ///
  /// In en, this message translates to:
  /// **'Age Restriction'**
  String get termsAgeRestriction;

  /// No description provided for @termsAgeRestrictionDesc.
  ///
  /// In en, this message translates to:
  /// **'Users must be 18 years or older to use this service.'**
  String get termsAgeRestrictionDesc;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @accountSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Users are responsible for maintaining the security of their accounts.'**
  String get accountSecurityDesc;

  /// No description provided for @unacceptableBehavior.
  ///
  /// In en, this message translates to:
  /// **'Unacceptable Behavior'**
  String get unacceptableBehavior;

  /// No description provided for @unacceptableBehaviorDesc.
  ///
  /// In en, this message translates to:
  /// **'Any form of harassment, abuse, or illegal activities is strictly prohibited.'**
  String get unacceptableBehaviorDesc;

  /// No description provided for @contentRights.
  ///
  /// In en, this message translates to:
  /// **'Content Rights'**
  String get contentRights;

  /// No description provided for @contentRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Users retain rights to their content while granting us license to use it.'**
  String get contentRightsDesc;

  /// No description provided for @serviceChanges.
  ///
  /// In en, this message translates to:
  /// **'Service Changes'**
  String get serviceChanges;

  /// No description provided for @serviceChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify or discontinue services with notice.'**
  String get serviceChangesDesc;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @disclaimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Service is provided \'as is\' without warranties.'**
  String get disclaimerDesc;

  /// No description provided for @termsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get termsContact;

  /// No description provided for @termsContactDesc.
  ///
  /// In en, this message translates to:
  /// **'For questions about these terms, please contact us.'**
  String get termsContactDesc;

  /// No description provided for @dataCollection.
  ///
  /// In en, this message translates to:
  /// **'Data Collection'**
  String get dataCollection;

  /// No description provided for @dataCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'We collect necessary information to provide our services.'**
  String get dataCollectionDesc;

  /// No description provided for @dataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get dataSecurity;

  /// No description provided for @dataSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'We implement security measures to protect your data.'**
  String get dataSecurityDesc;

  /// No description provided for @dataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get dataSharing;

  /// No description provided for @dataSharingDesc.
  ///
  /// In en, this message translates to:
  /// **'We only share data with your consent or as required by law.'**
  String get dataSharingDesc;

  /// No description provided for @dataDeletion.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion'**
  String get dataDeletion;

  /// No description provided for @dataDeletionDesc.
  ///
  /// In en, this message translates to:
  /// **'You can request deletion of your personal data.'**
  String get dataDeletionDesc;

  /// No description provided for @cookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get cookies;

  /// No description provided for @cookiesDesc.
  ///
  /// In en, this message translates to:
  /// **'We use cookies to improve your experience.'**
  String get cookiesDesc;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @contactInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'For privacy concerns, please contact us.'**
  String get contactInfoDesc;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Group Description'**
  String get groupDescription;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @micPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission'**
  String get micPermissionTitle;

  /// No description provided for @micPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'We need microphone access to record voice messages'**
  String get micPermissionMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @micPermissionSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable microphone access in settings'**
  String get micPermissionSettingsMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

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

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields marked with * are required'**
  String get allFieldsRequired;

  /// No description provided for @taskCategory.
  ///
  /// In en, this message translates to:
  /// **'Task Category'**
  String get taskCategory;

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
  /// **'Task Deadline'**
  String get taskDeadline;

  /// No description provided for @uploadTask.
  ///
  /// In en, this message translates to:
  /// **'Upload Task'**
  String get uploadTask;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgotPasswordEmail;

  /// No description provided for @forgotPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordReset;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
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
  /// **'This email is already in use'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Operation not allowed'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed'**
  String get authErrorNetworkFailed;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorAccountExists.
  ///
  /// In en, this message translates to:
  /// **'Account already exists with different credentials'**
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
  /// **'Quota exceeded'**
  String get authErrorQuotaExceeded;

  /// No description provided for @authErrorCredentialInUse.
  ///
  /// In en, this message translates to:
  /// **'Credential already in use'**
  String get authErrorCredentialInUse;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in again to continue'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again'**
  String get authErrorGeneric;

  /// No description provided for @profile_image_size_error.
  ///
  /// In en, this message translates to:
  /// **'Profile image size cannot exceed 5MB'**
  String get profile_image_size_error;

  /// No description provided for @invalid_image_format.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format. Only images are allowed'**
  String get invalid_image_format;

  /// No description provided for @profile_image_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload profile image'**
  String get profile_image_upload_failed;

  /// No description provided for @creatingTeam.
  ///
  /// In en, this message translates to:
  /// **'Creating your team...\nPlease wait.'**
  String get creatingTeam;

  /// No description provided for @chooseYourJob.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Job'**
  String get chooseYourJob;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @recordingError.
  ///
  /// In en, this message translates to:
  /// **'Recording Error'**
  String get recordingError;

  /// No description provided for @recordingStartError.
  ///
  /// In en, this message translates to:
  /// **'Failed to start recording'**
  String get recordingStartError;

  /// No description provided for @recordingStopError.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop recording'**
  String get recordingStopError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again'**
  String get sessionExpired;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// No description provided for @errorTitleChat.
  ///
  /// In en, this message translates to:
  /// **'Chat Error'**
  String get errorTitleChat;

  /// No description provided for @noPermissionToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'No permission to send message'**
  String get noPermissionToSendMessage;

  /// No description provided for @chatRoomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Chat room not found'**
  String get chatRoomNotFound;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

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

  /// No description provided for @filePickingError.
  ///
  /// In en, this message translates to:
  /// **'Error picking file'**
  String get filePickingError;

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
  /// **'Only admins can add members'**
  String get onlyAdminsCanAdd;

  /// No description provided for @onlyAdminsCanRemove.
  ///
  /// In en, this message translates to:
  /// **'Only admins can remove members'**
  String get onlyAdminsCanRemove;

  /// No description provided for @onlyAdminsCanPromote.
  ///
  /// In en, this message translates to:
  /// **'Only admins can promote members'**
  String get onlyAdminsCanPromote;

  /// No description provided for @failedToRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member'**
  String get failedToRemoveMember;

  /// No description provided for @failedToPromoteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Failed to promote admin'**
  String get failedToPromoteAdmin;

  /// No description provided for @errorTitleGroup.
  ///
  /// In en, this message translates to:
  /// **'Group Error'**
  String get errorTitleGroup;

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

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChats;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'You are not a member of any group yet'**
  String get noGroups;

  /// No description provided for @teamSettings.
  ///
  /// In en, this message translates to:
  /// **'Team Settings'**
  String get teamSettings;

  /// No description provided for @teamInformation.
  ///
  /// In en, this message translates to:
  /// **'Team Information'**
  String get teamInformation;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get teamName;

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

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @leaveTeam.
  ///
  /// In en, this message translates to:
  /// **'Leave Team'**
  String get leaveTeam;

  /// No description provided for @leaveTeamConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this team?'**
  String get leaveTeamConfirm;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

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

  /// No description provided for @groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created successfully'**
  String get groupCreated;

  /// No description provided for @selectMembers.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one member'**
  String get selectMembers;

  /// No description provided for @groupCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating group'**
  String get groupCreationError;

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Group Members'**
  String get groupMembers;

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members available to add'**
  String get noMembers;

  /// No description provided for @taskUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task uploaded successfully'**
  String get taskUploadSuccess;

  /// No description provided for @taskUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading task'**
  String get taskUploadError;

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

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @allWorkers.
  ///
  /// In en, this message translates to:
  /// **'All Workers'**
  String get allWorkers;

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
  /// **'Could not open email app'**
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

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @teamMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Members'**
  String teamMemberCount(int count);

  /// No description provided for @teamMembersLowercase.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get teamMembersLowercase;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String memberCount(int count);

  /// No description provided for @leaveGroupSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have left the group'**
  String get leaveGroupSuccess;

  /// No description provided for @leaveGroupError.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave the group'**
  String get leaveGroupError;

  /// No description provided for @operationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get operationSuccess;

  /// No description provided for @unexpectedErrorWithAction.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please refresh the page and try again'**
  String get unexpectedErrorWithAction;

  /// No description provided for @errorTitleUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload Error'**
  String get errorTitleUpload;

  /// No description provided for @errorTitleNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get errorTitleNetwork;

  /// No description provided for @errorTitleAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get errorTitleAuth;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User not found. Please log in again'**
  String get userNotFoundError;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @shareReferralCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Use this referral code to join my team: {code}'**
  String shareReferralCodeMessage(String code);

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @teamInfo.
  ///
  /// In en, this message translates to:
  /// **'Team Information'**
  String get teamInfo;

  /// No description provided for @teamRole.
  ///
  /// In en, this message translates to:
  /// **'Team Role'**
  String get teamRole;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @teamNotFoundText.
  ///
  /// In en, this message translates to:
  /// **'Team not found'**
  String get teamNotFoundText;

  /// No description provided for @roleNotFoundText.
  ///
  /// In en, this message translates to:
  /// **'Role not found'**
  String get roleNotFoundText;

  /// Subject for team invitation share
  ///
  /// In en, this message translates to:
  /// **'TuncBT Team Invitation'**
  String get teamInviteSubject;

  /// No description provided for @teamCreationDate.
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get teamCreationDate;

  /// No description provided for @memberManagement.
  ///
  /// In en, this message translates to:
  /// **'Member Management'**
  String get memberManagement;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

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

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @maximumRetryExceeded.
  ///
  /// In en, this message translates to:
  /// **'Maximum retry exceeded'**
  String get maximumRetryExceeded;

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

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage Notifications'**
  String get manageNotifications;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Download a copy of your personal data'**
  String get exportDataDescription;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
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

  /// No description provided for @groupChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Group chat feature coming soon'**
  String get groupChatComingSoon;

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

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'New members added'**
  String get memberAdded;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'A member has been removed'**
  String get memberRemoved;

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
  /// **'A member has been removed'**
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

  /// No description provided for @teamErrorMemberDataMissing.
  ///
  /// In en, this message translates to:
  /// **'Member data is missing or invalid'**
  String get teamErrorMemberDataMissing;

  /// No description provided for @teamErrorInvalidRole.
  ///
  /// In en, this message translates to:
  /// **'Invalid team role'**
  String get teamErrorInvalidRole;

  /// No description provided for @teamErrorInvalidTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format'**
  String get teamErrorInvalidTimestamp;

  /// No description provided for @teamErrorMemberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Member not found'**
  String get teamErrorMemberNotFound;

  /// No description provided for @teamErrorDataInvalid.
  ///
  /// In en, this message translates to:
  /// **'Team data is invalid'**
  String get teamErrorDataInvalid;

  /// No description provided for @teamErrorUserDataMissing.
  ///
  /// In en, this message translates to:
  /// **'User data is missing'**
  String get teamErrorUserDataMissing;
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
