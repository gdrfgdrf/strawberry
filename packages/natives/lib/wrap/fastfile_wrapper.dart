import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:get_it/get_it.dart';
import 'package:natives/wrap/native_loader.dart';

typedef open_map32_c =
    Uint64 Function(Pointer<Uint8> path_ptr, Uint32 path_len);
typedef open_map64_c =
    Uint64 Function(Pointer<Uint8> path_ptr, Uint64 path_len);
typedef open_map_dart = int Function(Pointer<Uint8> path_ptr, int path_len);

typedef get_map_ptr32_c =
    Pointer<Uint8> Function(Uint64 handle, Pointer<Uint32> out_len);
typedef get_map_ptr64_c =
    Pointer<Uint8> Function(Uint64 handle, Pointer<Uint64> out_len);
typedef get_map_ptr32_dart =
    Pointer<Uint8> Function(int handle, Pointer<Uint32> out_len);
typedef get_map_ptr64_dart =
    Pointer<Uint8> Function(int handle, Pointer<Uint64> out_len);

typedef close_map_c = Void Function(Uint64 handle);
typedef close_map_dart = void Function(int handle);

class DartFastFile {
  final String path;

  NativeMappedFile? nativeMappedFile;
  Uint8List? copiedData;
  bool closed = false;

  DartFastFile(this.path);

  void scope(void Function(Uint8List) inner) {
    open();
    inner(asUint8ListView());
    close();
  }

  void open() {
    if (closed) {
      throw Exception("this mapped file is closed");
    }

    final handle = NativeFastFile.openMap(path);
    final nativeMappedFile = NativeFastFile.getMapPtr(handle);
    if (nativeMappedFile.dataPointer == nullptr ||
        nativeMappedFile.length <= 0) {
      return;
    }

    this.nativeMappedFile = nativeMappedFile;
  }

  Uint8List asUint8ListView() {
    if (copiedData != null) {
      return copiedData!;
    }
    if (nativeMappedFile == null) {
      throw Exception("the file is not opened");
    }
    if (closed) {
      throw Exception("this mapped file is closed");
    }
    final pointer = nativeMappedFile!.dataPointer;
    final length = nativeMappedFile!.length;
    return pointer.asTypedList(length);
  }

  Uint8List copy() {
    if (nativeMappedFile == null) {
      throw Exception("the file is not opened");
    }
    if (this.copiedData != null) {
      return this.copiedData!;
    }
    final pointer = nativeMappedFile!.dataPointer;
    final length = nativeMappedFile!.length;
    final copiedData = <int>[];

    copiedData.addAll(pointer.asTypedList(length));
    close();

    this.copiedData = Uint8List.fromList(copiedData);
    return this.copiedData!;
  }

  void close() {
    if (!closed) {
      closed = true;

      if (nativeMappedFile == null) {
        return;
      }
      NativeFastFile.closeMap(nativeMappedFile!.handle);
    }
  }
}

class NativeMappedFile {
  final int handle;
  final Pointer<Uint8> dataPointer;
  final int length;

  NativeMappedFile(this.handle, this.dataPointer, this.length) {
    if (dataPointer == nullptr || length <= 0) {
      NativeFastFile.closeMap(handle);
    }
  }
}

class NativeFastFile {
  static open_map_dart? _openMap;

  static get_map_ptr32_dart? _getMapPtr32;
  static get_map_ptr64_dart? _getMapPtr64;

  static close_map_dart? _closeMap;

  static int openMap(String path) {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    final bytes = utf8.encode(path);
    final pointer = createBuffer!(bytes.length);
    pointer.asTypedList(bytes.length).setAll(0, bytes);

    final handle = _openMap!(pointer, bytes.length);
    releaseBuffer!(pointer, bytes.length);

    return handle;
  }

  static NativeMappedFile getMapPtr(int handle) {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    if (is64bit()) {
      final out = malloc<Uint64>();
      final dataPointer = _getMapPtr64!(handle, out);
      final length = out.value;
      malloc.free(out);
      return NativeMappedFile(handle, dataPointer, length);
    }

    final out = malloc<Uint32>();
    final dataPointer = _getMapPtr32!(handle, out);
    final length = out.value;
    malloc.free(out);
    return NativeMappedFile(handle, dataPointer, length);
  }

  static closeMap(int handle) {
    final library = GetIt.instance.get<DynamicLibrary>();
    findFunctions(library);

    _closeMap!(handle);
  }

  static void findFunctions(DynamicLibrary library) {
    if (is64bit()) {
      _openMap ??= library.lookupFunction<open_map64_c, open_map_dart>(
        "open_map64",
      );
      _getMapPtr64 ??= library
          .lookupFunction<get_map_ptr64_c, get_map_ptr64_dart>("get_map_ptr64");
      _closeMap ??= library.lookupFunction<close_map_c, close_map_dart>(
        "close_map",
      );
    } else {
      _openMap ??= library.lookupFunction<open_map32_c, open_map_dart>(
        "open_map32",
      );
      _getMapPtr32 ??= library
          .lookupFunction<get_map_ptr32_c, get_map_ptr32_dart>("get_map_ptr32");
      _closeMap ??= library.lookupFunction<close_map_c, close_map_dart>(
        "close_map",
      );
    }
  }

  static bool is64bit() {
    return sizeOf<IntPtr>() != 4;
  }
}
