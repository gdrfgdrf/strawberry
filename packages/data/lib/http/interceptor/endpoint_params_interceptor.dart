

import 'package:data/http/url/api_url_provider.dart';
import 'package:dio/dio.dart';

import '../../isolatepool/isolate_executor.dart';

class EndpointParamsInterceptor implements Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger!.error("endpoint params interceptor on error: $hashCode: ${err.error}\n${err.stackTrace}");
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger!.trace("endpoint params interceptor on request: $hashCode");

    final headers = options.headers;
    final endpoint = options.extra["endpoint"] as Endpoint;

    if (endpoint.headers != null) {
      headers.addAll(endpoint.headers!);
    }
    if (endpoint.userAgent != null) {
      headers["User-Agent"] = endpoint.userAgent!;
    }
    if (endpoint.contentType != null) {
      options.contentType = endpoint.contentType;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    logger!.trace("endpoint params interceptor on response: $hashCode");
    handler.next(response);
  }

}