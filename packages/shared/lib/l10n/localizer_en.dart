// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizer.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LocalizerEn extends Localizer {
  LocalizerEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Retry';

  @override
  String get username_here => 'Username';

  @override
  String get email_here => 'Email';

  @override
  String get cellphone_here => 'Cellphone';

  @override
  String get password_here => 'Password';

  @override
  String get argument_error => 'Argument error';

  @override
  String get login_preparation_error =>
      'An error occurred when preparing the parameters required for login';

  @override
  String get cellphone_login_not_available =>
      'Cellphone login is not available on your platform';

  @override
  String get use_cloudmusic_app_to_scan => 'Scanning with the CloudMusic App';

  @override
  String get qr_code_authorizing => 'Authorizing';

  @override
  String qr_code_error(String message) {
    return 'Login error, Please check the CloudMusic App: $message';
  }

  @override
  String get get_user_detail_failed => 'Obtain user information failed';

  @override
  String login_failed(String reason) {
    return 'Login failed: $reason';
  }

  @override
  String username(String username) {
    return '$username';
  }

  @override
  String get goto_profile_page => 'Profile Page';

  @override
  String get fan_count => 'Fans';

  @override
  String get follow_count => 'Follows';

  @override
  String get event_count => 'Events';

  @override
  String get play_count => 'Play';

  @override
  String get create_time => 'Create Time';

  @override
  String get update_time => 'Update Time';
}
