//
//  NavigationBar.swift
//  CyberLife
//
//  Created by 赵翔宇 on 2024/11/16.
//

import SwiftUI

struct NavigationBar: View {
    @State var title: String = ""
    var body: some View {
        ZStack {
            HStack {
                XMUserAvatar(str: "", userId: "", size: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(lineWidth: 1)
                            .fcolor(.xm.f3)
                    }
                Spacer()
                XMDesgin.XMIcon(iconName: "add_line",
                                color: .xm.f1,
                                renderingMode: .template)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.xm.b1)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .height(1)
                    .fcolor(.xm.f3.opacity(0.3))
            }
            .overlay(alignment: .center) {
                Text(title)
                    .font(.custom("HFHourglass", size: 32))
                    .fcolor(.xm.f1)
                    .task {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                self.title = "CyberLife"
                            }
                        }
                    }
                    .contentTransition(.numericText(countsDown: false))
            }
        }
    }

    private var bottomBlurGradient: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .mask(
                VStack(spacing: 0) {
                    Rectangle()
                    LinearGradient(colors: [.clear, .black], startPoint: .bottom, endPoint: .top)
                }
            )
            .frame(height: UIScreen.main.bounds.height * 0.20)
            .colorScheme(.dark)
    }
}

#Preview {
    MainView()
}
