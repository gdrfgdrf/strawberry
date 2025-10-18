import 'dart:async';
import 'dart:convert';

import 'package:data/http/repository/exception/api_service_exception.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/entity/account_entity.dart';
import 'package:domain/entity/anonimous_entity.dart';
import 'package:domain/entity/login_result.dart';
import 'package:domain/hives.dart';
import 'package:domain/repository/auth_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared/api/device.dart';

class AuthRepositoryImpl extends AbstractAuthRepository {
  @override
  Future<AnonimousEntity> registerAnonimous(String deviceId) {
    final completer = Completer<AnonimousEntity>();
    final endpoint = GetIt.instance.get<UrlProvider>().registerAnonimous(
      deviceId: deviceId,
    );
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

          final result = AnonimousEntity.parseJson(response);
          completer.complete(result);
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }

  @override
  Future<LoginResult> loginCellphoneDesktop(
    String countryCode,
    String appVer,
    String deviceId,
    String requestId,
    ClientSign clientSign,
    String osVer,
    String cellphone,
    String password,
  ) {
    final completer = Completer<LoginResult>();
    final endpoint = GetIt.instance
        .get<UrlProvider>()
        .userLoginCellphoneDesktop(
          countryCode: countryCode,
          appVer: appVer,
          deviceId: deviceId,
          requestId: requestId,
          clientSign: clientSign,
          osVer: osVer,
          cellphone: cellphone,
          password: password,
        );
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
          final loginResult = LoginResult.parseJson(response);

          final account = loginResult.account;
          final profile = loginResult.profile;
          GetIt.instance.registerSingleton<Account>(account);
          GetIt.instance.registerSingleton<Profile>(profile);

          final box = Hive.box<LoginResult>(HiveBoxes.loginResult);
          box.put(profile.userId, loginResult);

          completer.complete(loginResult);
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }

  @override
  Future<void> refreshToken_Type1(int id) {
    final completer = Completer<void>();
    final endpoint = GetIt.instance.get<UrlProvider>().refreshToken_Type1();
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

          final box = Hive.box<LoginResult>(HiveBoxes.loginResult);
          final loginResult = box.get(id);
          if (loginResult == null) {
            final exception = ApiServiceException("login result is null");
            completer.completeError(exception);
            return;
          }

          GetIt.instance.registerSingleton<Account>(loginResult.account);
          GetIt.instance.registerSingleton<Profile>(loginResult.profile);

          completer.complete();
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }

  @override
  Future<String> refreshToken_Type2(int id) {
    final completer = Completer<String>();
    final endpoint = GetIt.instance.get<UrlProvider>().refreshToken_Type2();
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

          final dataInResponse = parsedResponse["data"];
          final message = dataInResponse["message"];

          completer.complete(message);
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }
}
