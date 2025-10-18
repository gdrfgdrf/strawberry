// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizer.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class LocalizerZh extends Localizer {
  LocalizerZh([String locale = 'zh']) : super(locale);

  @override
  String get retry => '重试';

  @override
  String get username_here => '用户名';

  @override
  String get email_here => '邮箱';

  @override
  String get cellphone_here => '手机号';

  @override
  String get password_here => '密码';

  @override
  String get argument_error => '参数错误';

  @override
  String get login_preparation_error => '准备登录所需参数时发生错误';

  @override
  String get cellphone_login_not_available => '您的平台无法使用手机号登录';

  @override
  String get use_cloudmusic_app_to_scan => '请使用网易云 App 扫码登录';

  @override
  String get qr_code_authorizing => '授权中';

  @override
  String qr_code_error(String message) {
    return '登录异常，请前往网易云 App 查看: $message';
  }

  @override
  String get get_user_detail_failed => '获取用户信息失败';

  @override
  String login_failed(String reason) {
    return '登录失败: $reason';
  }

  @override
  String username(String username) {
    return '$username';
  }

  @override
  String get goto_profile_page => '个人页面';

  @override
  String get fan_count => '粉丝数';

  @override
  String get follow_count => '关注数';

  @override
  String get event_count => '动态数';

  @override
  String get play_count => '播放量';

  @override
  String get create_time => '创建时间';

  @override
  String get update_time => '更新时间';
}
