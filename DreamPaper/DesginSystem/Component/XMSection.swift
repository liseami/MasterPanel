//
//  XMSection.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/10.
//

import SwiftUI

struct XMSection<Content: View>: View {
    let title: String
    let footer: String?
    @ViewBuilder var content: () -> Content
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
        self.footer = nil
    }

    init(title: String, footer: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
        self.footer = footer
    }

    var body: some View {
        let content =

            content()
            .listRowInsets(.init(top: 24, leading: 20, bottom: 24, trailing: 20))
            .listRowSeparator(.hidden, edges: .top)
            .tint(.xm.main)

        if let footer {
            Section {
                content
            } header: {
                Text(title)
                    .font(.XMFont.f1b.v1)
                    .fcolor(.xmf1)
            } footer: {
                Text(footer)
                    .font(.XMFont.f2.v1)
                    .fcolor(.xmf2)
                    .listRowSeparator(.hidden, edges: .bottom)
            }
        } else {
            Section {
                content
            } header: {
                Text(title)
                    .font(.XMFont.f1b.v1)
                    .fcolor(.xmf1)
            }
        }
    }
}

#Preview {
    XMSection(title: "标题", footer: "nil") {
        EmptyView()
    }
}
