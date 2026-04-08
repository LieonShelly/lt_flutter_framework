import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// 原生函数类型定义 — process_icon
typedef ProcessIconNative =
    Int32 Function(
      Pointer<Uint8> inputData,
      Int32 inputLength,
      Int32 thickness,
      Pointer<Pointer<Uint8>> outputData,
      Pointer<Int32> outputLength,
    );
typedef ProcessIconDart =
    int Function(
      Pointer<Uint8> inputData,
      int inputLength,
      int thickness,
      Pointer<Pointer<Uint8>> outputData,
      Pointer<Int32> outputLength,
    );

/// 原生函数类型定义 — free_processed_data
typedef FreeProcessedDataNative = Void Function(Pointer<Uint8> pointer);
typedef FreeProcessedDataDart = void Function(Pointer<Uint8> pointer);

/// Dart FFI 绑定层，负责加载原生符号、分配/释放内存、调用原生函数。
class FfiBridge {
  static final DynamicLibrary _lib = DynamicLibrary.process();

  static final ProcessIconDart _processIcon = _lib
      .lookupFunction<ProcessIconNative, ProcessIconDart>('process_icon');

  static final FreeProcessedDataDart _freeProcessedData = _lib
      .lookupFunction<FreeProcessedDataNative, FreeProcessedDataDart>(
        'free_processed_data',
      );

  /// 调用原生 process_icon，返回处理后的 PNG 数据，失败返回 null。
  static Uint8List? processIcon(Uint8List imageBytes, int thickness) {
    Pointer<Uint8> inputPtr = nullptr;
    Pointer<Pointer<Uint8>> outPtrPtr = nullptr;
    Pointer<Int32> outLenPtr = nullptr;

    try {
      // 分配输入缓冲区并拷贝数据
      inputPtr = malloc<Uint8>(imageBytes.length);
      inputPtr.asTypedList(imageBytes.length).setAll(0, imageBytes);

      // 分配输出指针和输出长度
      outPtrPtr = malloc<Pointer<Uint8>>();
      outLenPtr = malloc<Int32>();

      // 调用原生函数
      final status = _processIcon(
        inputPtr,
        imageBytes.length,
        thickness,
        outPtrPtr,
        outLenPtr,
      );

      // 非零状态码表示处理失败
      if (status != 0) {
        return null;
      }

      // 读取输出数据并拷贝到 Dart 堆
      final outPtr = outPtrPtr.value;
      final outLen = outLenPtr.value;

      if (outPtr == nullptr || outLen <= 0) {
        return null;
      }

      return Uint8List.fromList(outPtr.asTypedList(outLen));
    } finally {
      // 释放 Dart 侧分配的输入缓冲区
      if (inputPtr != nullptr) {
        malloc.free(inputPtr);
      }
      // 释放原生侧分配的输出缓冲区 + Dart 侧分配的输出指针
      if (outPtrPtr != nullptr) {
        final outPtr = outPtrPtr.value;
        if (outPtr != nullptr) {
          _freeProcessedData(outPtr);
        }
        malloc.free(outPtrPtr);
      }
      // 释放 Dart 侧分配的输出长度指针
      if (outLenPtr != nullptr) {
        malloc.free(outLenPtr);
      }
    }
  }
}
