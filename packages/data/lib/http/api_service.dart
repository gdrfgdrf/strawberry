import 'dart:typed_data';

import 'package:data/http/url/api_url_provider.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

abstract class ApiService {
  final Dio dio = GetIt.instance.get<UrlManager>().dio!;
  final String baseUrl = GetIt.instance.get<UrlManager>().baseUrl!;

  Future<dynamic> get(Endpoint endpoint);

  Future<Stream<Uint8List>?> getStream(Endpoint endpoint);

  Future<dynamic> post(Endpoint endpoint);

  Future<Stream<Uint8List>?> postStream(Endpoint endpoint);

  Future<dynamic> put(Endpoint endpoint);

  Future<Stream<Uint8List>?> putStream(Endpoint endpoint);

  Future<dynamic> delete(Endpoint endpoint);

  Future<Stream<Uint8List>?> deleteStream(Endpoint endpoint);
}
