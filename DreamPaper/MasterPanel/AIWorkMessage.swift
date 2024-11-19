//
//  AIWorkMessage.swift
//  DreamPaper
//  AI工作状态消息视图

import Orb
import Pow
import SwiftUI

// MARK: - Orb配置扩展
private extension OrbConfiguration {
    // 宇宙风格Orb配置
    static func cosmic(white: Color) -> OrbConfiguration {
        OrbConfiguration(
            backgroundColors: [.purple, .pink, .blue], // 背景渐变色
            glowColor: white,                         // 发光颜色
            coreGlowIntensity: 1.5,                  // 核心发光强度
            speed: 90                                 // 动画速度
        )
    }

    // 自然风格Orb配置
    static func natureOrb() -> OrbConfiguration { 
        OrbConfiguration(
            backgroundColors: [.green, .mint, .teal], // 自然色系背景
            glowColor: .green,                       // 绿色发光
            speed: 45                                // 中等速度
        ) 
    }
}

// MARK: - 消息状态枚举
enum MessageState {
    case working  // 工作中
    case complete // 已完成
    case waiting  // 等待中
}

// MARK: - AI消息数据模型
struct AIMessage {
    var messageState: MessageState = .waiting
    var message: String = "镜头平滑向右移动，保持稳定,同时添加一定的变焦效果..."
    var timeLeft: Double = 5
}

// MARK: - AI工作消息视图
struct AIWorkMessage: View {
    private let white = Color(hex: "E5E5E5")  // 白色主题色
    
    @Binding var message: AIMessage
    init(message: Binding<AIMessage>) {
        self._message = message
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // 状态指示器
            Group {
                switch message.messageState {
                case .working:  // 工作中状态显示宇宙风格动画
                    OrbView(configuration: .cosmic(white: white))
                        .frame(width: 24, height: 24)
                        .scaleEffect(1.53)
                case .waiting:  // 等待状态显示倒计时圆环
                    ZStack {
                        // 背景圆环
                        Circle()
                            .trim(from: 0, to: 1)
                            .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 24, height: 24)
                            .foregroundColor(white.opacity(0.2))
                        
                        // 进度圆环
                        Circle()
                            .trim(from: 0, to: message.timeLeft / 10)
                            .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 24, height: 24)
                            .foregroundColor(white)
                    }
                    .changeEffect(.spray({
                        Text("+1 S")
                            .bold()
                            .font(.caption)
                            .fcolor(.white)
                    }), value: self.message.timeLeft.truncatingRemainder(dividingBy: 1) == 0)
                case .complete:  // 完成状态显示自然风格动画
                    OrbView(configuration:.natureOrb())
                        .frame(width: 24, height: 24)
                        .scaleEffect(1.53)
                }
            }
            .transition(.scale.combined(with: .opacity).animation(.smooth))
            
            // 消息文本区域
            if self.message.messageState == .waiting {
                Text(message.message)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .redacted(reason: .placeholder)
                    .conditionalEffect(.repeat(.shine(duration: 0.3), every: 0.3), condition: true)
            }else{
                XMTyperText(message.message)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
                
            Spacer()
            
            // 状态文本
            XMTyperText(stateText)
                .font(.caption)
                .foregroundColor(.init(hex: "898989"))
            
            // 状态指示点
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(color)
                .shadow(color: color, radius: 3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(messageBackground)
    }
    
    // 状态文本
    private var stateText: String {
        switch message.messageState {
        case .working:
            return "Working..."
        case .complete:
            return "Complete"
        case .waiting:
            return "Waiting..."
        }
    }
    
    // 状态颜色
    private var color: Color {
        switch message.messageState {
        case .working:
            return Color.orange
        case .complete:
            return Color.green
        case .waiting:
            return Color.white
        }
    }
    
    // 消息背景
    private var messageBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: "282828"))
            .overlay(messageOverlay)
    }
    
    // 消息边框装饰
    private var messageOverlay: some View {
        ZStack {
            // 顶部渐变描边
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
                .foregroundStyle(.linearGradient(.init(colors: [.init(hex: "4D4D4D"), .clear, .clear]), startPoint: .top, endPoint: .bottom))
            
            // 内发光效果
            RoundedRectangle(cornerRadius: 16)
                .stroke(white.opacity(0.23), lineWidth: 2)
                .blur(radius: 2)
                .mask(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [white, .clear],
                                             startPoint: .leading,
                                             endPoint: .trailing))
                )
        }
    }
}

// MARK: - 预览
#Preview {
    VStack(alignment: .center, spacing: 32) {
        AIWorkMessage(message: .constant(.init(messageState: .waiting, message: "镜头平滑向右移动，保持稳定镜头平动，保持稳定,同时添加一定的变焦效果...同时添加一定的变焦效果...", timeLeft: 4)))
        AIWorkMessage(message: .constant(.init(messageState: .working, message: "镜头平滑向右移动，保持稳定镜头平滑向右移动，时添加一定的变焦效果...", timeLeft: 3)))
        AIWorkMessage(message: .constant(.init(messageState: .complete, message: "镜头平滑向右移动，保持稳定,镜头平滑向右移动，保持稳定,同时添加一定的变焦效果......", timeLeft: 3)))
    }
    .padding(.horizontal)
}
