//
//  BoundingBox.swift
//  ColorOverlayRenderer
//
//  Created by Renjun Li on 2026/4/9.
//


#include <metal_stdlib>
using namespace metal;

kernel void dilate_mask(texture2d<half, access::read> inMask [[texture(0)]],
                        texture2d<half, access::write> outMask [[texture(1)]],
                        constant int &radius [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]]) {
    
    if (gid.x >= outMask.get_width() || gid.y >= outMask.get_height()) { return; }

    int r = radius;
    if (r <= 0) {
        outMask.write(inMask.read(gid), gid);
        return;
    }

    int r2 = r * r;
    half isEffective = 0.0h;

    // 搜索周围的像素
    for (int j = -r; j <= r; j++) {
        for (int i = -r; i <= r; i++) {
            // 切割成完美的圆形内核
            if (i * i + j * j <= r2) {
                uint2 readPos = uint2(clamp(int(gid.x) + i, 0, int(inMask.get_width() - 1)),
                                      clamp(int(gid.y) + j, 0, int(inMask.get_height() - 1)));
                
                // 如果发现邻居是蒙版有效区域
                if (inMask.read(readPos).r > 0.5h) {
                    isEffective = 1.0h;
                    break; // 【性能核心】: 找到了就立刻停止搜索当前像素！
                }
            }
        }
        if (isEffective > 0.5h) break; // 只要变色了，外层循环也立刻停止！
    }

    // 写入膨胀后的单通道 Mask
    outMask.write(half4(isEffective, 0.0h, 0.0h, 1.0h), gid);
}


// Pass 2: 颜色叠加着色器
struct OverlayColor {
    float4 color; // r, g, b, a (刚好 16 字节)
};

kernel void apply_color_overlay(texture2d<half, access::read> inTexture [[texture(0)]],
                                texture2d<half, access::read> maskTexture [[texture(1)]], // 读取 Pass1 产物
                                texture2d<half, access::write> outTexture [[texture(2)]],
                                constant OverlayColor &params [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]]) {
                                
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) { return; }

    half origAlpha = inTexture.read(gid).a;
    half maskValue = maskTexture.read(gid).r;

    half4 outColor;
    
    if (maskValue > 0.5h) {
        half finalAlpha;
        if (origAlpha > 0.0h && origAlpha < 1.0h) {
            finalAlpha = origAlpha;
        } else {
            finalAlpha = 1.0h;
        }
        
        outColor = half4(half(params.color.r), half(params.color.g), half(params.color.b), finalAlpha);
        
        if (origAlpha > 0.0h) {
            outColor = inTexture.read(gid);
        }
    } else {
        outColor = half4(0.0h, 0.0h, 0.0h, 0.0h);
    }

    outTexture.write(outColor, gid);
}

struct QuadVertexOut {
    float4 position [[position]]; // 屏幕空间坐标 (NDC: -1 到 1)
    float2 texCoord;              // 纹理坐标 (0 到 1)
};

vertex QuadVertexOut quad_vertex_main(constant packed_float2 *vertices [[buffer(0)]],
                                      constant packed_float2 *texCoords [[buffer(1)]],
                                      uint vertexID [[vertex_id]]) {
    QuadVertexOut out;
    out.position = float4(vertices[vertexID], 0.0, 1.0);
    out.texCoord = texCoords[vertexID];
    return out;
}

fragment half4 quad_fragment_main(QuadVertexOut in [[stage_in]],
                                  texture2d<half, access::sample> texture [[texture(0)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    return texture.sample(textureSampler, in.texCoord);
}
