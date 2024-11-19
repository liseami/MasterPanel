//
//  HomeView.swift
//  CyberLife
//
//  Created by 赵翔宇 on 2024/11/16.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            NavigationBar()
            ScrollView {
                Spacer().height(12)
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(0 ..< 80) { _ in
                        messageRow()
                            .scrollTransition(.animated) { content, phase in
                                content
                                    .offset(x: phase.isIdentity ? 0 : 32)
                                    .scaleEffect(phase.isIdentity ? 1 : 1.1)
                                    .opacity(phase.isIdentity ? 1 : 0.3)
                                    .blur(radius: phase.isIdentity ? 0 : 32)
//                                    .hueRotation(.degrees(45 * phase.value))
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    func messageRow() -> some View {
        XMDesgin.XMButton {} label: {
            HStack(spacing: 12) {
                XMUserAvatar(str: "", userId: "", size: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(lineWidth: 1)
                            .fcolor(.xm.f3)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text("需要我做什么？")
                        .font(.XMFont.f2b.v1)
                        .fcolor(.xm.f1)
                    Text("Hi,👋 · 2h")
                        .font(.XMFont.f3.v1)
                        .fcolor(.xm.f2)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    MainView()
}
