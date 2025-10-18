import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:data/center/cookie_center.dart';
import 'package:data/isolatepool/isolate_executor.dart';
import 'package:data/isolatepool/stream/task_stream.dart';
import 'package:domain/result/result.dart';
import 'package:get_it/get_it.dart';
import 'package:shared/configuration/desktop_config.dart';
import 'package:shared/configuration/general_config.dart';

import '../../http/api_service.dart';
import '../../http/api_service_impl.dart';
import '../../http/url/api_url_provider.dart';
import '../../http/url/api_url_provider_impl.dart';
import '../isolate_pool_bean.dart';

class NetworkInitParam {
  final Map<String, dynamic> customHeaders;
  final DesktopConfig desktopConfig;

  const NetworkInitParam(this.customHeaders, this.desktopConfig);

  static NetworkInitParam readBuffer(Uint8List buffer) {
    final reader = BufferReader(buffer);

    final customHeaders = reader.readJson();
    final desktopConfig = DesktopConfig.parseJson(
      jsonEncode(reader.readJson()),
    );

    return NetworkInitParam(customHeaders, desktopConfig);
  }

  Uint8List writeBuffer() {
    final writer = BufferWriter();
    writer.writeJson(customHeaders);
    writer.writeJson(desktopConfig.toJson());

    return writer.takeBytes();
  }
}

NetworkInitParam buildNetworkInitParam() {
  final generalConfig = GetIt.instance.get<GeneralConfig>();
  final desktopConfig = GetIt.instance.get<DesktopConfig>();
  final customHeaders = <String, dynamic>{
    "User-Agent": generalConfig.userAgent,
  };
  customHeaders.addAll(generalConfig.customHeaders);
  return NetworkInitParam(customHeaders, desktopConfig);
}

void isolateInitNetwork(
  NetworkInitParam initParam,
) async {
  logger!.info("initializing network");

  final getIt = GetIt.instance;

  logger!.trace("configuring api service singleton");
  getIt.registerLazySingleton<ApiService>(() => ApiServiceImpl());

  logger!.trace("configuring url manager singleton");
  getIt.registerLazySingleton<UrlManager>(() {
    final manager = UrlManager();
    manager.setProvider(UrlProviderImpl());
    manager.init(initParam.customHeaders, CookieCenter.instance);
    return manager;
  });
}

void processStreamNetworkTask(String id, Endpoint endpoint, SendPort sendPort) async {
  final apiService = GetIt.instance.get<ApiService>();
  final String baseUrl;
  Stream<Uint8List>? result;

  if (endpoint.baseUrl?.isNotEmpty == true) {
    baseUrl = endpoint.baseUrl!;
  } else {
    baseUrl = apiService.baseUrl;
  }

  logger!.trace("stream task id: $id, ${endpoint.method}: ${endpoint.buildUrl(baseUrl)}");
  switch (endpoint.method) {
    case HttpMethod.get:
      {
        result = await apiService.getStream(endpoint);
      }
    case HttpMethod.post:
      {
        result = await apiService.postStream(endpoint);
      }
    case HttpMethod.delete:
      {
        result = await apiService.deleteStream(endpoint);
      }
    case HttpMethod.put:
      {
        result = await apiService.putStream(endpoint);
      }
  }

  if (result != null) {
    result.listen((data) {
      sendPort.send(TransferableTypedData.fromList([data]));
    }, onDone: () {
      sendPort.send(StreamEndSignal(null));
    }, onError: (e, s) {
      sendPort.send(StreamEndSignal(Failure(e, s)));
    });
  }
}

Future<Uint8List?> processNetworkTask(String id, Endpoint endpoint) async {
  final apiService = GetIt.instance.get<ApiService>();
  final String baseUrl;
  final result;

  if (endpoint.baseUrl?.isNotEmpty == true) {
    baseUrl = endpoint.baseUrl!;
  } else {
    baseUrl = apiService.baseUrl;
  }

  logger!.trace("task id: $id, ${endpoint.method}: ${endpoint.buildUrl(baseUrl)}");
  switch (endpoint.method) {
    case HttpMethod.get:
      {
        result = await apiService.get(endpoint);
      }
    case HttpMethod.post:
      {
        result = await apiService.post(endpoint);
      }
    case HttpMethod.delete:
      {
        result = await apiService.delete(endpoint);
      }
    case HttpMethod.put:
      {
        result = await apiService.put(endpoint);
      }
  }

  if (result is String) {
    return utf8.encode(result);
  }
  return result;
}
