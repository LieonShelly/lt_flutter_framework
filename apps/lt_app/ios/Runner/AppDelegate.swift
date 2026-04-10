import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let registrar = self.registrar(forPlugin: "MetalOverlayPlugin")!
        let factory = MetalOverlayViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "plugin.metal_overlay_view")
        registerExternalTexure()
        registerBinnaryChannel()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    var externalTexture: MetalExternalTexture?
    var channel: FlutterMethodChannel?
    
    func registerExternalTexure() {
        let registry = self.registrar(forPlugin: "MetalTexturePlugin")!.textures()
        let controller = window?.rootViewController as! FlutterViewController
        let device = MTLCreateSystemDefaultDevice()!
        externalTexture = MetalExternalTexture(registry: registry, device: device)
        OverlayExternalTextureRenderer.shared.externalTexture = externalTexture
        channel = FlutterMethodChannel(name: "metal_texture_channel", binaryMessenger: controller.binaryMessenger)
        channel?.setMethodCallHandler({ [weak self] (call, result) in
            guard let self = self else { return }
            
            if call.method == "initializeTexture" {
                result(self.externalTexture?.textureId)
                
                if let params = call.arguments as? [String: Any],
                    let imagePath = params["imagePath"] as? String,
                    let image = UIImage(contentsOfFile: imagePath) {
                    OverlayExternalTextureRenderer.shared.prepareForRealtimeRendering(image: image)
                    OverlayExternalTextureRenderer.shared.overlayColor = UIColor.red
                    OverlayExternalTextureRenderer.shared.renderToExternalTexture()
                }
                
            } else if call.method == "updateColor" {
                if let rgba = call.arguments as? [NSNumber], rgba.count == 4 {
                    let color = UIColor(
                        red: CGFloat(rgba[0].doubleValue),
                        green: CGFloat(rgba[1].doubleValue),
                        blue: CGFloat(rgba[2].doubleValue),
                        alpha: CGFloat(rgba[3].doubleValue)
                    )
                    OverlayExternalTextureRenderer.shared.overlayColor = color
                    OverlayExternalTextureRenderer.shared.renderToExternalTexture()
                    result(nil)
                }
            }
        })
    }
    
    func registerBinnaryChannel() {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let binnaryChannel = FlutterBasicMessageChannel(
            name: "binnary_channel",
            binaryMessenger: controller.binaryMessenger,
            codec: FlutterBinaryCodec.sharedInstance()
        )
        binnaryChannel.setMessageHandler { messsage, reply in
            if let data = messsage as? Data {
                // TODO: 处理图像数据
                let reponseBytes: [UInt8] = [1]
                let responseData = Data(reponseBytes)
                reply(responseData)
            } else {
                reply(nil)
            }
        }
    }
}
    
