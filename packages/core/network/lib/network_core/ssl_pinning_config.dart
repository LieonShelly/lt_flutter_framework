import 'dart:io';

abstract interface class SslPinningConfig {
  bool get disabled;

  List<String> get publicKeyHashes;

  bool validate(X509Certificate certificate, String host, int port);
}
