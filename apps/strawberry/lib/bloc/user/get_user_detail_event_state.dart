
import 'package:domain/entity/account_entity.dart';
import 'package:domain/result/result.dart';
import 'package:pair/pair.dart';

import 'user_bloc.dart';

/// 该类型返回体中，没有 Account，有完整 Profile，
/// https://interface.music.163.com/eapi/w/v1/user/detail/account.id
class AttemptGetUserDetailEvent_Type1 extends UserEvent {
  final bool isLogin;
  final int userId;

  AttemptGetUserDetailEvent_Type1(this.userId, {this.isLogin = false});
}

/// 该类型返回体中，有完整 Account，有不完整 Profile，Profile 中没有粉丝数，关注数，需要登录后才能调用
/// http://interface.music.163.com/eapi/w/nuser/account/get
class AttemptGetUserDetailEvent_Type2 extends UserEvent {
  final bool isLogin;

  AttemptGetUserDetailEvent_Type2({this.isLogin = false});
}

class GetUserDetailSuccess_Type1 extends UserState {
  final Profile profile;

  GetUserDetailSuccess_Type1(this.profile);
}

class GetUserDetailSuccess_Type2 extends UserState {
  /// account and incomplete profile json
  final Pair<Account, String> pair;

  GetUserDetailSuccess_Type2(this.pair);
}