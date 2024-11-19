//
//  GenreSelectorView.swift
//  FilmFinder
//
//  Created by Todd Hamilton on 11/3/24.
//

import Orb
import SwiftUI
import TipKit

// 定义镜头动作枚举
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
    
    var position: CGPoint {
        switch self {
        case .none: return .init()
        case .rightMove: return CGPoint(x: 1.000, y: 0.500)
        case .pull: return CGPoint(x: 0.853, y: 0.853)
        case .downShake: return CGPoint(x: 0.500, y: 1.000)
        case .closeup: return CGPoint(x: 0.147, y: 0.853)
        case .leftMove: return CGPoint(x: 0.000, y: 0.500)
        case .push: return CGPoint(x: 0.147, y: 0.147)
        case .upShake: return CGPoint(x: 0.500, y: 0.000)
        case .fixed: return CGPoint(x: 0.853, y: 0.147)
        }
    }
}

struct GenreSelectorView: View {
    // MARK: - 属性

    private let getStartedTip = GetStartedTip()
    
    private var modelWidth: CGFloat {
        UIScreen.main.bounds.width - 32 * 2
    }

    private var modelHeight: CGFloat {
        modelWidth * 3 / 4 // 4:3比例
    }

    private let gridSize = 40
    private let dotSize: CGFloat = 2
    private let spacing: CGFloat = 20
    private let thresholdDistance: CGFloat = 75
    
//    let getMovieRecFromGroq: () -> Void
    let addActionPerMSec : (CameraAction) -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isDragging = false
    @Binding var targetAction: CameraAction
    @State private var timer: Timer?
//    @State var genreScores: [String: Double] = Dictionary(
//        uniqueKeysWithValues: CameraAction.allCases.map { ($0 , 0.0) }
//    )
//
    // 使用枚举定义的位置
//    @State var genreCenters: [String: CGPoint] = Dictionary(
//        uniqueKeysWithValues: CameraAction.allCases.map { ($0 , $0.position) }
//    )
    
    // 初始位置设置在中心点
    @State var knobPosition: CGPoint
    
    var circleColor: Color {
        return colorScheme == .dark ? .white : .black
    }
    
    // MARK: - 初始化方法

    init(targetAction: Binding<CameraAction>,addActionPerMSec:@escaping (CameraAction) -> ()) {
//        self.getMovieRecFromGroq = getMovieRecFromGroq
        self.addActionPerMSec = addActionPerMSec
        self._targetAction = targetAction
        
        // 初始化knob位置在中心点
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
                // 创建新定时器,每3毫秒执行一次
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
    
    // 背景容器
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
    
    // 网格点阵
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
    
    // 十字准星
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
    
    // Y轴标签
    private var yAxisLabels: some View {
        VStack {
            makeActionLabel(action: .upShake)
            Spacer()
            makeActionLabel(action: .downShake)
        }
        .padding()
        .frame(width: modelWidth, height: modelHeight)
    }
    
    // X轴标签
    private var xAxisLabels: some View {
        HStack {
            makeActionLabel(action: .leftMove)
            Spacer()
            makeActionLabel(action: .rightMove)
        }
        .padding()
        .frame(width: modelWidth, height: modelHeight)
    }
    
    // 象限标签
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
    
    private func makeActionLabel(action: CameraAction) -> some View {
        Text(action.rawValue)
            .foregroundStyle(targetAction == action ? .primary : .secondary)
            .fontWeight(targetAction == action ? .bold : .regular)
            .scaleEffect(targetAction == action ? 1.6 : 1.0)
    }
    
    // 控制旋钮
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
                            
//                            calculateGenreProximityScores()
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
//                        getMovieRecFromGroq()
                    }
            )
    }
    
    // MARK: - 辅助方法
    
    // 初始网格点位置
    private func initialDotPosition(row: Int, col: Int) -> CGPoint {
        CGPoint(x: CGFloat(col) * spacing, y: CGFloat(row) * spacing)
    }
    
    // 计算点的实时位置
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
    
    // 计算点的透明度
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
    
    // 计算最近的动作类型
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
    
//    // 计算每个动作的接近度分数
//    private func calculateGenreProximityScores() {
//        let normalizedKnobPosition = CGPoint(
//            x: knobPosition.x / modelWidth,
//            y: knobPosition.y / modelHeight
//        )
//
//        var scores: [String: Double] = [:]
//
//        for action in CameraAction.allCases {
//            let distance = hypot(normalizedKnobPosition.x - action.position.x,
//                               normalizedKnobPosition.y - action.position.y)
//            scores[action ] = max(0, 1 - distance)
//        }
//
//        withAnimation(.bouncy){
//            genreScores = scores
//        }
//    }
}

#Preview {
//    VStack(alignment: .center, spacing: 32, content: {
//        GenreSelectorView(getMovieRecFromGroq: {}, targetAction: .constant(.none))
//    })
//        .padding(.all, 12)
//        .background(RoundedRectangle(cornerRadius: 32)
//            .fill(.thinMaterial)
//            .overlay(
//                RoundedRectangle(cornerRadius: 32)
//                    .stroke(lineWidth: 3)
//                    .foregroundColor(.white.opacity(0.14))
//            )
//        )
    FilmView()
}
