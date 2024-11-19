//
//  LaunchScreenAnimation.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/26.
//

struct LaunchScreenAnimation: View {
    @State private var timer: AnyCancellable? = nil
    @State private var progress: Double = 0
    @State private var year: Double = .init(Date.now.year)

    private func startTimer() {
        let totalDuration = 1.89 // 总时长为2.5秒
        let progressIncrement = 1.0 / (totalDuration / 0.01) // 每0.01秒增加的进度
        let yearDecrement = Double((2023 - 2000) / ((totalDuration - 0.5) / 0.01)) // 每0.01秒减少的年份

        timer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if progress < 1.0 {
                    withAnimation {
                        progress += progressIncrement // 逐渐增加进度
                    }
                }
                if year > 2000 {
                    year -= Double(yearDecrement) // 逐渐减少年份
                }
                if progress >= 1.0, year <= 1999 {
                    stopTimer()
                }
            }
    }

    private func stopTimer() {
        timer?.cancel()
    }

    var body: some View {
        ZStack {
            Image("login_back")
                .resizable()
                .scaledToFill()
                .height(UIScreen.main.bounds.height)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 12) {
                VStack(alignment: .center, spacing: 24) {
                    Image("Speech manager")
                        .resizable()
                        .frame(width: 56, height: 56)
                    Text("陌生人闹钟")
                        .font(.XMFont.big1.v1)
                }
                .width(UIScreen.main.bounds.width * 0.718)
                .padding(.vertical, 24)
                .background(
                    Color.xmb1
                        .addOS9Shadow(status: .凹)
                )
                .padding(.vertical)
                .padding(.horizontal)

                VStack(alignment: .center, spacing: 12) {
                    Text("正在回到\(Int(year).formatted())...")
                        .contentTransition(.numericText())
                        .font(.XMFont.f1.v1)
//                    SBProgressView(progress: progress)
//                        .frame(width: 200)
                }
            }
            .padding(.vertical, 16)

            .background(Color.xmb2
                .addOS9Shadow(status: .凸)
            )
        }
        .ignoresSafeArea()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .transition(.opacity.combined(with: .scale(scale: 12)).animation(.easeInOut(duration: 1)))
        .ifshow(show: progress < 1)
    }
}

#Preview {
    LaunchScreenAnimation()
}
