
import 'package:dartz/dartz.dart';
import 'package:pair/pair.dart';

import '../../entity/account_entity.dart';

abstract class AbstractUserDetailRepository {
  Future<Profile> type1(int userId, {bool isLogin = false});
  Future<Pair<Account, String>> type2({bool isLogin = false});


}