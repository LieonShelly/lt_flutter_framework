import 'dart:isolate';

typedef JsonDecoder<T> = T Function(Map<String, dynamic> json);

class ComputeTransformer {
  ComputeTransformer._();

  static Future<List<T>> decodeList<T>(
    List<dynamic> data,
    JsonDecoder<T> decoder,
  ) async {
    return await Isolate.run(() {
      return data.map((e) => decoder(e as Map<String, dynamic>)).toList();
    });
  }

  static Future<T> decodeObject<T>(
    Map<String, dynamic> data,
    JsonDecoder<T> decoder,
  ) async {
    return await Isolate.run(() {
      return decoder(data);
    });
  }
}
