#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 dotScreenEffect(float2 position,
                                     half4 color,
                                     float2 size,
                                     float scale,
                                     float angle) {
    // 旋转矩阵
    float2x2 rotationMatrix = float2x2(cos(angle), -sin(angle),
                                      sin(angle), cos(angle));
    
    // 计算旋转后的坐标
    float2 rotatedPos = position * rotationMatrix;
    
    // 创建点阵网格
    float2 pattern = rotatedPos / scale;
    pattern = pattern - floor(pattern);
    
    // 计算亮度
    float brightness = (color.r + color.g + color.b) / 3.0;
    
    // 计算点的大小（基于亮度）
    float dotSize = (1.0 - brightness) * 0.5;
    
    // 计算当前像素到网格中心的距离
    float2 center = float2(0.5, 0.5);
    float dist = distance(pattern, center);
    
    // 如果距离小于点大小，则显示为黑色，否则为白色
    float output = dist < dotSize ? 0.0 : 1.0;
    
    // 添加一些噪点使效果更自然
    float noise = fract(sin(dot(position, float2(12.9898, 78.233))) * 43758.5453);
    output = mix(output, noise, 0.05);
    
    return half4(output, output, output, 1.0);
}
