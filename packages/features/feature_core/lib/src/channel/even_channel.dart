import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class TimerEventPage extends StatefulWidget {
  const TimerEventPage({Key? key}) : super(key: key);

  @override
  State<TimerEventPage> createState() => _TimerEventPageState();
}

class _TimerEventPageState extends State<TimerEventPage> {
  // 1. 定义与原生端名称完全一致的 EventChannel
  static const EventChannel _timerEventChannel = EventChannel(
    'com.example.app/timer_events',
  );

  StreamSubscription? _timerSubscription;
  String _timerValue = '等待接收数据...';

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    // 2. 将 Channel 转换为 Stream 并监听 (receiveBroadcastStream)
    _timerSubscription = _timerEventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        // 原生端每发一次数据，这里就会回调一次
        setState(() {
          _timerValue = '来自原生的数据: $event';
        });
      },
      onError: (dynamic error) {
        // 如果原生端发送了一个 error 事件，这里处理异常
        setState(() {
          _timerValue = '发生错误: ${error.message}';
        });
      },
      onDone: () {
        // 原生端通知流已关闭
        setState(() {
          _timerValue = '原生端已停止发送数据';
        });
      },
    );
  }

  @override
  void dispose() {
    // 3. 极其重要：页面销毁时务必取消订阅，否则会导致内存泄漏及原生端抛异常
    _timerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EventChannel 演示')),
      body: Center(
        child: Text(_timerValue, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}


/*
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    
    private var timer: Timer?
    private var counter = 0
    private var flutterEventSink: FlutterEventSink?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // 1. 创建 FlutterEventChannel 实例
        let eventChannel = FlutterEventChannel(name: "com.example.app/timer_events",
                                              binaryMessenger: controller.binaryMessenger)
        
        // 2. 设置当前类作为它的 Handler (需实现 FlutterStreamHandler 协议)
        eventChannel.setStreamHandler(self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - FlutterStreamHandler
    
    // Flutter 端发起 listen 时调用
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.flutterEventSink = events // 保存 Sink 回调闭包
        self.counter = 0
        
        // 启动定时器，每秒执行一次
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.counter += 1
            // ⚠️ 同样必须确保回调在主线程执行
            DispatchQueue.main.async {
                self.flutterEventSink?("iOS Ticking: \(self.counter)")
            }
        }
        
        return nil
    }
    
    // Flutter 端调用 cancel 取消监听时调用
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // 清理定时器和引用
        self.timer?.invalidate()
        self.timer = nil
        self.flutterEventSink = nil
        return nil
    }
}

 */