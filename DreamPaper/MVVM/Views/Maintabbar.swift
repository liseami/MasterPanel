//
//  Maintabbar.swift
//
//
//  Created by 赵翔宇 on 2024/11/16.
//

import Orb
import SwiftUI

struct MainTabbar: View {
    @ObservedObject private var vm = MainViewModel.shared
    @State var showToolsList: Bool = false
    @State var showTools: Bool = false
//    @ObservedObject private var userManager = UserManager.shared

    var body: some View {
        VStack(alignment: .center, spacing: 12, content: {
            inputbar
                .zIndex(32)
                .ifshow(show: showToolsList == false)
            tabbar
        })
        .background(alignment: .bottom) {
            bottomBlurGradient
                .offset(x: 0, y: 120)
        }
        .transition(.asymmetric(insertion: .opacity.animation(.easeInOut), removal: .movingParts.move(edge: .bottom).combined(with: .opacity).animation(.linear(duration: 0.3))))
        .frame(maxHeight: .infinity, alignment: .bottom)
        .overlay(alignment: .top) {
            toolList
        }
        .onChange(of: self.showToolsList) { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.showTools = value
            }
        }
    }

    var toolList: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 16) {
                Text("选择工具")
                    .font(.XMFont.f1b.v1)
                    .fcolor(.white)
                ForEach(AITool.allCases, id: \.self) { tool in
                    if let index = AITool.allCases.firstIndex(of: tool) {
                        toolRow(tool)
                            .transition(.movingParts.move(edge: .trailing).combined(with: .opacity).animation(.smooth.delay(Double(index) * 0.1)))
                            .animation(.smooth, value: self.showTools)
                            .ifshow(show: showTools)
                    }
                }
                Spacer().height(120)
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [Color.xm.b1, Color.xm.b1, .clear], startPoint: .bottom, endPoint: .top).frame(height: 240)
                .offset(x: 0, y: 80)
                .frame(maxWidth: .infinity)
                .transition(.opacity.animation(.smooth))
                .ifshow(show: showTools)
        }
        .overlay(alignment: .bottom) {
            XMDesgin.CircleBtn(backColor: .xm.b2, fColor: .xm.f1, iconName: "arrow_down", enable: true) {
                withAnimation {
                    self.showToolsList = false
                }
            }
            .rotationEffect(.init(degrees: -90))
            .transition(.move(edge: .bottom).animation(.smooth.delay(1)))
            .ifshow(show: showTools)
        }
        .transition(.asymmetric(insertion: .opacity, removal: .movingParts.move(edge: .bottom).combined(with: .opacity)))
        .ifshow(show: showToolsList)
    }

    func toolRow(_ tool: AITool) -> some View {
        HStack {
            LinearGradient(colors: tool.orb.backgroundColors, startPoint: .bottomLeading, endPoint: .topTrailing)
                .frame(width: 32, height: 32)
                .mask {
                    XMDesgin.XMIcon(iconName: tool.icon, size: 28, color: .xm.f1, withBackCricle: false, backColor: .clear, renderingMode: .template)
                }
                .padding(.leading, 12)

            Spacer()
        }
        .padding(.all, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.xm.b2)
)
        .overlay(alignment: .center) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1)
                .fcolor(.xm.f3)
                .opacity(0.3)
        }
        .overlay(alignment: .center) {
            Text(tool.name)
                .foregroundColor(.xm.f1)
                .font(.XMFont.f1b.v1)
        }
    }

    var inputbar: some View {
        HStack(spacing: 12) {
            orb
            VStack(alignment: .leading, spacing: 2) {
                Text("需要我做什么？")
                    .font(.XMFont.f2.v1)
                    .fcolor(.xm.f1)
                Text("随时开始一项任务")
                    .font(.XMFont.f3.v1)
                    .fcolor(.xm.f2)
            }
            Spacer()
            HStack(alignment: .center, spacing: 6) {
                
                XMDesgin.XMButton {
                    withAnimation {
                        showToolsList = true
                    }
                } label: {
                    TimelineView(.animation(minimumInterval: 1)) { timeline in
                        let orbs = [
                            ORB().mysticOrb,
                            ORB().natureOrb, 
                            ORB().sunsetOrb,
                            ORB().oceanOrb,
                            ORB().minimalOrb,
                            ORB().cosmicOrb,
                            ORB().fireOrb,
                            ORB().arcticOrb,
                            ORB().shadowOrb
                        ]
                        let randomOrb = orbs.randomElement() ?? ORB().arcticOrb
                        LinearGradient(colors: randomOrb.backgroundColors, startPoint: .topLeading, endPoint: .bottom)
                            .frame(width: 32, height: 32)
                            .mask {
                                XMDesgin.XMIcon(iconName: "bolt", size: 24, color: .xm.f1, renderingMode: .template)
                            }
                            .animation(.easeInOut(duration: 0.5), value: randomOrb.backgroundColors)
                    }
                }

                XMDesgin.XMIcon(iconName: "add", size: 24, color: .xm.f1, renderingMode: .template)
            }
        }
        .padding(.all, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                )
        .overlay(alignment: .center) {
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1)
                .fcolor(.xm.f3)
        }
        .padding(.horizontal, 16)
    }

    var orb: some View {
        return OrbView(configuration: ORB().minimalOrb)
            .frame(width: 36, height: 36)
    }

    let date = Date.now
    var tabbar: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(MainViewModel.TabbarItem.allCases, id: \.self) { item in
                tabbarItem(for: item)
            }
        }
    }

    private var bottomBlurGradient: some View {
        ZStack{
            RainbowLine()
                .blur(radius: 24)
                .drawingGroup()
                .equatable(by: true)
                .offset(x: 0, y: 80)
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(
                    VStack(spacing: 0) {
                        LinearGradient(colors: [.clear, .white], startPoint: .top, endPoint: .bottom)
                        Rectangle()
                            .fill(Color.white)
                    }
                )
                .frame(height: UIScreen.main.bounds.height * (showToolsList ? 1.74 : 0.42))
        }
   
    }

    private func tabbarItem(for item: MainViewModel.TabbarItem) -> some View {
        let selected = item == vm.currentTabbar
        let index = MainViewModel.TabbarItem.allCases.firstIndex(of: item) ?? 0
        let iconname = "tabbar_\(index)"
        return XMDesgin.XMButton(action: {
            withAnimation {
                vm.currentTabbar = item
            }
        }, label: {
            VStack(alignment: .center, spacing: 4) {
                XMDesgin.XMIcon(iconName: iconname, size: 24, color: selected ? .xm.f1 : .xm.f1.opacity(0.468), renderingMode: .template)
                Text(item.labelInfo.name)
                    .font(selected ? .XMFont.f3b.v1 : .XMFont.f3.v1)
                    .fcolor(selected ? .xm.f1 : .xm.f1.opacity(0.468))
            }
            .frame(maxWidth: .infinity, alignment: .center)

        })
    }
}

