import 'dart:async';
import 'dart:convert';

import 'package:data/http/repository/exception/api_service_exception.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/entity/account_entity.dart';
import 'package:domain/entity/login_result.dart';
import 'package:domain/hives.dart';
import 'package:domain/repository/user/user_detail_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:pair/pair.dart';

class UserDetailRepositoryImpl extends AbstractUserDetailRepository {
  @override
  Future<Profile> type1(int userId, {bool isLogin = false}) {
    final completer = Completer<Profile>();
    final endpoint = GetIt.instance.get<UrlProvider>().userDetail_Type1(userId);
    final taskStream = TaskChain();

    taskStream
        .stringNetwork(() => endpoint)
        .onComplete((response, _) {
          final parsedResponse = jsonDecode(response);

          if (parsedResponse["code"] != 200) {
            final exception = ApiServiceException(
              parsedResponse["message"] ?? parsedResponse.toString(),
            );
            completer.completeError(exception);
            return;
          }
          final profileJson = jsonEncode(parsedResponse["profile"]);
          final profile = Profile.parseJson_Type1(profileJson);

          if (isLogin) {
            if (!GetIt.instance.isRegistered<Profile>()) {
              GetIt.instance.registerSingleton<Profile>(profile);
            }

            final account = GetIt.instance.get<Account>();
            final loginResult = LoginResult(account, profile);

            final box = Hive.box<LoginResult>(HiveBoxes.loginResult);
            box.put(userId, loginResult);
          }

          completer.complete(profile);
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }

  @override
  Future<Pair<Account, String>> type2({bool isLogin = false}) {
    final completer = Completer<Pair<Account, String>>();
    final endpoint = GetIt.instance.get<UrlProvider>().userDetail_Type2();
    final taskStream = TaskChain();

    taskStream
        .stringNetwork(() => endpoint)
        .onComplete((response, _) {
          final parsedResponse = jsonDecode(response);

          if (parsedResponse["code"] != 200) {
            final exception = ApiServiceException(
              parsedResponse["message"] ?? parsedResponse.toString(),
            );
            completer.completeError(exception);
            return;
          }

          final accountJson = jsonEncode(parsedResponse["account"]);
          final profileJson = jsonEncode(parsedResponse["profile"]);
          final account = Account.parseJson(accountJson);

          if (isLogin) {
            if (!GetIt.instance.isRegistered<Account>()) {
              GetIt.instance.registerSingleton<Account>(account);
            }
          }

          completer.complete(Pair(account, profileJson));
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }
}
