import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:data/http/interceptor/crypto_interceptor.dart';
import 'package:data/http/interceptor/endpoint_params_interceptor.dart';
import 'package:data/isolatepool/isolate_executor.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:domain/entity/song_quality_entity.dart';
import 'package:shared/api/device.dart';

import '../../isolatepool/isolate_pool_bean.dart';

abstract class UrlProvider {
  String get baseUrl;

  Endpoint registerAnonimous({required String deviceId});

  Endpoint userLoginEmail({required String email, required String password});

  Endpoint userLoginCellphoneDesktop({
    required String countryCode,
    required String appVer,
    required String deviceId,
    required String requestId,
    required ClientSign clientSign,
    required String osVer,
    required String cellphone,
    required String password,
  });

  Endpoint userLoginQrCodeGetUniKey();

  Endpoint userLoginQrCode(String uniKey);

  Endpoint refreshToken_Type1();

  Endpoint refreshToken_Type2();

  Endpoint userDetail_Type1(int userId);

  Endpoint userDetail_Type2();

  Endpoint playlists(int userId);

  Endpoint playlistQuery(int id, int songCount);

  Endpoint songDetails(List<int> ids);

  Endpoint songPlayerFiles(
    List<int> ids,
    SongQualityLevel level, {
    List<String> effects = const [],
    String? encodeType,
  });

  Endpoint songLyric(int id);

  Endpoint songLike(int id, bool like);
}

class UrlManager {
  UrlProvider? _provider;
  Dio? dio;
  String? baseUrl;

  void setProvider(UrlProvider provider) {
    _provider = provider;
  }

  void init(Map<String, dynamic> customHeaders, CookieJar cookieJar) {
    baseUrl = _provider!.baseUrl;
    logger!.info("initializing dio, base url: $baseUrl");

    dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 60),
        contentType: "application/x-www-form-urlencoded",
        responseType: ResponseType.bytes,
        headers: customHeaders,
      ),
    );

    dio!.interceptors.addAll([
      CookieManager(cookieJar),
      EndpointParamsInterceptor(),
      CryptoInterceptor(),
    ]);

    (dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: 10);
      // client.findProxy = (uri) {
      //   return "PROXY localhost:8080";
      // };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }
}

enum HttpMethod { get, post, put, delete }

class Endpoint {
  final String path;
  final String? eapiPath;

  final String? baseUrl;
  final HttpMethod method;

  final bool requiresEncryption;
  final bool requiresDecryption;

  final Map<String, dynamic>? pathParams;
  final Map<String, dynamic>? queryParams;

  final Map<String, dynamic>? headers;
  final String? userAgent;
  final dynamic body;
  final String? contentType;

  const Endpoint({
    required this.path,
    this.eapiPath,
    this.baseUrl,
    required this.method,
    this.requiresEncryption = false,
    this.requiresDecryption = false,
    this.pathParams,
    this.queryParams,
    this.headers,
    this.userAgent,
    this.body,
    this.contentType,
  });

  String buildUrl(String baseUrl) {
    String url = '$baseUrl$path';

    if (pathParams != null) {
      pathParams!.forEach((key, value) {
        final encodedValue = Uri.encodeComponent(value.toString());
        url = url.replaceAll(':$key', encodedValue);
      });
    }

    if (queryParams != null && queryParams!.isNotEmpty) {
      final queryString = queryParams!.entries
          .map(
            (e) =>
                '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}',
          )
          .join('&');
      url += '?$queryString';
    }

    return url;
  }

  Map<String, dynamic> get params => {...?pathParams, ...?queryParams};

  static Endpoint get({
    required String path,
    String? eapiPath,
    String? baseUrl,
    bool requiresEncryption = false,
    bool requiresDecryption = false,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? userAgent,
    dynamic body,
    bool Function(Map<String, dynamic> params)? validator,
  }) {
    return Endpoint(
      path: path,
      eapiPath: eapiPath,
      baseUrl: baseUrl,
      method: HttpMethod.get,
      requiresEncryption: requiresEncryption,
      requiresDecryption: requiresDecryption,
      pathParams: pathParams,
      queryParams: queryParams,
      headers: headers,
      userAgent: userAgent,
      body: body,
    );
  }

  static Endpoint post({
    required String path,
    String? eapiPath,
    String? baseUrl,
    bool requiresEncryption = false,
    bool requiresDecryption = false,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? userAgent,
    dynamic body,
    String contentType = "application/x-www-form-urlencoded",
    bool Function(Map<String, dynamic> params)? validator,
  }) {
    return Endpoint(
      path: path,
      eapiPath: eapiPath,
      baseUrl: baseUrl,
      method: HttpMethod.post,
      requiresEncryption: requiresEncryption,
      requiresDecryption: requiresDecryption,
      pathParams: pathParams,
      queryParams: queryParams,
      headers: headers,
      userAgent: userAgent,
      body: body,
      contentType: contentType,
    );
  }

  static Endpoint put({
    required String path,
    String? eapiPath,
    String? baseUrl,
    bool requiresAuth = false,
    bool requiresEncryption = false,
    bool requiresDecryption = false,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    String? userAgent,
    dynamic body,
    String contentType = "application/x-www-form-urlencoded",
    bool Function(Map<String, dynamic> params)? validator,
  }) {
    return Endpoint(
      path: path,
      eapiPath: eapiPath,
      baseUrl: baseUrl,
      method: HttpMethod.put,
      requiresEncryption: requiresEncryption,
      requiresDecryption: requiresDecryption,
      pathParams: pathParams,
      queryParams: queryParams,
      headers: headers,
      userAgent: userAgent,
      body: body,
      contentType: contentType,
    );
  }

  static Endpoint readBuffer(Uint8List buffer) {
    final reader = BufferReader(buffer);

    final path = reader.readString();
    final eapiPath = reader.readNullableString();
    final baseUrl = reader.readNullableString();
    final method = reader.readEnum(HttpMethod.values);
    final requiresEncryption = reader.readBool();
    final requiresDecryption = reader.readBool();
    final pathParams = reader.readNullableJson();
    final queryParams = reader.readNullableJson();
    final headers = reader.readNullableJson();
    final userAgent = reader.readNullableString();
    final body = reader.readNullableJson();
    final contentType = reader.readNullableString();

    return Endpoint(
      path: path,
      method: method,
      eapiPath: eapiPath,
      baseUrl: baseUrl,
      requiresEncryption: requiresEncryption,
      requiresDecryption: requiresDecryption,
      pathParams: pathParams,
      queryParams: queryParams,
      headers: headers,
      userAgent: userAgent,
      body: body,
      contentType: contentType,
    );
  }

  Uint8List writeBuffer() {
    final writer = BufferWriter();
    writer.writeString(path);
    writer.writeNullableString(eapiPath);
    writer.writeNullableString(baseUrl);
    writer.writeEnum(method);
    writer.writeBool(requiresEncryption);
    writer.writeBool(requiresDecryption);
    writer.writeNullableJson(pathParams);
    writer.writeNullableJson(queryParams);
    writer.writeNullableJson(headers);
    writer.writeNullableString(userAgent);
    writer.writeNullableJson(body);
    writer.writeNullableString(contentType);

    return writer.takeBytes();
  }
}