#Preview {
    MainView()
}

enum AITool: Int, CaseIterable {
    case construction = 1 // 建构
    case mathematics = 2 // 数学
    case webSearch = 3 // 联网搜索
    case localSearch = 4 // 本地检索
    case mindMap = 5 // 思维导图
    case translation = 6 // 翻译
    case summarize = 7 // 总结
    case brainstorm = 8 // 脑暴
    case critique = 9 // 批判

    var orb: OrbConfiguration {
        switch self {
        case .construction:
            return ORB().arcticOrb
        case .mathematics:
            return ORB().cosmicOrb
        case .webSearch:
            return ORB().fireOrb
        case .localSearch:
            return ORB().minimalOrb
        case .mindMap:
            return ORB().mysticOrb
        case .translation:
            return ORB().natureOrb
        case .summarize:
            return ORB().oceanOrb
        case .brainstorm:
            return ORB().shadowOrb
        case .critique:
            return ORB().sunsetOrb
        }
    }

    var name: String {
        switch self {
        case .construction:
            return "建构"
        case .mathematics:
            return "数学"
        case .webSearch:
            return "联网搜索"
        case .localSearch:
            return "本地检索"
        case .mindMap:
            return "思维导图"
        case .translation:
            return "翻译"
        case .summarize:
            return "总结"
        case .brainstorm:
            return "脑暴"
        case .critique:
            return "批判"
        }
    }

    var icon: String {
        switch self {
        case .construction:
            return "ai_tools_1"
        case .mathematics:
            return "ai_tools_2"
        case .webSearch:
            return "ai_tools_3"
        case .localSearch:
            return "ai_tools_4"
        case .mindMap:
            return "ai_tools_5"
        case .translation:
            return "ai_tools_6"
        case .summarize:
            return "ai_tools_7"
        case .brainstorm:
            return "ai_tools_8"
        case .critique:
            return "ai_tools_9"
        }
    }
}
