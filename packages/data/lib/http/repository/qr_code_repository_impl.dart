import 'dart:async';
import 'dart:convert';

import 'package:data/http/repository/exception/api_service_exception.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/task_chain.dart';
import 'package:domain/entity/login_result.dart';
import 'package:domain/repository/qr_code_repository.dart';
import 'package:get_it/get_it.dart';

class QrCodeRepositoryImpl extends AbstractQrCodeRepository {
  @override
  Future<String> getUniKey() {
    final completer = Completer<String>();
    final endpoint =
        GetIt.instance.get<UrlProvider>().userLoginQrCodeGetUniKey();
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

          completer.complete(parsedResponse["unikey"]);
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }

  @override
  Future<QrCodeResult> tryLogin(String uniKey) {
    final completer = Completer<QrCodeResult>();
    final endpoint = GetIt.instance.get<UrlProvider>().userLoginQrCode(uniKey);
    final taskStream = TaskChain();

    taskStream
        .stringNetwork(() => endpoint)
        .onComplete((response, _) {
          completer.complete(QrCodeResult.parseJson(response));
        })
        .globalOnError((_, e, s) => completer.completeError(e, s))
        .run();

    return completer.future;
  }
}
