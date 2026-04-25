import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:lt_network/network.dart';

class AppSslPinningConfig implements SslPinningConfig {
  const AppSslPinningConfig();

  @override
  bool get disabled => true;

  @override
  List<String> get publicKeyHashes => const [];

  @override
  bool validate(X509Certificate certificate, String host, int port) {
    try {
      final spkiBytes = _extractSpkiBytes(certificate.der);
      if (spkiBytes == null) return false;

      final hash = base64.encode(sha256.convert(spkiBytes).bytes);

      return publicKeyHashes.contains(hash);
    } catch (_) {
      return false;
    }
  }

  List<int>? _extractSpkiBytes(List<int> derCert) {
    try {
      return _parseDerFindSpki(derCert);
    } catch (_) {
      return null;
    }
  }

  List<int>? _parseDerFindSpki(List<int> der) {
    int pos = 0;
    while (pos < der.length) {
      final tag = der[pos];
      if (pos + 1 >= der.length) break;
      final lenByte = der[pos + 1];

      int contentLen;
      int headerLen;
      if (lenByte & 0x80 == 0) {
        contentLen = lenByte;
        headerLen = 2;
      } else {
        final numLenBytes = lenByte & 0x7F;
        if (pos + 1 + numLenBytes >= der.length) break;
        contentLen = 0;
        for (int i = 0; i < numLenBytes; i++) {
          contentLen = (contentLen << 8) | der[pos + 2 + i];
        }
        headerLen = 2 + numLenBytes;
      }

      if (tag == 0x30) {
        final content = der.sublist(
          pos + headerLen,
          pos + headerLen + contentLen,
        );
        if (content.length > 4 && content[0] == 0x30) {
          final innerSeqLen = _getLength(content, 1);
          final afterInnerSeq = 1 + _headerLen(content, 1) + innerSeqLen;
          if (afterInnerSeq < content.length &&
              content[afterInnerSeq] == 0x03) {
            return der.sublist(pos, pos + headerLen + contentLen);
          }
        }
        final inner = _parseDerFindSpki(content);
        if (inner != null) return inner;
      }
      pos += headerLen + contentLen;
    }
    return null;
  }

  int _getLength(List<int> bytes, int pos) {
    final lenByte = bytes[pos];
    if (lenByte & 0x80 == 0) return lenByte;
    final numLenBytes = lenByte & 0x7F;
    int len = 0;
    for (int i = 0; i < numLenBytes; i++) {
      len = (len << 8) | bytes[pos + 1 + i];
    }
    return len;
  }

  int _headerLen(List<int> bytes, int pos) {
    final lenByte = bytes[pos];
    if (lenByte & 0x80 == 0) return 2;
    return 2 + (lenByte & 0x7F);
  }
}
