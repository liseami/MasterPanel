//
//  XMTextFiledWithTitle.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/5/30.
//

import SwiftUI

struct XMTextFiledWithTitleLeft: View {
    let title : String
    @Binding var text : String
    let isOptional : Bool
    init(title: String, isOptional : Bool = false ,text: Binding<String>) {
        self.title = title
        self._text = text
        self.isOptional = isOptional
    }
    var body: some View {
        HStack {
            Text(title)
                .font(.XMFont.f1b.v2)
                .fcolor(.xmf1)
            Spacer()
            TextField("添加\(title)", text: $text)
                .font(.XMFont.f1.v2)
                .fcolor(.xmf1)
                .multilineTextAlignment(.trailing)
                
            Text("(可选)")
                .font(.XMFont.f1.v2)
                .fcolor(.xmf1)
                .multilineTextAlignment(.trailing)
                .ifshow(show: self.isOptional)
                .ifshow(show: text.isEmpty)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

#Preview {
    XMTextFiledWithTitleLeft.init(title: "标题", text:  .constant("内容"))
}
