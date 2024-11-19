//
//  XMEditSheet.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/5/30.
//

import SwiftUI

struct XMEditSheet<Content: View>: View where Content: View {
    let onTapComplete: () async -> Void

    let title: String
    let content: () -> Content
    var enable: Bool
    init(title: String, enable: Bool = true, onTapComplete: @escaping () async -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onTapComplete = onTapComplete

        self.title = title
        self.content = content
        self.enable = enable
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // sheetHeader
            sheetHeader
            // 内容滚动视图
            scrollView
        }
    }

    var scrollView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24, pinnedViews: [], content: {
                content()
            })
            .padding(.all, 16)
        }
        .font(.XMFont.f1b.v1)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    var sheetHeader: some View {
        HStack(content: {
            Text(LocalizedStringKey(stringLiteral: title))
                .font(.XMFont.f1.v1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.vertical,4)
                .padding(.leading, 8)
                .padding(.trailing, 24)
                .background( Image("Bar Picker")
                    .resizable()
                    .height(24))
            
             
            Spacer()
            XMDesgin.XMButton {
                await self.onTapComplete()
            } label: {
                Image("checkbox")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .overlay {
                        XMDesgin.XMIcon(iconName: "system_check",size: 32)
                            .offset(x: 4, y: -8)
                    }
            }
        })
        .padding(.all, 12)
        .background(Color.xmb3)
        .overlay(alignment: .center) {
            Rectangle().stroke(lineWidth: 4)
                .fcolor(.xmf1.opacity(0.2))
                .padding(.all, 2)
        }
        .overlay(alignment: .center) {
            Rectangle().stroke(lineWidth: 3)
                .fcolor(.xmf1)
        }
    }
}

#Preview {
    Color.clear
        .onAppearOnce {
            Apphelper.shared.presentPanSheet(XMEditSheet(title: "编辑sheet") {} content: {
                Text("内容视图")
            }, style: .sheet)
        }
}
