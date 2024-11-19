//
//  MasterPanelView.swift
//  DreamPaper
//
//  控制面板视图,用于控制相机动作

import Orb
import SwiftUI
import TipKit

// 定义相机动作枚举,包含9种基本动作
enum CameraAction: String, CaseIterable {
    case none = "无"
    case upShake = "上摇"
    case fixed = "固定机位" 
    case rightMove = "右移"
    case pull = "拉镜头"
    case downShake = "下摇"
    case closeup = "大特写"
    case leftMove = "左移"
    case push = "推镜头"
    
    // 每个动作对应的标准化坐标位置
    var position: CGPoint {
        switch self {
        case .none: return .init()
        case .rightMove: return CGPoint(x: 1.000, y: 0.500)  // 右侧中点
        case .pull: return CGPoint(x: 0.853, y: 0.853)       // 右下角
        case .downShake: return CGPoint(x: 0.500, y: 1.000)  // 底部中点
        case .closeup: return CGPoint(x: 0.147, y: 0.853)    // 左下角
        case .leftMove: return CGPoint(x: 0.000, y: 0.500)   // 左侧中点
        case .push: return CGPoint(x: 0.147, y: 0.147)       // 左上角
        case .upShake: return CGPoint(x: 0.500, y: 0.000)    // 顶部中点
        case .fixed: return CGPoint(x: 0.853, y: 0.147)      // 右上角
        }
    }
}

struct MasterPanelView: View {
    // MARK: - 属性

    // 新手引导提示
    private let getStartedTip = GetStartedTip()
    
    // 控制面板宽度,左右各留32点边距
    private var modelWidth: CGFloat {
        UIScreen.main.bounds.width - 32 * 2
    }

    // 控制面板高度,保持4:3比例
    private var modelHeight: CGFloat {
        modelWidth * 3 / 4
    }

    // 网格相关常量
    private let gridSize = 40
    private let dotSize: CGFloat = 2
    private let spacing: CGFloat = 20
    private let thresholdDistance: CGFloat = 75
    
    // 回调函数,用于每毫秒触发相机动作
    let addActionPerMSec : (CameraAction) -> Void
    
    // 环境变量和状态属性
    @Environment(\.colorScheme) var colorScheme
    @State private var isDragging = false
    @Binding var targetAction: CameraAction
    @State private var timer: Timer?
    
    // 控制旋钮位置
    @State var knobPosition: CGPoint
    
    // 根据暗黑模式切换圆点颜色
    var circleColor: Color {
        return colorScheme == .dark ? .white : .black
    }
    
    // MARK: - 初始化方法

    init(targetAction: Binding<CameraAction>,addActionPerMSec:@escaping (CameraAction) -> ()) {
        self.addActionPerMSec = addActionPerMSec
        self._targetAction = targetAction
        
        // 初始化旋钮位置在中心点
        let width = UIScreen.main.bounds.width - 32 * 2
        let height = width * 3 / 4
        _knobPosition = State(initialValue: CGPoint(
            x: width / 2,
            y: height / 2
        ))
    }
    
    // MARK: - 主视图

    var body: some View {
        ZStack {
            backgroundContainer
            dotsGrid
            crosshair
            yAxisLabels
            xAxisLabels
            quadrantLabels
            controlKnob
        }
        .frame(width: modelWidth, height: modelHeight)
        .font(.caption2)
        .fontDesign(.monospaced)
        .onChange(of: targetAction) { newValue in
            if newValue != .none {
                // 如果已有定时器先停止
                timer?.invalidate()
                // 创建新定时器,每5毫秒执行一次动作
                timer = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { _ in
                    self.addActionPerMSec(self.targetAction)
                }
            } else {
                // 停止定时器
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    // MARK: - 视图组件
    
    // 背景容器 - 带渐变边框和内阴影的圆角矩形
    private var backgroundContainer: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color(hex: "282828"))
            .frame(width: modelWidth, height: modelHeight)
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
    
    // 网格点阵 - 动态响应旋钮拖动的点阵网格
    private var dotsGrid: some View {
        GeometryReader { _ in
            let rows = Int(modelHeight / spacing)
            let cols = Int(modelWidth / spacing)
            
            ZStack {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        Circle()
                            .fill(circleColor.opacity(dotOpacity(row: row, col: col)))
                            .frame(width: dotSize, height: dotSize)
                            .position(self.dotPosition(row: row, col: col))
                    }
                }
            }
            .background(Color.clear)
            .padding(11)
        }
    }
    
