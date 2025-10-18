import 'dart:ffi';

import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:get_it/get_it.dart';

import '../ffi/frb_generated.dart';

Future<void> initNative() async {
  final externalLibrary = await loadExternalLibrary(
    RustLib.kDefaultExternalLibraryLoaderConfig,
  );
  final dynamicLibrary = externalLibrary.ffiDynamicLibrary;
  GetIt.instance.registerSingleton<DynamicLibrary>(dynamicLibrary);

  createBuffer ??= dynamicLibrary.lookupFunction<
    Pointer<Uint8> Function(Int32),
    Pointer<Uint8> Function(int)
  >("create_buffer");
  releaseBuffer ??= dynamicLibrary.lookupFunction<
    Void Function(Pointer<Uint8>, Int32),
    void Function(Pointer<Uint8>, int)
  >("release_buffer");

  createFloatBuffer ??= dynamicLibrary.lookupFunction<
    Pointer<Float> Function(Int32),
    Pointer<Float> Function(int)
  >("create_float_buffer");
  releaseFloatBuffer ??= dynamicLibrary.lookupFunction<
    Void Function(Pointer<Float>, Int32),
    void Function(Pointer<Float>, int)
  >("release_float_buffer");

  await RustLib.init(externalLibrary: externalLibrary);
}

Pointer<Uint8> Function(int)? createBuffer;
void Function(Pointer<Uint8>, int)? releaseBuffer;

Pointer<Float> Function(int)? createFloatBuffer;
void Function(Pointer<Float>, int)? releaseFloatBuffer;
