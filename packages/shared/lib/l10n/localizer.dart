import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizer_en.dart';
import 'localizer_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of Localizer
/// returned by `Localizer.of(context)`.
///
/// Applications need to include `Localizer.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/localizer.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Localizer.localizationsDelegates,
///   supportedLocales: Localizer.supportedLocales,
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
/// be consistent with the languages listed in the Localizer.supportedLocales
/// property.
abstract class Localizer {
  Localizer(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Localizer? of(BuildContext context) {
    return Localizations.of<Localizer>(context, Localizer);
  }

  static const LocalizationsDelegate<Localizer> delegate = _LocalizerDelegate();

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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @username_here.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username_here;

  /// No description provided for @email_here.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_here;

  /// No description provided for @cellphone_here.
  ///
  /// In en, this message translates to:
  /// **'Cellphone'**
  String get cellphone_here;

  /// No description provided for @password_here.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_here;

  /// No description provided for @argument_error.
  ///
  /// In en, this message translates to:
  /// **'Argument error'**
  String get argument_error;

  /// No description provided for @login_preparation_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred when preparing the parameters required for login'**
  String get login_preparation_error;

  /// No description provided for @cellphone_login_not_available.
  ///
  /// In en, this message translates to:
  /// **'Cellphone login is not available on your platform'**
  String get cellphone_login_not_available;

  /// No description provided for @use_cloudmusic_app_to_scan.
  ///
  /// In en, this message translates to:
  /// **'Scanning with the CloudMusic App'**
  String get use_cloudmusic_app_to_scan;

  /// No description provided for @qr_code_authorizing.
  ///
  /// In en, this message translates to:
  /// **'Authorizing'**
  String get qr_code_authorizing;

  /// qr code login error
  ///
  /// In en, this message translates to:
  /// **'Login error, Please check the CloudMusic App: {message}'**
  String qr_code_error(String message);

  /// No description provided for @get_user_detail_failed.
  ///
  /// In en, this message translates to:
  /// **'Obtain user information failed'**
  String get get_user_detail_failed;

  /// login failed reason
  ///
  /// In en, this message translates to:
  /// **'Login failed: {reason}'**
  String login_failed(String reason);

  /// Username
  ///
  /// In en, this message translates to:
  /// **'{username}'**
  String username(String username);

  /// No description provided for @goto_profile_page.
  ///
  /// In en, this message translates to:
  /// **'Profile Page'**
  String get goto_profile_page;

  /// No description provided for @fan_count.
  ///
  /// In en, this message translates to:
  /// **'Fans'**
  String get fan_count;

  /// No description provided for @follow_count.
  ///
  /// In en, this message translates to:
  /// **'Follows'**
  String get follow_count;

  /// No description provided for @event_count.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get event_count;

  /// No description provided for @play_count.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play_count;

  /// No description provided for @create_time.
  ///
  /// In en, this message translates to:
  /// **'Create Time'**
  String get create_time;

  /// No description provided for @update_time.
  ///
  /// In en, this message translates to:
  /// **'Update Time'**
  String get update_time;
}

class _LocalizerDelegate extends LocalizationsDelegate<Localizer> {
  const _LocalizerDelegate();

  @override
  Future<Localizer> load(Locale locale) {
    return SynchronousFuture<Localizer>(lookupLocalizer(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_LocalizerDelegate old) => false;
}

Localizer lookupLocalizer(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LocalizerEn();
    case 'zh':
      return LocalizerZh();
  }

  throw FlutterError(
    'Localizer.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