    // 十字准星 - 中心点辅助线
    private var crosshair: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .clear, circleColor.opacity(0.24), .clear, .clear], startPoint: .leading, endPoint: .trailing))
                .frame(width: modelWidth, height: 1)
                
            Rectangle()
                .fill(LinearGradient(colors: [.clear, .clear, circleColor.opacity(0.24), .clear, .clear], startPoint: .top, endPoint: .bottom))
                .frame(width: 1, height: modelHeight)
        }
    }
    
    // Y轴标签 - 显示上下摇动动作
    private var yAxisLabels: some View {
        VStack {
            makeActionLabel(action: .upShake)
            Spacer()
            makeActionLabel(action: .downShake)
        }
        .padding()
        .frame(width: modelWidth, height: modelHeight)
    }
    
    // X轴标签 - 显示左右移动动作
    private var xAxisLabels: some View {
        HStack {
            makeActionLabel(action: .leftMove)
            Spacer()
            makeActionLabel(action: .rightMove)
        }
        .padding()
        .frame(width: modelWidth, height: modelHeight)
    }
    
    // 象限标签 - 显示四个角落的动作
    private var quadrantLabels: some View {
        Group {
            makeActionLabel(action: .push)
                .position(x: modelWidth * 0.25, y: modelHeight * 0.25)
            makeActionLabel(action: .fixed)
                .position(x: modelWidth * 0.75, y: modelHeight * 0.25)
            makeActionLabel(action: .closeup)
                .position(x: modelWidth * 0.25, y: modelHeight * 0.75)
            makeActionLabel(action: .pull)
                .position(x: modelWidth * 0.75, y: modelHeight * 0.75)
        }
    }
    
    // 动作标签生成器 - 根据当前选中状态显示不同样式
    private func makeActionLabel(action: CameraAction) -> some View {
        Text(action.rawValue)
            .foregroundStyle(targetAction == action ? .primary : .secondary)
            .fontWeight(targetAction == action ? .bold : .regular)
            .scaleEffect(targetAction == action ? 1.6 : 1.0)
    }
    
    // 控制旋钮 - 可拖动的圆形控制器
    private var controlKnob: some View {
        let minimalOrb = OrbConfiguration(
            backgroundColors: [.gray, .white],
            glowColor: .white,
            showWavyBlobs: false,
            showParticles: false,
            speed: 30
        )
        
        return OrbView(configuration: minimalOrb)
            .frame(width: 40, height: 40)
            .popoverTip(getStartedTip)
            .position(knobPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        getStartedTip.invalidate(reason: .actionPerformed)
                        withAnimation(.easeOut(duration: 0.1)) {
                            knobPosition = CGPoint(
                                x: max(0, min(modelWidth, value.location.x)),
                                y: max(0, min(modelHeight, value.location.y))
                            )
                            calculateGenre()
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.bouncy) {
                            knobPosition = CGPoint(
                                x: modelWidth / 2,
                                y: modelHeight / 2
                            )
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.bouncy) {
                                isDragging = false
                            }
                        }
                        targetAction = .none
                    }
            )
    }
    
    // MARK: - 辅助方法
    
    // 计算网格点的初始位置
    private func initialDotPosition(row: Int, col: Int) -> CGPoint {
        CGPoint(x: CGFloat(col) * spacing, y: CGFloat(row) * spacing)
    }
    
    // 计算网格点的实时位置 - 根据旋钮位置产生吸引效果
    private func dotPosition(row: Int, col: Int) -> CGPoint {
        guard isDragging else {
            return initialDotPosition(row: row, col: col)
        }
        
        let fingerPosition = knobPosition
        let dotPos = initialDotPosition(row: row, col: col)
        let distance = hypot(dotPos.x - fingerPosition.x + 10, dotPos.y - fingerPosition.y + 10)
        
        if distance < thresholdDistance {
            let offsetFactor = (thresholdDistance - distance) / thresholdDistance
            let direction = CGPoint(x: (fingerPosition.x - dotPos.x) * offsetFactor,
                                    y: (fingerPosition.y - dotPos.y) * offsetFactor)
            return CGPoint(x: dotPos.x + direction.x, y: dotPos.y + direction.y)
        } else {
            return dotPos
        }
    }
    
    // 计算网格点的透明度 - 距离旋钮越近越不透明
    private func dotOpacity(row: Int, col: Int) -> Double {
        guard isDragging else {
            return 0.1
        }
        
        let fingerPosition = knobPosition
        let dotPos = initialDotPosition(row: row, col: col)
        let distance = hypot(dotPos.x - fingerPosition.x + 10, dotPos.y - fingerPosition.y + 10)
        let opacityFactor = max(0.1, min(1.0, (thresholdDistance - distance) / thresholdDistance))
        return opacityFactor
    }
    
    // 根据旋钮位置计算最近的动作类型
    private func calculateGenre() {
        let normalizedKnobPosition = CGPoint(
            x: knobPosition.x / modelWidth,
            y: knobPosition.y / modelHeight
        )
        
        let closestAction = CameraAction.allCases.min { action1, action2 in
            let distance1 = hypot(normalizedKnobPosition.x - action1.position.x,
                                  normalizedKnobPosition.y - action1.position.y)
            let distance2 = hypot(normalizedKnobPosition.x - action2.position.x,
                                  normalizedKnobPosition.y - action2.position.y)
            return distance1 < distance2
        }
        
        withAnimation {
            targetAction = closestAction ?? .none
        }
    }
}

#Preview {
    FilmView()
}
