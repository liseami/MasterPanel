//
//  XMTyperText.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/2.
//

import SwiftUI

struct XMTyperText: View {
    let text: String
    let madaOpen: Bool
    let duration: Double?
    var guangbiao: String {
        return currentIndex == text.count ? "" : " ●"
    }

    init(text: String, duration: Double? = nil, madaOpen: Bool = true) {
        self.text = text
        self.duration = duration
        self.madaOpen = madaOpen
    }

    init(_ text: String, duration: Double? = nil, madaOpen: Bool = true) {
        self.text = text
        self.duration = duration
        self.madaOpen = madaOpen
    }

    @State private var currentIndex: Int = 0

    @State var timer: Timer?

    func scheduleTimer() {
        let interval: TimeInterval
        if let duration = duration {
            // 限定表达时间。
            interval = duration / Double(text.count)
        } else {
            // 随机表达时间。
            interval = Double.random(in: 0.03 ... 0.07)
        }

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in

            if currentIndex < text.count {
                DispatchQueue.main.async {
                    currentIndex += 1
                    if madaOpen {
                        switch UserDefaults.standard.integer(forKey: "MadaLevel") {
                        case 2:
                            let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
                            impactFeedback.prepare()
                            impactFeedback.impactOccurred(intensity: 0.8)
                        case 1:
                            let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
                            impactFeedback.prepare()
                            impactFeedback.impactOccurred(intensity: 0.4)
                        case 0:
                            break
                        default:
                            break
                        }
                    }
                    scheduleTimer()
                }
            }
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text(LocalizedStringKey(String(text.prefix(currentIndex))))
                .contentTransition(.numericText())

//                +
//                Text(guangbiao)
        }
        .onAppear {
            scheduleTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

#Preview {
    XMTyperText(text: String.randomChineseString(length: 340))
        .padding(.all, 24)
}
