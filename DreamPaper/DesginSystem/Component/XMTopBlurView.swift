//
//  XMTopBlurView.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/8.
//

import SwiftUI

struct XMTopBlurView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.black, Color.black, Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
            .blur(radius: 12)
            .padding([.horizontal, .top], -30)
            .frame(height: 90)
            .ignoresSafeArea()
    }
}

#Preview {
    XMTopBlurView()
}
