// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Habit App`
  String get appTitle {
    return Intl.message(
      'Habit App',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }
  /// Select Language
  String get selectLanguage => 'Select Language';

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `More Personalization`
  String get morePersonalization {
    return Intl.message(
      'More Personalization',
      name: 'morePersonalization',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Change Email`
  String get changeEmail {
    return Intl.message(
      'Change Email',
      name: 'changeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter the new email address twice to change it.`
  String get enterNewEmailTwice {
    return Intl.message(
      'Enter the new email address twice to change it.',
      name: 'enterNewEmailTwice',
      desc: '',
      args: [],
    );
  }

  /// `New Email`
  String get newEmail {
    return Intl.message(
      'New Email',
      name: 'newEmail',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Email`
  String get confirmNewEmail {
    return Intl.message(
      'Confirm New Email',
      name: 'confirmNewEmail',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get cancel {
    return Intl.message(
      'CANCEL',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the email address in both fields.`
  String get enterEmailInBothFields {
    return Intl.message(
      'Please enter the email address in both fields.',
      name: 'enterEmailInBothFields',
      desc: '',
      args: [],
    );
  }

  /// `Email addresses do not match.`
  String get emailsDoNotMatch {
    return Intl.message(
      'Email addresses do not match.',
      name: 'emailsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Login email has been changed. Check your inbox to verify the new email address.`
  String get emailChangedCheckInbox {
    return Intl.message(
      'Login email has been changed. Check your inbox to verify the new email address.',
      name: 'emailChangedCheckInbox',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address.`
  String get invalidEmail {
    return Intl.message(
      'Invalid email address.',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Email address is already in use.`
  String get emailAlreadyInUse {
    return Intl.message(
      'Email address is already in use.',
      name: 'emailAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred: {errorMessage}`
  String unknownError(Object errorMessage) {
    return Intl.message(
      'An unknown error occurred: $errorMessage',
      name: 'unknownError',
      desc: '',
      args: [errorMessage],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter the new password twice to change it.`
  String get enterNewPasswordTwice {
    return Intl.message(
      'Enter the new password twice to change it.',
      name: 'enterNewPasswordTwice',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get confirmNewPassword {
    return Intl.message(
      'Confirm New Password',
      name: 'confirmNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the password in both fields.`
  String get enterPasswordInBothFields {
    return Intl.message(
      'Please enter the password in both fields.',
      name: 'enterPasswordInBothFields',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match.`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match.',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Password has been changed.`
  String get passwordChanged {
    return Intl.message(
      'Password has been changed.',
      name: 'passwordChanged',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak.`
  String get weakPassword {
    return Intl.message(
      'Password is too weak.',
      name: 'weakPassword',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account?`
  String get confirmDeleteAccount {
    return Intl.message(
      'Are you sure you want to delete your account?',
      name: 'confirmDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting account`
  String get errorDeletingAccount {
    return Intl.message(
      'Error deleting account',
      name: 'errorDeletingAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to sign out?`
  String get confirmSignOut {
    return Intl.message(
      'Are you sure you want to sign out?',
      name: 'confirmSignOut',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation`
  String get confirmation {
    return Intl.message(
      'Confirmation',
      name: 'confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message(
      'Support',
      name: 'support',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get supportTitle {
    return Intl.message(
      'Support',
      name: 'supportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Contact Support`
  String get contactSupport {
    return Intl.message(
      'Contact Support',
      name: 'contactSupport',
      desc: '',
      args: [],
    );
  }

  /// `Get in touch with our support team`
  String get contactSupportSubtitle {
    return Intl.message(
      'Get in touch with our support team',
      name: 'contactSupportSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Share your feedback with us`
  String get feedbackSubtitle {
    return Intl.message(
      'Share your feedback with us',
      name: 'feedbackSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Learn about our privacy practices`
  String get privacyPolicySubtitle {
    return Intl.message(
      'Learn about our privacy practices',
      name: 'privacyPolicySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `About App`
  String get aboutApp {
    return Intl.message(
      'About App',
      name: 'aboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Information and licenses`
  String get aboutAppSubtitle {
    return Intl.message(
      'Information and licenses',
      name: 'aboutAppSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message(
      'Contact',
      name: 'contact',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `MORNING`
  String get morning {
    return Intl.message(
      'MORNING',
      name: 'morning',
      desc: '',
      args: [],
    );
  }

  /// `AFTERNOON`
  String get afternoon {
    return Intl.message(
      'AFTERNOON',
      name: 'afternoon',
      desc: '',
      args: [],
    );
  }

  /// `EVENING`
  String get evening {
    return Intl.message(
      'EVENING',
      name: 'evening',
      desc: '',
      args: [],
    );
  }

  /// `Active Habits`
  String get activeHabits {
    return Intl.message(
      'Active Habits',
      name: 'activeHabits',
      desc: '',
      args: [],
    );
  }

  /// `Completed Habits`
  String get completedHabits {
    return Intl.message(
      'Completed Habits',
      name: 'completedHabits',
      desc: '',
      args: [],
    );
  }

  /// `No Active Habits`
  String get noActiveHabits {
    return Intl.message(
      'No Active Habits',
      name: 'noActiveHabits',
      desc: '',
      args: [],
    );
  }

  /// `No Completed Habits`
  String get noCompletedHabits {
    return Intl.message(
      'No Completed Habits',
      name: 'noCompletedHabits',
      desc: '',
      args: [],
    );
  }

  /// `Habit Marked Incomplete`
  String get habitMarkedIncomplete {
    return Intl.message(
      'Habit Marked Incomplete',
      name: 'habitMarkedIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `Habit Completed`
  String get habitCompleted {
    return Intl.message(
      'Habit Completed',
      name: 'habitCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Loading Error`
  String get loadingError {
    return Intl.message(
      'Loading Error',
      name: 'loadingError',
      desc: '',
      args: [],
    );
  }

  /// `Progress`
  String get progressTitle {
    return Intl.message(
      'Progress',
      name: 'progressTitle',
      desc: '',
      args: [],
    );
  }

  /// `Here is your progress`
  String get progressContent {
    return Intl.message(
      'Here is your progress',
      name: 'progressContent',
      desc: '',
      args: [],
    );
  }

  /// `Unknown email`
  String get unknownEmail {
    return Intl.message(
      'Unknown email',
      name: 'unknownEmail',
      desc: '',
      args: [],
    );
  }

  /// `Unknown name`
  String get unknownName {
    return Intl.message(
      'Unknown name',
      name: 'unknownName',
      desc: '',
      args: [],
    );
  }

  /// `Time Range`
  String get timeRange {
    return Intl.message(
      'Time Range',
      name: 'timeRange',
      desc: '',
      args: [],
    );
  }

  /// `This Week`
  String get thisWeek {
    return Intl.message(
      'This Week',
      name: 'thisWeek',
      desc: '',
      args: [],
    );
  }

  /// `Quick Stats`
  String get quickStats {
    return Intl.message(
      'Quick Stats',
      name: 'quickStats',
      desc: '',
      args: [],
    );
  }

  /// `Total Work Hours`
  String get totalWorkHours {
    return Intl.message(
      'Total Work Hours',
      name: 'totalWorkHours',
      desc: '',
      args: [],
    );
  }

  /// `Completed Tasks`
  String get completedTasks {
    return Intl.message(
      'Completed Tasks',
      name: 'completedTasks',
      desc: '',
      args: [],
    );
  }

  /// `Graphical Visualizations`
  String get graphicalVisualizations {
    return Intl.message(
      'Graphical Visualizations',
      name: 'graphicalVisualizations',
      desc: '',
      args: [],
    );
  }

  /// `Additional Options`
  String get additionalOptions {
    return Intl.message(
      'Additional Options',
      name: 'additionalOptions',
      desc: '',
      args: [],
    );
  }

  /// `Payment Methods`
  String get paymentMethods {
    return Intl.message(
      'Payment Methods',
      name: 'paymentMethods',
      desc: '',
      args: [],
    );
  }

  /// `Longest Streak`
  String get longestStreak {
    return Intl.message(
      'Longest Streak',
      name: 'longestStreak',
      desc: '',
      args: [],
    );
  }

  /// `Account Settings`
  String get accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'accountSettings',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message(
      'Sign Out',
      name: 'signOut',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notificationsTitle {
    return Intl.message(
      'Notifications',
      name: 'notificationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Push Notifications`
  String get pushNotifications {
    return Intl.message(
      'Push Notifications',
      name: 'pushNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive notifications on your device`
  String get pushNotificationsSubtitle {
    return Intl.message(
      'Receive notifications on your device',
      name: 'pushNotificationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Email Notifications`
  String get emailNotifications {
    return Intl.message(
      'Email Notifications',
      name: 'emailNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Receive notifications via email`
  String get emailNotificationsSubtitle {
    return Intl.message(
      'Receive notifications via email',
      name: 'emailNotificationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Daily Reminders`
  String get dailyReminders {
    return Intl.message(
      'Daily Reminders',
      name: 'dailyReminders',
      desc: '',
      args: [],
    );
  }

  /// `Set reminders for habits`
  String get dailyRemindersSubtitle {
    return Intl.message(
      'Set reminders for habits',
      name: 'dailyRemindersSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Reminder Time`
  String get reminderTime {
    return Intl.message(
      'Reminder Time',
      name: 'reminderTime',
      desc: '',
      args: [],
    );
  }

  /// `Notification Days`
  String get notificationDays {
    return Intl.message(
      'Notification Days',
      name: 'notificationDays',
      desc: '',
      args: [],
    );
  }

  /// `Mon`
  String get monday {
    return Intl.message(
      'Mon',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Tue`
  String get tuesday {
    return Intl.message(
      'Tue',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wed`
  String get wednesday {
    return Intl.message(
      'Wed',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thu`
  String get thursday {
    return Intl.message(
      'Thu',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Fri`
  String get friday {
    return Intl.message(
      'Fri',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Sat`
  String get saturday {
    return Intl.message(
      'Sat',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `Sun`
  String get sunday {
    return Intl.message(
      'Sun',
      name: 'sunday',
      desc: '',
      args: [],
    );
  }

  /// `Personalization`
  String get personalizationTitle {
    return Intl.message(
      'Personalization',
      name: 'personalizationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Change the app's color scheme`
  String get darkModeSubtitle {
    return Intl.message(
      'Change the app\'s color scheme',
      name: 'darkModeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Text Size`
  String get textSize {
    return Intl.message(
      'Text Size',
      name: 'textSize',
      desc: '',
      args: [],
    );
  }

  /// `Theme Color`
  String get themeColor {
    return Intl.message(
      'Theme Color',
      name: 'themeColor',
      desc: '',
      args: [],
    );
  }

  /// `Layout`
  String get layout {
    return Intl.message(
      'Layout',
      name: 'layout',
      desc: '',
      args: [],
    );
  }

  /// `Compact View`
  String get compactView {
    return Intl.message(
      'Compact View',
      name: 'compactView',
      desc: '',
      args: [],
    );
  }

  /// `Show Labels`
  String get showLabels {
    return Intl.message(
      'Show Labels',
      name: 'showLabels',
      desc: '',
      args: [],
    );
  }

  /// `Blue`
  String get blue {
    return Intl.message(
      'Blue',
      name: 'blue',
      desc: '',
      args: [],
    );
  }

  /// `Green`
  String get green {
    return Intl.message(
      'Green',
      name: 'green',
      desc: '',
      args: [],
    );
  }

  /// `Purple`
  String get purple {
    return Intl.message(
      'Purple',
      name: 'purple',
      desc: '',
      args: [],
    );
  }

  /// `Red`
  String get red {
    return Intl.message(
      'Red',
      name: 'red',
      desc: '',
      args: [],
    );
  }

  /// `Brown`
  String get brown {
    return Intl.message(
      'Brown',
      name: 'brown',
      desc: '',
      args: [],
    );
  }

  /// `Black`
  String get black {
    return Intl.message(
      'Black',
      name: 'black',
      desc: '',
      args: [],
    );
  }

  /// `Grey`
  String get grey {
    return Intl.message(
      'Grey',
      name: 'grey',
      desc: '',
      args: [],
    );
  }

  /// `Orange`
  String get orange {
    return Intl.message(
      'Orange',
      name: 'orange',
      desc: '',
      args: [],
    );
  }

  /// `Pink`
  String get pink {
    return Intl.message(
      'Pink',
      name: 'pink',
      desc: '',
      args: [],
    );
  }

  /// `Lime`
  String get lime {
    return Intl.message(
      'Lime',
      name: 'lime',
      desc: '',
      args: [],
    );
  }

  /// `Habits`
  String get habits {
    return Intl.message(
      'Habits',
      name: 'habits',
      desc: '',
      args: [],
    );
  }

  /// `Guides`
  String get guides {
    return Intl.message(
      'Guides',
      name: 'guides',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get statistics {
    return Intl.message(
      'Statistics',
      name: 'statistics',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to the guides section! Here you will find the latest information and tips on habit management.`
  String get guidesHeader {
    return Intl.message(
      'Welcome to the guides section! Here you will find the latest information and tips on habit management.',
      name: 'guidesHeader',
      desc: '',
      args: [],
    );
  }

  /// `How to Create Good Habits`
  String get guideTitle1 {
    return Intl.message(
      'How to Create Good Habits',
      name: 'guideTitle1',
      desc: '',
      args: [],
    );
  }

  /// `Learn how to effectively create and maintain good habits.`
  String get guideSubtitle1 {
    return Intl.message(
      'Learn how to effectively create and maintain good habits.',
      name: 'guideSubtitle1',
      desc: '',
      args: [],
    );
  }

  /// `Creating good habits requires consistency and patience. Here are some steps that can help you:\n\n1. Define your goal.\n2. Start with small steps.\n3. Be consistent.\n4. Monitor your progress.\n5. Reward yourself for achievements.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.`
  String get guideContent1 {
    return Intl.message(
      'Creating good habits requires consistency and patience. Here are some steps that can help you:\n\n1. Define your goal.\n2. Start with small steps.\n3. Be consistent.\n4. Monitor your progress.\n5. Reward yourself for achievements.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.',
      name: 'guideContent1',
      desc: '',
      args: [],
    );
  }

  /// `Time Management`
  String get guideTitle2 {
    return Intl.message(
      'Time Management',
      name: 'guideTitle2',
      desc: '',
      args: [],
    );
  }

  /// `Tips for effective time management.`
  String get guideSubtitle2 {
    return Intl.message(
      'Tips for effective time management.',
      name: 'guideSubtitle2',
      desc: '',
      args: [],
    );
  }

  /// `Effective time management is key to achieving success. Here are some tips:\n\n1. Plan your day.\n2. Set priorities.\n3. Avoid distractions.\n4. Delegate tasks.\n5. Regularly assess your progress.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.`
  String get guideContent2 {
    return Intl.message(
      'Effective time management is key to achieving success. Here are some tips:\n\n1. Plan your day.\n2. Set priorities.\n3. Avoid distractions.\n4. Delegate tasks.\n5. Regularly assess your progress.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.',
      name: 'guideContent2',
      desc: '',
      args: [],
    );
  }

  /// `Motivation to Act`
  String get guideTitle3 {
    return Intl.message(
      'Motivation to Act',
      name: 'guideTitle3',
      desc: '',
      args: [],
    );
  }

  /// `How to keep your motivation to act at a high level.`
  String get guideSubtitle3 {
    return Intl.message(
      'How to keep your motivation to act at a high level.',
      name: 'guideSubtitle3',
      desc: '',
      args: [],
    );
  }

  /// `Maintaining motivation to act can be challenging. Here are some strategies:\n\n1. Set realistic goals.\n2. Find your "why".\n3. Surround yourself with positive people.\n4. Celebrate small successes.\n5. Be flexible and adjust your plans.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.`
  String get guideContent3 {
    return Intl.message(
      'Maintaining motivation to act can be challenging. Here are some strategies:\n\n1. Set realistic goals.\n2. Find your "why".\n3. Surround yourself with positive people.\n4. Celebrate small successes.\n5. Be flexible and adjust your plans.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.',
      name: 'guideContent3',
      desc: '',
      args: [],
    );
  }

  /// `Healthy Eating Habits`
  String get guideTitle4 {
    return Intl.message(
      'Healthy Eating Habits',
      name: 'guideTitle4',
      desc: '',
      args: [],
    );
  }

  /// `Tips for healthy eating and dietary habits.`
  String get guideSubtitle4 {
    return Intl.message(
      'Tips for healthy eating and dietary habits.',
      name: 'guideSubtitle4',
      desc: '',
      args: [],
    );
  }

  /// `Healthy eating habits are key to well-being. Here are some tips:\n\n1. Eat regularly.\n2. Choose whole foods.\n3. Avoid processed foods.\n4. Drink plenty of water.\n5. Listen to your body.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.`
  String get guideContent4 {
    return Intl.message(
      'Healthy eating habits are key to well-being. Here are some tips:\n\n1. Eat regularly.\n2. Choose whole foods.\n3. Avoid processed foods.\n4. Drink plenty of water.\n5. Listen to your body.\n\nAdditional information:\n- Set realistic goals.\n- Find your "why".\n- Surround yourself with positive people.\n- Celebrate small successes.\n- Be flexible and adjust your plans.',
      name: 'guideContent4',
      desc: '',
      args: [],
    );
  }

  /// `Summary Today`
  String get summaryToday {
    return Intl.message(
      'Summary Today',
      name: 'summaryToday',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Progress`
  String get weeklyProgress {
    return Intl.message(
      'Weekly Progress',
      name: 'weeklyProgress',
      desc: '',
      args: [],
    );
  }

  /// `Success Rate`
  String get successRate {
    return Intl.message(
      'Success Rate',
      name: 'successRate',
      desc: '',
      args: [],
    );
  }

  /// `Most Active Day`
  String get mostActiveDay {
    return Intl.message(
      'Most Active Day',
      name: 'mostActiveDay',
      desc: '',
      args: [],
    );
  }

  /// `Habit Completion Percentage from January to December`
  String get habitCompletionPercentage {
    return Intl.message(
      'Habit Completion Percentage from January to December',
      name: 'habitCompletionPercentage',
      desc: '',
      args: [],
    );
  }

  /// `General Settings`
  String get generalSettings {
    return Intl.message(
      'General Settings',
      name: 'generalSettings',
      desc: '',
      args: [],
    );
  }

  /// `January`
  String get january {
    return Intl.message(
      'January',
      name: 'january',
      desc: '',
      args: [],
    );
  }

  /// `February`
  String get february {
    return Intl.message(
      'February',
      name: 'february',
      desc: '',
      args: [],
    );
  }

  /// `March`
  String get march {
    return Intl.message(
      'March',
      name: 'march',
      desc: '',
      args: [],
    );
  }

  /// `April`
  String get april {
    return Intl.message(
      'April',
      name: 'april',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get may {
    return Intl.message(
      'May',
      name: 'may',
      desc: '',
      args: [],
    );
  }

  /// `June`
  String get june {
    return Intl.message(
      'June',
      name: 'june',
      desc: '',
      args: [],
    );
  }

  /// `July`
  String get july {
    return Intl.message(
      'July',
      name: 'july',
      desc: '',
      args: [],
    );
  }

  /// `August`
  String get august {
    return Intl.message(
      'August',
      name: 'august',
      desc: '',
      args: [],
    );
  }

  /// `September`
  String get september {
    return Intl.message(
      'September',
      name: 'september',
      desc: '',
      args: [],
    );
  }

  /// `October`
  String get october {
    return Intl.message(
      'October',
      name: 'october',
      desc: '',
      args: [],
    );
  }

  /// `November`
  String get november {
    return Intl.message(
      'November',
      name: 'november',
      desc: '',
      args: [],
    );
  }

  /// `December`
  String get december {
    return Intl.message(
      'December',
      name: 'december',
      desc: '',
      args: [],
    );
  }

  /// `Mon`
  String get mondayShort {
    return Intl.message(
      'Mon',
      name: 'mondayShort',
      desc: '',
      args: [],
    );
  }

  /// `Tue`
  String get tuesdayShort {
    return Intl.message(
      'Tue',
      name: 'tuesdayShort',
      desc: '',
      args: [],
    );
  }

  /// `Wed`
  String get wednesdayShort {
    return Intl.message(
      'Wed',
      name: 'wednesdayShort',
      desc: '',
      args: [],
    );
  }

  /// `Thu`
  String get thursdayShort {
    return Intl.message(
      'Thu',
      name: 'thursdayShort',
      desc: '',
      args: [],
    );
  }

  /// `Fri`
  String get fridayShort {
    return Intl.message(
      'Fri',
      name: 'fridayShort',
      desc: '',
      args: [],
    );
  }

  /// `Sat`
  String get saturdayShort {
    return Intl.message(
      'Sat',
      name: 'saturdayShort',
      desc: '',
      args: [],
    );
  }

  /// `Sun`
  String get sundayShort {
    return Intl.message(
      'Sun',
      name: 'sundayShort',
      desc: '',
      args: [],
    );
  }

  /// `Add Habit`
  String get addHabit {
    return Intl.message(
      'Add Habit',
      name: 'addHabit',
      desc: '',
      args: [],
    );
  }

  /// `Basic Information`
  String get basicInfo {
    return Intl.message(
      'Basic Information',
      name: 'basicInfo',
      desc: '',
      args: [],
    );
  }

  /// `Habit Name`
  String get habitName {
    return Intl.message(
      'Habit Name',
      name: 'habitName',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get schedule {
    return Intl.message(
      'Schedule',
      name: 'schedule',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get startDate {
    return Intl.message(
      'Start Date',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message(
      'Select Date',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  /// `Repeat`
  String get repeat {
    return Intl.message(
      'Repeat',
      name: 'repeat',
      desc: '',
      args: [],
    );
  }

  /// `Repeat Settings`
  String get repeatSettings {
    return Intl.message(
      'Repeat Settings',
      name: 'repeatSettings',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `Select Days of the Week`
  String get selectDaysOfWeek {
    return Intl.message(
      'Select Days of the Week',
      name: 'selectDaysOfWeek',
      desc: '',
      args: [],
    );
  }

  /// `Execution Details`
  String get executionDetails {
    return Intl.message(
      'Execution Details',
      name: 'executionDetails',
      desc: '',
      args: [],
    );
  }

  /// `Time of Day`
  String get timeOfDay {
    return Intl.message(
      'Time of Day',
      name: 'timeOfDay',
      desc: '',
      args: [],
    );
  }

  /// `Reminders`
  String get reminders {
    return Intl.message(
      'Reminders',
      name: 'reminders',
      desc: '',
      args: [],
    );
  }

  /// `Add Reminder`
  String get addReminder {
    return Intl.message(
      'Add Reminder',
      name: 'addReminder',
      desc: '',
      args: [],
    );
  }

  /// `SAVE`
  String get save {
    return Intl.message(
      'SAVE',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred: {errorMessage}`
  String errorMessage(Object errorMessage) {
    return Intl.message(
      'An error occurred: $errorMessage',
      name: 'errorMessage',
      desc: '',
      args: [errorMessage],
    );
  }

  /// `Daily ({selectedDaysCount} days a week)`
  String repeatSummary(Object selectedDaysCount) {
    return Intl.message(
      'Daily ($selectedDaysCount days a week)',
      name: 'repeatSummary',
      desc: '',
      args: [selectedDaysCount],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address to reset your password.`
  String get resetPasswordDescription {
    return Intl.message(
      'Enter your email address to reset your password.',
      name: 'resetPasswordDescription',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the email address in both fields.`
  String get emailErrorMessage {
    return Intl.message(
      'Please enter the email address in both fields.',
      name: 'emailErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Email addresses do not match.`
  String get emailMismatchError {
    return Intl.message(
      'Email addresses do not match.',
      name: 'emailMismatchError',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account?`
  String get deleteAccountConfirmation {
    return Intl.message(
      'Are you sure you want to delete your account?',
      name: 'deleteAccountConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to sign out?`
  String get signOutConfirmation {
    return Intl.message(
      'Are you sure you want to sign out?',
      name: 'signOutConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Password reset email has been sent. Check your inbox.`
  String get resetPasswordEmailSent {
    return Intl.message(
      'Password reset email has been sent. Check your inbox.',
      name: 'resetPasswordEmailSent',
      desc: '',
      args: [],
    );
  }

  /// `No user found with this email address.`
  String get userNotFound {
    return Intl.message(
      'No user found with this email address.',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Enter the new email address twice to change it.`
  String get changeEmailDescription {
    return Intl.message(
      'Enter the new email address twice to change it.',
      name: 'changeEmailDescription',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPasswordTitle {
    return Intl.message(
      'Reset Password',
      name: 'resetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Change Email`
  String get changeEmailTitle {
    return Intl.message(
      'Change Email',
      name: 'changeEmailTitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccountTitle {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOutTitle {
    return Intl.message(
      'Sign Out',
      name: 'signOutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Habit App`
  String get appName {
    return Intl.message(
      'Habit App',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `SET YOUR HABITS`
  String get setYourHabits {
    return Intl.message(
      'SET YOUR HABITS',
      name: 'setYourHabits',
      desc: '',
      args: [],
    );
  }

  /// `Easily introduce and modify habits that will help you achieve a better version of yourself.`
  String get setYourHabitsDescription {
    return Intl.message(
      'Easily introduce and modify habits that will help you achieve a better version of yourself.',
      name: 'setYourHabitsDescription',
      desc: '',
      args: [],
    );
  }

  /// `SET REMINDERS`
  String get setReminders {
    return Intl.message(
      'SET REMINDERS',
      name: 'setReminders',
      desc: '',
      args: [],
    );
  }

  /// `With notifications, you won't forget your daily step towards a better you.`
  String get setRemindersDescription {
    return Intl.message(
      'With notifications, you won\'t forget your daily step towards a better you.',
      name: 'setRemindersDescription',
      desc: '',
      args: [],
    );
  }

  /// `TRACK YOUR PROGRESS`
  String get trackProgress {
    return Intl.message(
      'TRACK YOUR PROGRESS',
      name: 'trackProgress',
      desc: '',
      args: [],
    );
  }

  /// `Our charts and reports will help you see how you develop your habits.`
  String get trackProgressDescription {
    return Intl.message(
      'Our charts and reports will help you see how you develop your habits.',
      name: 'trackProgressDescription',
      desc: '',
      args: [],
    );
  }

  /// `READY TO GO`
  String get readyToGo {
    return Intl.message(
      'READY TO GO',
      name: 'readyToGo',
      desc: '',
      args: [],
    );
  }

  /// `You are ready to start your journey!`
  String get readyToGoDescription {
    return Intl.message(
      'You are ready to start your journey!',
      name: 'readyToGoDescription',
      desc: '',
      args: [],
    );
  }

  /// `Start now`
  String get startNow {
    return Intl.message(
      'Start now',
      name: 'startNow',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email address.`
  String get enterEmail {
    return Intl.message(
      'Please enter your email address.',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password.`
  String get enterPassword {
    return Intl.message(
      'Please enter your password.',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Email address not verified. Check your inbox.`
  String get emailNotVerified {
    return Intl.message(
      'Email address not verified. Check your inbox.',
      name: 'emailNotVerified',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email or password.`
  String get invalidEmailOrPassword {
    return Intl.message(
      'Invalid email or password.',
      name: 'invalidEmailOrPassword',
      desc: '',
      args: [],
    );
  }

  /// `User account has been disabled.`
  String get userDisabled {
    return Intl.message(
      'User account has been disabled.',
      name: 'userDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Failed to sign in with Google.`
  String get googleSignInFailed {
    return Intl.message(
      'Failed to sign in with Google.',
      name: 'googleSignInFailed',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during Google sign-in: {errorMessage}`
  String googleSignInError(Object errorMessage) {
    return Intl.message(
      'An error occurred during Google sign-in: $errorMessage',
      name: 'googleSignInError',
      desc: '',
      args: [errorMessage],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get signInWithGoogle {
    return Intl.message(
      'Sign in with Google',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Habit`
  String get editHabit {
    return Intl.message(
      'Edit Habit',
      name: 'editHabit',
      desc: '',
      args: [],
    );
  }

  /// `DELETE HABIT`
  String get deleteHabit {
    return Intl.message(
      'DELETE HABIT',
      name: 'deleteHabit',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Available from 8:00 AM to 8:00 PM`
  String get chatAvailability {
    return Intl.message(
      'Available from 8:00 AM to 8:00 PM',
      name: 'chatAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Chat with support`
  String get chatWithSupport {
    return Intl.message(
      'Chat with support',
      name: 'chatWithSupport',
      desc: '',
      args: [],
    );
  }

  /// `Chat feature will be available soon!`
  String get chatComingSoon {
    return Intl.message(
      'Chat feature will be available soon!',
      name: 'chatComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Share your feedback`
  String get feedbackHint {
    return Intl.message(
      'Share your feedback',
      name: 'feedbackHint',
      desc: '',
      args: [],
    );
  }

  /// `Submit Feedback`
  String get submitFeedback {
    return Intl.message(
      'Submit Feedback',
      name: 'submitFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Please fill out all fields`
  String get feedbackError {
    return Intl.message(
      'Please fill out all fields',
      name: 'feedbackError',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your feedback!`
  String get feedbackSuccess {
    return Intl.message(
      'Thank you for your feedback!',
      name: 'feedbackSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Nawykomat is an app designed to help build positive habits...`
  String get aboutAppDescription {
    return Intl.message(
      'Nawykomat is an app designed to help build positive habits...',
      name: 'aboutAppDescription',
      desc: '',
      args: [],
    );
  }

  /// `Open Source Licenses`
  String get openSourceLicenses {
    return Intl.message(
      'Open Source Licenses',
      name: 'openSourceLicenses',
      desc: '',
      args: [],
    );
  }

  /// `1. Introduction`
  String get privacyPolicySection1Title {
    return Intl.message(
      '1. Introduction',
      name: 'privacyPolicySection1Title',
      desc: '',
      args: [],
    );
  }

  /// `This Privacy Policy outlines the rules for processing and protecting the personal data of Nawykomat app users. We respect your privacy and are committed to protecting your personal data.`
  String get privacyPolicySection1Content {
    return Intl.message(
      'This Privacy Policy outlines the rules for processing and protecting the personal data of Nawykomat app users. We respect your privacy and are committed to protecting your personal data.',
      name: 'privacyPolicySection1Content',
      desc: '',
      args: [],
    );
  }

  /// `2. Data Controller`
  String get privacyPolicySection2Title {
    return Intl.message(
      '2. Data Controller',
      name: 'privacyPolicySection2Title',
      desc: '',
      args: [],
    );
  }

  /// `The controller of your personal data is Nawykomat Sp. z o.o. based in Warsaw, ul. Przykładowa 1, 00-001 Warsaw.`
  String get privacyPolicySection2Content {
    return Intl.message(
      'The controller of your personal data is Nawykomat Sp. z o.o. based in Warsaw, ul. Przykładowa 1, 00-001 Warsaw.',
      name: 'privacyPolicySection2Content',
      desc: '',
      args: [],
    );
  }

  /// `3. Collected Data`
  String get privacyPolicySection3Title {
    return Intl.message(
      '3. Collected Data',
      name: 'privacyPolicySection3Title',
      desc: '',
      args: [],
    );
  }

  /// `We collect the following categories of data:\n• Basic data (name, email address)\n• App usage data\n• Habit progress data\n• Device technical data`
  String get privacyPolicySection3Content {
    return Intl.message(
      'We collect the following categories of data:\n• Basic data (name, email address)\n• App usage data\n• Habit progress data\n• Device technical data',
      name: 'privacyPolicySection3Content',
      desc: '',
      args: [],
    );
  }

  /// `4. Purpose of Data Processing`
  String get privacyPolicySection4Title {
    return Intl.message(
      '4. Purpose of Data Processing',
      name: 'privacyPolicySection4Title',
      desc: '',
      args: [],
    );
  }

  /// `Your data is processed for the purpose of:\n• Providing services within the app\n• Personalizing user experience\n• Improving app functionality\n• Communicating with the user\n• Statistical analysis`
  String get privacyPolicySection4Content {
    return Intl.message(
      'Your data is processed for the purpose of:\n• Providing services within the app\n• Personalizing user experience\n• Improving app functionality\n• Communicating with the user\n• Statistical analysis',
      name: 'privacyPolicySection4Content',
      desc: '',
      args: [],
    );
  }

  /// `5. Legal Basis`
  String get privacyPolicySection5Title {
    return Intl.message(
      '5. Legal Basis',
      name: 'privacyPolicySection5Title',
      desc: '',
      args: [],
    );
  }

  /// `We process your data based on:\n• User consent\n• Contract performance\n• Legitimate interest of the controller\n• Legal obligations`
  String get privacyPolicySection5Content {
    return Intl.message(
      'We process your data based on:\n• User consent\n• Contract performance\n• Legitimate interest of the controller\n• Legal obligations',
      name: 'privacyPolicySection5Content',
      desc: '',
      args: [],
    );
  }

  /// `6. Data Storage`
  String get privacyPolicySection6Title {
    return Intl.message(
      '6. Data Storage',
      name: 'privacyPolicySection6Title',
      desc: '',
      args: [],
    );
  }

  /// `Your data is stored on secure servers with encryption. We use the latest security technologies and regularly update our security systems.`
  String get privacyPolicySection6Content {
    return Intl.message(
      'Your data is stored on secure servers with encryption. We use the latest security technologies and regularly update our security systems.',
      name: 'privacyPolicySection6Content',
      desc: '',
      args: [],
    );
  }

  /// `7. User Rights`
  String get privacyPolicySection7Title {
    return Intl.message(
      '7. User Rights',
      name: 'privacyPolicySection7Title',
      desc: '',
      args: [],
    );
  }

  /// `You have the right to:\n• Access your data\n• Rectify data\n• Delete data\n• Restrict processing\n• Data portability\n• Object to processing`
  String get privacyPolicySection7Content {
    return Intl.message(
      'You have the right to:\n• Access your data\n• Rectify data\n• Delete data\n• Restrict processing\n• Data portability\n• Object to processing',
      name: 'privacyPolicySection7Content',
      desc: '',
      args: [],
    );
  }

  /// `8. Cookies`
  String get privacyPolicySection8Title {
    return Intl.message(
      '8. Cookies',
      name: 'privacyPolicySection8Title',
      desc: '',
      args: [],
    );
  }

  /// `We use cookies and similar technologies to track activity in our app and store certain information.`
  String get privacyPolicySection8Content {
    return Intl.message(
      'We use cookies and similar technologies to track activity in our app and store certain information.',
      name: 'privacyPolicySection8Content',
      desc: '',
      args: [],
    );
  }

  /// `9. Data Sharing`
  String get privacyPolicySection9Title {
    return Intl.message(
      '9. Data Sharing',
      name: 'privacyPolicySection9Title',
      desc: '',
      args: [],
    );
  }

  /// `We do not sell or share your personal data with third parties, except as described in this policy.`
  String get privacyPolicySection9Content {
    return Intl.message(
      'We do not sell or share your personal data with third parties, except as described in this policy.',
      name: 'privacyPolicySection9Content',
      desc: '',
      args: [],
    );
  }

  /// `10. Contact`
  String get privacyPolicySection10Title {
    return Intl.message(
      '10. Contact',
      name: 'privacyPolicySection10Title',
      desc: '',
      args: [],
    );
  }

  /// `For matters related to data protection, you can contact us at: privacy@nawykomat.pl`
  String get privacyPolicySection10Content {
    return Intl.message(
      'For matters related to data protection, you can contact us at: privacy@nawykomat.pl',
      name: 'privacyPolicySection10Content',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
