
import 'package:strawberry/bloc/auth/auth_bloc.dart';

/// 请求 https://interface.music.163.com/eapi/login/token/refresh params = /api/login/token/refresh + authBody(checkToken and X-antiCheatToken) also X-antiCheatToken in cookies
/// 返回 成功: {"bizCode":"201","code":200}
/// 返回 失败: {"msg":null,"code":301,"message":null}
/// 当返回失败时，将请求 Type 2
class AttemptRefreshTokenEvent_Type1 extends AuthEvent {
  final int id;

  AttemptRefreshTokenEvent_Type1(this.id);
}

/// 当请求到此处时，都要重新登录
/// 请求 https://interface3.music.163.com/eapi/middle/account/token/refresh params = /api/middle/account/token/refresh + body(extraHeader: Nm-GCore-Status: "1")
/// 返回 失败 1: {"code":200,"data":{"tokenEmpty":false,"action":1,"jumpUrl":null,"message":"","followAction":null},"message":""}
/// 返回 失败 2: {"code":200,"data":{"tokenEmpty":false,"action":2,"jumpUrl":null,"message":"你的设备已被移除登录，如果不是你本人操作，账号可能已经被盗，请尽快重新登录并修改密码或修改绑定信息，避免产生资金损失。","followAction":null},"message":""}
/// 若该请求失败，则退出登录
class AttemptRefreshTokenEvent_Type2 extends AuthEvent {
  final int id;

  AttemptRefreshTokenEvent_Type2(this.id);
}

class RefreshTokenSuccess_Type1 extends AuthState {
  RefreshTokenSuccess_Type1();
}

class RefreshTokenSuccess_Type2 extends AuthState {
  final String message;

  RefreshTokenSuccess_Type2(this.message);
}