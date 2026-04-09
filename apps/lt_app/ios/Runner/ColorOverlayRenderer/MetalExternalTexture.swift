//
//  MetalExternalTexture.swift
//  Runner
//
//  Created by Renjun Li on 2026/4/9.
//

import Foundation
import Flutter
import CoreVideo
import Metal

class MetalExternalTexture: NSObject, FlutterTexture {
    private var pixelBuffer: CVPixelBuffer?
    private var textureCache: CVMetalTextureCache?
    private weak var registry: FlutterTextureRegistry?
    var textureId: Int64 = -1
    
    
    init(registry: FlutterTextureRegistry, device: MTLDevice) {
        self.registry = registry
        super.init()
        
        
        
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        self.textureId = registry.register(self)
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let pixelBuffer else { return nil }
        return Unmanaged.passRetained(pixelBuffer)
    }
    
    func prepareTexture(width: Int, height: Int) -> MTLTexture? {
        guard let textureCache else { return nil }
        let attrs = [
            kCVPixelBufferMetalCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ] as CFDictionary
        
        var newPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &newPixelBuffer)
        guard status == kCVReturnSuccess, let buffer = newPixelBuffer else { return nil }
        self.pixelBuffer = buffer
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  textureCache,
                                                  buffer,
                                                  nil,
                                                  .bgra8Unorm,
                                                  width, height,
                                                  0,
                                                  &cvTextureOut)
        
        guard let cvTexture = cvTextureOut else { return nil }
        return CVMetalTextureGetTexture(cvTexture)
    }
    
    
    public func markFrameAvailable() {
        if textureId != -1 {
            registry?.textureFrameAvailable(textureId)
        }
    }
    
}
