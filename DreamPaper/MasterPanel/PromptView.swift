//
//  PromptView.swift
//  DreamPaper
//
//  Created by 赵翔宇 on 2024/11/18.
//

import SwiftUI

struct PromptView: View {
    @State private var text: String = ""
    @State private var timer: Timer?
    @State private var currentIndex: Int = 0
    
    let prompts = [
        "",
        "Vertical Tracking Shot | Slow Dolly Upward \n",
        "Maintain Active Dialogue Framing\n",
//        "Preserve Conversation Blocking\n",
//        "Camera Speed: 0.3-0.5x Normal Tracking Velocity\n",
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12, content: {
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    Text("Prompt")
                        .font(.XMFont.f1b.v1)
                        .fcolor(.white)
                    TextEditor(text:$text)
                        .scrollContentBackground(.hidden)
                        .tint(.white)
                        .fontDesign(.monospaced)
                        .contentTransition(.numericText())
                        .animation(.smooth, value: self.text)
                        .font(.XMFont.f1.v1)
                        .fcolor(.white)
                        .frame(maxWidth:.infinity, alignment: .leading)
                }
            }
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                startTimer()
            })
        }
        .onDisappear {
            stopTimer()
        }
        .height(320)
        .frame(maxWidth:.infinity)
        .padding(.horizontal,16)
        .padding(.top, 16)
        .background(backgroundContainer)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            guard currentIndex < prompts.count - 1 else {
                stopTimer()
                return
            }
            currentIndex = (currentIndex + 1) % prompts.count
            withAnimation {
                text += prompts[currentIndex]
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 背景容器
    private var backgroundContainer: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color(hex: "282828"))
//            .frame(width: modelWidth, height: modelHeight)
            .overlay(
                ZStack {
                    // 外部描边渐变
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(lineWidth: 3)
                        .foregroundStyle(.linearGradient(.init(colors: [.init(hex: "4D4D4D"), .clear, .clear]), startPoint: .top, endPoint: .bottom))
                    
                    // 添加内阴影
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.23), lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: 0, y: 0)
                        .mask(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(LinearGradient(colors: [.white, .clear],
                                                     startPoint: .leading,
                                                     endPoint: .trailing))
                        )
                }
            )
            .shadow(color: .black.opacity(0.62), radius: 8, x: 0, y: 6)
    }
}

#Preview {
    FilmView()
}
