//
//  ShaderImage.swift
//  CyberLife
//
//  Created by 赵翔宇 on 2024/11/16.
//

import SwiftUI

struct RainbowLine: View {
    @State private var time: Float = 0 // 用于动画
    
    let now = Date.now
    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = now.distance(to: timeline.date)

            Rectangle()
                .visualEffect { content, proxy in
                    content
                        .colorEffect(
                            ShaderLibrary.sinebow(
                                .float2(proxy.size),
                                .float(elapsedTime)
                            )
                        )
                }
        }
        .frame(height:120)
    }
}

#Preview {
    RainbowLine()
}
