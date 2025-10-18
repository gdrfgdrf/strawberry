import 'dart:convert';

import 'package:data/http/url/api_url_provider.dart';
import 'package:data/isolatepool/isolate_executor.dart';
import 'package:dio/dio.dart';
import 'package:shared/api/eapi.dart';

class CryptoInterceptor implements Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger!.error("crypto interceptor on error: $hashCode: ${err.error}\n${err.stackTrace}");
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger!.trace("crypto interceptor on request: $hashCode");

    final endpoint = options.extra["endpoint"] as Endpoint;
    var body = endpoint.body != null ? jsonEncode(endpoint.body) : null;

    if (endpoint.requiresEncryption && body != null) {
      final params = EapiParams(
        endpoint.eapiPath != null ? endpoint.eapiPath! : endpoint.path,
        body,
      );
      body = "params=${EapiCrypto.paramsEncrypt(params)}";
    }
    options.data = body;

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger!.trace("crypto interceptor on response: $hashCode");

    final requestOptions = response.requestOptions;
    if (requestOptions.responseType == ResponseType.stream) {
      handler.next(response);
      return;
    }

    final endpoint = requestOptions.extra["endpoint"] as Endpoint;
    final data = response.data;
    var processedData = data;
    var hex = EapiCrypto.bytes2hex(processedData);

    if (endpoint.requiresDecryption && processedData != null) {
      processedData = EapiCrypto.dataDecrypt(hex);
    }

    final processedResponse = Response(
      data: processedData,
      requestOptions: requestOptions,
    );
    handler.next(processedResponse);
  }
}
