//
//  ColorSharderView.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/5/30.
//

import SwiftUI

struct ColorSharderView: View {
    @State private var randomFloat: Float = 2 // Initial value
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let start = Date.now
    var body: some View {
        ZStack {
            if #available(iOS 17.0, *) {
                TimelineView(.animation) { context in
                    Rectangle()
                        .foregroundStyle(.black)
                        .scaleEffect(4)
                        .colorEffect(
                            ShaderLibrary.default.timeLines(
                                .boundingRect,
                                .float(context.date.timeIntervalSince1970 - start.timeIntervalSince1970),
                                .float(randomFloat)
                            )
                        )
                }.blur(radius: 1.2, opaque: true)
            } else {
                Color.xmf1
            }
        }
        .onReceive(timer) { _ in
            if Bool.random() {
                randomFloat = Float.random(in: 0.8 ..< 1)
            } else {
                randomFloat = Float.random(in: 0 ..< 4)
            }
        }
    }
}

#Preview {
    ColorSharderView()
}
