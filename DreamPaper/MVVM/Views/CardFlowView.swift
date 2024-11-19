//
//  CardFlowView.swift
//  CyberLife
//
//  Created by 赵翔宇 on 2024/11/16.
//

import SwiftUI
import WaterfallGrid


struct CardFlowView: View {
    // 示例数据
    let items: [CardItem] = [
        CardItem(title: "忧伤的奶水", subtitle: "翔宇's Space", content: "西北出一轮柑子..."),
        CardItem(title: "Bullet Journal", subtitle: "翔宇's Space", content: "The Bullet Journal is a popular method..."),
        CardItem(title: "Recipes Collection", subtitle: "翔宇's Space", content: "How to use this template..."),
        CardItem(title: "忧伤的奶水", subtitle: "翔宇's Space", content: "西北出一轮柑子..."),
        CardItem(title: "Bullet Journal", subtitle: "翔宇's Space", content: "The Bullet Journal is a popular method..."),
        CardItem(title: "Recipes Collection", subtitle: "翔宇's Space", content: "How to use this template..."),
        CardItem(title: "忧伤的奶水", subtitle: "翔宇's Space", content: "西北出一轮柑子..."),
        CardItem(title: "Bullet Journal", subtitle: "翔宇's Space", content: "The Bullet Journal is a popular method..."),
        CardItem(title: "Recipes Collection", subtitle: "翔宇's Space", content: "How to use this template..."),        CardItem(title: "忧伤的奶水", subtitle: "翔宇's Space", content: "西北出一轮柑子..."),
        CardItem(title: "Bullet Journal", subtitle: "翔宇's Space", content: "The Bullet Journal is a popular method..."),
        CardItem(title: "Recipes Collection", subtitle: "翔宇's Space", content: "How to use this template...")
        // 可以添加更多项目
    ]
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            NavigationBar()
            ScrollView {
                WaterfallGrid(items) { item in
                    CardView(item: item)
                        .scrollTransition(.animated) { content, phase in
                            content
                                .offset(x: phase.isIdentity ? 0 : 32)
                                .scaleEffect(phase.isIdentity ? 1 : 1.1)
                                .opacity(phase.isIdentity ? 1 : 0.3)
                                .blur(radius: phase.isIdentity ? 0 : 32)
//                                    .hueRotation(.degrees(45 * phase.value))
                        }
                }
                .gridStyle(
                  columnsInPortrait: 2,
                  columnsInLandscape: 2,
                  spacing: 8,
                  animation: .smooth
                )
                .scrollOptions(direction: .vertical)
                .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
            }
        }
        
     
    }
}

// 卡片数据模型
struct CardItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let content: String
}

// 卡片视图组件
struct CardView: View {
    let item: CardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .foregroundColor(.xm.f1)
            
            HStack {
                Text(item.subtitle)
                    .font(.XMFont.f3b.v1)
                    .foregroundColor(.xm.f1)
                Spacer()
            }
            
            Text(item.content)
                .font(.XMFont.f3.v1)
                .lineLimit(nil)
                .fcolor(.xm.f2)
        }
        .padding(.all,12)
        .background(Color.xm.b2)
        .cornerRadius(6)
        .shadow(radius: 2)
    }
}

#Preview {
    MainView()
        .onAppear {
            MainViewModel.shared.currentTabbar = .collections
        }
}
