import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class BinaryChannelService {
  static const BasicMessageChannel<ByteData> _binaryChannel =
      BasicMessageChannel<ByteData>('binnary_channel', BinaryCodec());

  static void initReceiver() {
    _binaryChannel.setMessageHandler((ByteData? message) async {
      if (message != null) {}
      return ByteData(0);
    });
  }

  static Future<void> sendBinaryData(Uint8List data) async {
    ByteData byteData = ByteData.sublistView(data);
    try {
      ByteData? reply = await _binaryChannel.send(byteData);
      if (reply != null) {
        print('收到 Native 的处理回执, ${reply.lengthInBytes} bytes');
      }
    } on PlatformException catch (e) {
      print("发送二进制数据失败: ${e.message}");
    }
  }
}

class MessageChannelPage extends StatefulWidget {
  const MessageChannelPage({Key? key}) : super(key: key);

  @override
  State<MessageChannelPage> createState() => _MessageChannelPageState();
}

class _MessageChannelPageState extends State<MessageChannelPage> {
  // 1. 定义通道，明确指定名称及编解码器 (此处因为传 JSON 字符串，所以用 StringCodec)
  static const BasicMessageChannel<String> _messageChannel =
      BasicMessageChannel<String>(
        'com.example.app/json_messages',
        StringCodec(),
      );

  String _receivedMessage = '等待接收原生数据包...';

  @override
  void initState() {
    super.initState();
    // 2. 注册消息处理器，监听来自 iOS 主动发来的消息
    _messageChannel.setMessageHandler((String? message) async {
      setState(() {
        _receivedMessage = '收到 iOS 初始化推送: $message';
      });
      // 这里的 return 是给 iOS 端的 Reply 回复（对应 iOS 端 sendMessage 的 reply 闭包）
      return 'Flutter 已收到该数据包!';
    });
  }

  // 3. 由 Flutter 主动向 iOS 发送消息
  Future<void> _sendMessageToNative() async {
    final String mockJson = '{"action": "log", "msg": "user clicked button"}';

    // 使用 send 发送，并异步等待原生的直接回复 (对应 iOS 端的 reply 闭包)
    final String? response = await _messageChannel.send(mockJson);

    setState(() {
      _receivedMessage = '发送完毕，iOS 的答复是: $response';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BasicMessageChannel 演示')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_receivedMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendMessageToNative,
              child: const Text('发送 JSON 数据包给 iOS'),
            ),
          ],
        ),
      ),
    );
  }
}



/**

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // 必须保留通道的强引用，以便随时向 Flutter 主动发消息
    private var messageChannel: FlutterBasicMessageChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // 1. 初始化 BasicMessageChannel，务必传入与 Flutter 对应的 Codec (这里是 FlutterStringCodec)
        messageChannel = FlutterBasicMessageChannel(
            name: "com.example.app/json_messages",
            binaryMessenger: controller.binaryMessenger,
            codec: FlutterStringCodec.sharedInstance()
        )
        
        // 2. 被动监听：接收来自 Flutter send() 的消息
        messageChannel?.setMessageHandler { [weak self] (message: Any?, reply: @escaping FlutterReply) in
            // 接到 Flutter 的信息
            if let jsonString = message as? String {
                print("iOS 收到来自 Flutter 的数据包: \(jsonString)")
                
                // 处理原生逻辑...
                let isSuccess = true 
                
                // 向 Flutter 的 send() 方法返回结果
                if isSuccess {
                    reply("{\"status\":\"ok\", \"handledBy\":\"iOS\"}")
                } else {
                    reply("{\"status\":\"error\"}")
                }
            } else {
                reply(nil) // 数据格式不对时返回空
            }
        }
        
        // 👉 额外的示例演示代码：假设延迟 3 秒后，iOS 主动向 Flutter 推发一条业务消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.sendDataToFlutter()
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // 3. 主动发送：iOS 端随时向 Flutter 丢包
    func sendDataToFlutter() {
        let asyncPushJson = "{\"type\": \"remote_notification\", \"alert\": \"你有新的未读消息\"}"
        
        // 主动发送数据，并且可以监听 Flutter 那边的回复（对应 Flutter 端 setMessageHandler 中的 return）
        messageChannel?.sendMessage(asyncPushJson) { (replyMessage: Any?) in
            if let flutterReply = replyMessage as? String {
                print("iOS 主动发送成功，Flutter 回复说: \(flutterReply)")
            }
        }
    }
}

 */