//
//  XMUserLine.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/9.
//

import SwiftUI

struct XMUserLine: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(str: AppConfig.mokImage!.absoluteString)
                .scaledToFill()
                .frame(width: 44, height: 44, alignment: .center)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 12, content: {
                HStack {
                    VStack(alignment: .leading, spacing: 6, content: {
                        Text("Placeholder")
                            .font(.XMFont.f1b.v1)
                        Text("天蝎 · S")
                            .font(.XMFont.f2.v1)
                            .fcolor(.xmf2)
                    })
                    Spacer()
                    XMDesgin.SmallBtn( text: String.init(localized:"正在关注")) {}
                }
                Text(String.randomChineseString(length: 40))
                    .font(.XMFont.f2.v1)

            })
        }
        
    }
}


#Preview {
    XMUserLine()
}
