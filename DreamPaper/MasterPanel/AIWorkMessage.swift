//
//  AIWorkMessage.swift
//  FilmFinder
//
//  Created by 赵翔宇 on 2024/11/15.
//
import Orb
import Pow
import SwiftUI

private extension OrbConfiguration {
    static func cosmic(white: Color) -> OrbConfiguration {
        OrbConfiguration(
            backgroundColors: [.purple, .pink, .blue],
            glowColor: white,
            coreGlowIntensity: 1.5,
            speed: 90
        )
    }

    // Nature
    static func natureOrb() -> OrbConfiguration { OrbConfiguration(
        backgroundColors: [.green, .mint, .teal],
        glowColor: .green,
        speed: 45
    ) }
}

enum MessageState {
    case working
    case complete
    case waiting
}

struct AIMessage {
    var messageState: MessageState = .waiting
    var message: String = "镜头平滑向右移动，保持稳定,同时添加一定的变焦效果..."
    var timeLeft: Double = 5
}

struct AIWorkMessage: View {
    private let white = Color(hex: "E5E5E5")
    
    @Binding var message: AIMessage
    init(message: Binding<AIMessage>) {
        self._message = message
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Group {
                switch message.messageState {
                case .working:
                    OrbView(configuration: .cosmic(white: white))
                        .frame(width: 24, height: 24)
                        .scaleEffect(1.53)
                case .waiting:
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 1)
                            .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 24, height: 24)
                            .foregroundColor(white.opacity(0.2))
                        
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
                case .complete:
                    OrbView(configuration:.natureOrb())
                        .frame(width: 24, height: 24)
                        .scaleEffect(1.53)
                }
            }
            .transition(.scale.combined(with: .opacity).animation(.smooth))
            
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
            XMTyperText(stateText)
                .font(.caption)
                .foregroundColor(.init(hex: "898989"))
            
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
    
    private var messageBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: "282828"))
            .overlay(messageOverlay)
    }
    
    private var messageOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
                .foregroundStyle(.linearGradient(.init(colors: [.init(hex: "4D4D4D"), .clear, .clear]), startPoint: .top, endPoint: .bottom))
            
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

#Preview {
    VStack(alignment: .center, spacing: 32) {
        AIWorkMessage(message: .constant(.init(messageState: .waiting, message: "镜头平滑向右移动，保持稳定镜头平动，保持稳定,同时添加一定的变焦效果...同时添加一定的变焦效果...", timeLeft: 4)))
        AIWorkMessage(message: .constant(.init(messageState: .working, message: "镜头平滑向右移动，保持稳定镜头平滑向右移动，时添加一定的变焦效果...", timeLeft: 3)))
        AIWorkMessage(message: .constant(.init(messageState: .complete, message: "镜头平滑向右移动，保持稳定,镜头平滑向右移动，保持稳定,同时添加一定的变焦效果......", timeLeft: 3)))
    }
    .padding(.horizontal)
}
