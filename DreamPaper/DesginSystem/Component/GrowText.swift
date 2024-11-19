import Combine
import SwiftUI

// GrowingTextView: 一个自定义的SwiftUI视图,用于逐字显示文本
struct GrowingTextView: View {
    let madaOpen: Bool // 是否启用触感反馈
    let duration: Double? // 可选的动画持续时间
    @Binding var text: String // 要显示的完整文本
    @State private var displayedText: String = "" // 当前显示的文本
    @State private var currentIndex: Int = 0 // 当前处理到的字符索引
    @State private var showCursor: Bool = true // 是否显示光标
    @State private var timer: AnyCancellable? // 用于控制文本显示速度的定时器
    @State private var cursorTimer: AnyCancellable? // 用于控制光标闪烁的定时器
    @State private var lastHapticTime: Date = .distantPast // 上次触感反馈的时间
    
    var isComplete: Bool {
        currentIndex >= text.count
    }
    
    // 初始化方法
    init(_ text: Binding<String>, duration: Double? = nil, madaOpen: Bool = true) {
        self._text = text
        self.duration = duration
        self.madaOpen = madaOpen
    }
    
    // 设置定时器以控制文本显示速度
    private func scheduleTimer() {
        timer?.cancel() // 取消现有的定时器
        
        guard !isComplete else {
            cursorTimer?.cancel()
            return // 如果已经显示完所有文本,则退出
        }
        
        let interval: TimeInterval
        if let duration = duration {
            interval = duration / Double(text.count) // 如果指定了持续时间,则平均分配时间
        } else {
            interval = Double.random(in: 0.02 ... 0.03) // 否则使用随机间隔
        }
        // 创建并启动定时器
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if currentIndex < text.count {
                    // 添加下一个字符到显示文本中
                    let index = text.index(text.startIndex, offsetBy: currentIndex)
                    displayedText.append(text[index])
                    currentIndex += 1
                    
                    if madaOpen {
                        applyHapticFeedback() // 如果启用,则应用触感反馈
                    }
                    
                    scheduleTimer() // 递归调用以继续显示下一个字符
                } else {
                    timer?.cancel() // 显示完毕,取消定时器
                    cursorTimer?.cancel()
                }
            }
    }
    
    // 应用触感反馈
    private func applyHapticFeedback() {
        let now = Date()
        guard now.timeIntervalSince(lastHapticTime) >= 0.1 else { return } // 限制触感反馈的频率
        
        lastHapticTime = now
        let madaLevel = UserDefaults.standard.integer(forKey: "MadaLevel")
        switch madaLevel {
        case 2:
            Apphelper.shared.mada(style: .soft, intensity: 0.8) // 强度较高的触感
        case 1:
            Apphelper.shared.mada(style: .soft, intensity: 0.4) // 强度较低的触感
        default:
            break // 不应用触感
        }
    }
    
    // 启动光标闪烁效果
    private func startCursorBlink() {
        cursorTimer = Timer.publish(every: 0.3, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                showCursor.toggle() // 每0.3秒切换光标显示状态
            }
    }
    
    // 视图主体
    var body: some View {
        Group {
            Text(LocalizedStringKey(displayedText)) + // 显示当前文本
                Text(showCursor && currentIndex < (text.count) ? " ● " : " ") // 显示或隐藏光标
        }
        .onAppear {
            scheduleTimer() // 视图出现时启动文本显示
            startCursorBlink() // 开始光标闪烁
        }
        .onChange(of: text) { newValue in
            if newValue.hasPrefix(displayedText) {
                // 如果新文本以当前显示的文本开头,则从当前位置继续
                currentIndex = displayedText.count
            } else {
                // 如果是完全新的文本,则重新开始
                displayedText = ""
                currentIndex = 0
            }
            scheduleTimer() // 重新开始文本显示过程
        }
        .onDisappear {
            timer?.cancel() // 视图消失时取消所有定时器
            cursorTimer?.cancel()
        }
    }
}

// 用于测试GrowingTextView的视图
struct GrowingTextViewTest: View {
    @State var input: String = "今天天气真不错。" // 初始文本
    
    var body: some View {
        VStack {
            Button("增长") {
                input += String.random(ofLength: 120) // 点击按钮时添加随机文本
            }
            
            GrowingTextView($input) // 使用GrowingTextView显示文本
        }
    }
}

// 预览
#Preview {
    GrowingTextViewTest()
}
