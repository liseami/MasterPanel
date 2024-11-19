//
//  BellyLoadingView.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/4/15.
//

import SwiftUI

struct SBLoadingView: View {
    let w =  UIScreen.main.bounds.width * 0.618
    var body: some View {
        // 加载中
        AutoLottieView(lottieFliesName: "sbloading", loopMode: .loop, speed: 1)
            .frame(width: w, height: w)
            .transition(.movingParts.glare)
            .padding(.top, 120)
    }
}

#Preview {
    SBLoadingView()
}
