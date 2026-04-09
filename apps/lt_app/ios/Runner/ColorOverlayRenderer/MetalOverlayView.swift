//
//  MetalOverlayView.swift
//  Runner
//
//  Created by Renjun Li on 2026/4/9.
//

import Foundation
import Flutter
import MetalKit
import UIKit

class MetalOverlayView: NSObject, FlutterPlatformView, MTKViewDelegate {
    private var mtkView: MTKView
    private var channel: FlutterMethodChannel
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.mtkView = MTKView(frame: frame, device: MTLCreateSystemDefaultDevice())
        mtkView.colorPixelFormat = .rgba8Unorm
        mtkView.isPaused = true
        mtkView.enableSetNeedsDisplay = true
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        mtkView.isOpaque = false
        self.channel = FlutterMethodChannel(name: "color_overlayer_\(viewId)", binaryMessenger: messenger)
        super.init()
        mtkView.delegate = self
        ColorOverlayRenderer.shared.mtkView = self.mtkView
        if let params = args as? [String: Any], let imageName = params["imageName"] as? String {
            let image = UIImage(resource: .dripper)
            ColorOverlayRenderer.shared.prepareForRealtimeRendering(image: image)
            // 设置默认颜色以触发首次绘制
            ColorOverlayRenderer.shared.overlayColor = UIColor.red
        }
        
        setupMethodCallHandler()
    }
    
    func view() -> UIView {
        return mtkView
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        ColorOverlayRenderer.shared.renderToView()
    }
    
    private func setupMethodCallHandler() {
        channel.setMethodCallHandler {[weak self] (call, result) in
            if call.method == "updateColor" {
                if let rgba = call.arguments as? [NSNumber], rgba.count == 4 {
                    let color = UIColor(
                        red: CGFloat(rgba[0].doubleValue),
                        green: CGFloat(rgba[1].doubleValue),
                        blue: CGFloat(rgba[2].doubleValue),
                        alpha: CGFloat(rgba[3].doubleValue)
                    )
                    ColorOverlayRenderer.shared.overlayColor = color
                }
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
}


class MetalOverlayViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return MetalOverlayView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }
}
