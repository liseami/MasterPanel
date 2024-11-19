//
//  XMBrandLine.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/6/15.
//

import SwiftUI

struct XMBrandLine: View {
    let text : String
    init(text: String = "胃之书") {
        self.text = text
    }
    var body: some View {
        HStack(alignment: .center, spacing: 4, content: {
            XMAppLogo(size: 48)
                .background(Color.xmb2)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(.drop(color: .xmf1.opacity(0.1), radius: 12, x: 0, y: 0))
            VStack(alignment: .leading, spacing: 4, content: {
                Text(text).font(.XMFont.f1b.v2)
                Text("饮食之趣味，胃口之史书").font(.XMFont.f3.v2)
            })
            Spacer()
            Image("bellybookqrcode")
                .resizable()
                .renderingMode(.template)
                .frame(width: 38, height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 10), style: FillStyle())
                .fcolor(.xmf1.opacity(0.3))
        })
    }
}

#Preview {
    XMBrandLine()
}
