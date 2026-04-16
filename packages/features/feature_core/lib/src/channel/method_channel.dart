import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelPage extends StatefulWidget {
  const MethodChannelPage({Key? key}) : super(key: key);

  @override
  State<MethodChannelPage> createState() => _MethodChannelPageState();
}

class _MethodChannelPageState extends State<MethodChannelPage> {
  // 1. 定义 MethodChannel，名称必须与原生端绝对一致
  static const MethodChannel _methodChannel = MethodChannel(
    'com.example.app/device_info',
  );

  String _batteryStatus = '尚未获取电量';

  // 2. 封装一个异步方法，去调用原生的能力
  Future<void> _getBatteryLevel() async {
    String statusText;

    try {
      // 通过 invokeMethod 要求原生执行名为 'getBatteryLevel' 的特定方法
      // 这里的泛型 <int> 表示我们期望原生返回一个整型数据
      final int result = await _methodChannel.invokeMethod('getBatteryLevel');
      statusText = '当前 iOS 设备电量为: $result %';
    } on PlatformException catch (e) {
      // 捕获原生端主动抛过来的 FlutterError 异常
      statusText = "获取失败: ${e.message}";
    } on MissingPluginException {
      // 这是一个非常经典的异常：当你在 Flutter 调用了一个方法，但 iOS 端没有实现该通道，或者没有写对名字时触发
      statusText = "通道未注册或原生层未实现该方法";
    }

    setState(() {
      _batteryStatus = statusText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MethodChannel 演示')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_batteryStatus, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('获取原生电池电量'),
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
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // 1. 创建 FlutterMethodChannel
        let batteryChannel = FlutterMethodChannel(name: "com.example.app/device_info",
                                                  binaryMessenger: controller.binaryMessenger)
        
        // 2. 设置 MethodCall 回调处理
        batteryChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            // call.method 就是 Flutter 端 invokeMethod 传过来的字符串
            switch call.method {
            case "getBatteryLevel":
                // 收到具体的指令，分发到具体的原生逻辑
                self?.receiveBatteryLevel(result: result)
                
            default:
                // 🌟 核心规范：如果 Flutter 传来了未知的 method，务必返回 NotImplemented
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // 3. 具体的原生业务逻辑
    private func receiveBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        // 在模拟器上，状态通常是 unknown (值为 -1)
        if device.batteryState == UIDevice.BatteryState.unknown {
            // 如果出错或无法获取，向 Flutter 抛出一个结构化的 Error
            // Flutter 段就会在 `on PlatformException catch(e)` 中捕获到
            result(FlutterError(code: "UNAVAILABLE",
                                message: "无法获取电池信息 (可能是在模拟器上)",
                                details: nil))
        } else {
            // 成功获取，因为 batteryLevel 是 0.0 ~ 1.0 的小数，转换成百分比的整数返回
            let batteryLevel = Int(device.batteryLevel * 100)
            
            // 直接调用 result() 将数据正常返回给 Flutter 的 await
            result(batteryLevel)
        }
    }
}

 */