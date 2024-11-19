//
//  AnimatedGradient.metal
//  ActionPark
//
//  Created by 赵翔宇 on 2024/9/9.
//

#include <metal_stdlib>
using namespace metal;

float oscillate(float f) {
    return 0.5 * (sin(f) + 1);
}

[[stitchable]] half4 animatedGradient(float2 position, half4 color, float2 size, float time) {
    float redComponent = oscillate(2 * time + position.x/size.x);
    float greenComponent = oscillate(3 * time + position.y/size.y);
    float blueComponent = oscillate(4 * time + (position.x + position.y)/(size.x + size.y));
    
    return half4(redComponent, greenComponent, blueComponent, 1.0);
}
