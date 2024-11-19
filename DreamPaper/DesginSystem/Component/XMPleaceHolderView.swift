//
//  XMPleaceHolderView.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/3/21.
//

import SwiftUI

struct XMPleaceHolderView: View {
    let imageName: String?
    let text: String
    let btnText: String
    let btnaction: () async -> ()
    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .center, spacing: 32) {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .scaleEffect(2)
                }
                Text(text)
                    .font(.XMFont.f2.v1)
            }
            XMDesgin.XMMainBtn(text: btnText) {
                await btnaction()
            }
            .padding(.horizontal, 120)
        }
        .frame(height: UIScreen.main.bounds.width, alignment: .top)
        .frame(maxWidth: .infinity)
        .padding(.top, UIScreen.main.bounds.width * 0.24)
        .listRowInsets(.init(top: 0, leading: 24, bottom: 0, trailing: 24))
        .listRowSeparator(.hidden, edges: .all)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    XMPleaceHolderView(imageName: "残食", text: "暂无记录", btnText: "去记录") {}
}
