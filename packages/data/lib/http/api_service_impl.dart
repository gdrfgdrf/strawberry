import 'dart:convert';
import 'dart:typed_data';

import 'package:data/http/api_service.dart';
import 'package:data/http/url/api_url_provider.dart';
import 'package:dio/dio.dart';

class ApiServiceImpl extends ApiService {
  String smartBaseUrl(Endpoint endpoint) {
    if (endpoint.baseUrl != null) {
      return endpoint.baseUrl!;
    }
    return baseUrl;
  }

  @override
  Future<dynamic> get(Endpoint endpoint) async {
    final response = await dio.get(
      endpoint.buildUrl(smartBaseUrl(endpoint)),
      options: Options(extra: {"endpoint": endpoint}),
    );
    try {
      return response.data.runtimeType.toString() == "Uint8List"
          ? utf8.decode(response.data)
          : response.data;
    } catch (e, s) {
      return response.data;
    }
  }

  @override
  Future<Stream<Uint8List>?> getStream(Endpoint endpoint) async {
    final body = await dio.get<ResponseBody>(
      endpoint.buildUrl(smartBaseUrl(endpoint)),
      options: Options(
        sendTimeout: Duration(seconds: 10),
        extra: {"endpoint": endpoint},
        responseType: ResponseType.stream,
      ),
    );
    final data = body.data!;
    return data.stream;
  }

  @override
  Future<dynamic> post(Endpoint endpoint) async {
    final response = await dio.post(
      endpoint.buildUrl((smartBaseUrl(endpoint))),
      options: Options(
        extra: {"endpoint": endpoint},
        sendTimeout: Duration(seconds: 10),
      ),
    );
    try {
      return response.data.runtimeType.toString() == "Uint8List"
          ? utf8.decode(response.data)
          : response.data;
    } catch (e, s) {
      return response.data;
    }
  }

  @override
  Future<Stream<Uint8List>?> postStream(Endpoint endpoint) async {
    final body = await dio.post<ResponseBody>(
      endpoint.buildUrl(smartBaseUrl(endpoint)),
      options: Options(
        extra: {"endpoint": endpoint},
        responseType: ResponseType.stream,
        sendTimeout: Duration(seconds: 10),
      ),
    );
    return body.data?.stream;
  }

  @override
  Future<dynamic> put(Endpoint endpoint) async {
    final response = await dio.put(
      endpoint.buildUrl((smartBaseUrl(endpoint))),
      options: Options(
        extra: {"endpoint": endpoint},
        sendTimeout: Duration(seconds: 10),
      ),
    );
    try {
      return response.data.runtimeType.toString() == "Uint8List"
          ? utf8.decode(response.data)
          : response.data;
    } catch (e, s) {
      return response.data;
    }
  }

  @override
  Future<Stream<Uint8List>?> putStream(Endpoint endpoint) async {
    final body = await dio.put<ResponseBody>(
      endpoint.buildUrl(smartBaseUrl(endpoint)),
      options: Options(
        extra: {"endpoint": endpoint},
        responseType: ResponseType.stream,
      ),
    );
    return body.data?.stream;
  }

  @override
  Future<dynamic> delete(Endpoint endpoint) async {
    final response = await dio.delete(
      endpoint.buildUrl((smartBaseUrl(endpoint))),
      options: Options(extra: {"endpoint": endpoint}),
    );
    try {
      return response.data.runtimeType.toString() == "Uint8List"
          ? utf8.decode(response.data)
          : response.data;
    } catch (e, s) {
      return response.data;
    }
  }

  @override
  Future<Stream<Uint8List>?> deleteStream(Endpoint endpoint) async {
    final body = await dio.delete<ResponseBody>(
      endpoint.buildUrl(smartBaseUrl(endpoint)),
      options: Options(
        extra: {"endpoint": endpoint},
        responseType: ResponseType.stream,
      ),
    );
    return body.data?.stream;
  }
}
