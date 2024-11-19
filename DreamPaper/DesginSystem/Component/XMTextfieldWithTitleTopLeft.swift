//
//  XMTextfieldWithTitleTopLeft.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/5/30.
//

import SwiftUI

struct XMTextfieldWithTitleTopLeft: View {
    let title : String
    @Binding var text : String
    init(title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12, content: {
            Text(title)
                .font(.XMFont.f3.v2)
            TextField("", text: $text,axis: .vertical)
                .font(.XMFont.f1.v2)
                .tint(Color.xmf1)
                .fcolor(.xmf1)
                .minHeight(44)
            Divider()
        })
    }
}

#Preview {
    XMTextfieldWithTitleTopLeft.init(title: "标题", text: .constant("内容"))
}
