//
//  XMEmptyView.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/9.
//

import SwiftUI

struct XMEmptyView: View {
    let image: String
    let text: String
    let subline: String
    let paddingTop: CGFloat
    init(image: String = "membership_1", text: String = String(localized: "暂时没有内容"), subline: String = "", paddingTop: CGFloat = UIScreen.main.bounds.height * 0.15) {
        self.image = image
        self.text = text
        self.subline = subline
        self.paddingTop = paddingTop
    }

    var body: some View {
        VStack(spacing: 0) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            VStack(alignment: .center, spacing: 8) {
                Text(text)
                    .font(.XMFont.f1.v1)
                Text(subline)
                    .font(.XMFont.f3.v1)
                    .fcolor(.xmf2)
            }
        }
        .padding(.top, paddingTop)
    }
}

#Preview {
    XMEmptyView(image: "membership_1", text: "暂无内容", subline: "请添加内容", paddingTop: UIScreen.main.bounds.height * 0.3)
}
