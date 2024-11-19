//
//  CameraMoveView.swift
//  DreamPaper
//
//  Created by 赵翔宇 on 2024/11/17.
//

import Orb
import SwiftUI
struct CameraMoveView: View {
    @State private var position: CGPoint = .zero
    @State private var xValue: Float = 0
    @State private var yValue: Float = 0
    @State private var zoom: Float = 0
    @State private var roll: Float = 0
    var zoomRange: ClosedRange<Float> = -0.9 ... 0.9
    var rollRange: ClosedRange<Float> = -30 ... 30
    var xRange: ClosedRange<Float> = -100.0 ... 100.0
    var yRange: ClosedRange<Float> = -100.0 ... 100.0
    let mysticOrb = OrbConfiguration(
        backgroundColors: [.purple, .blue, .indigo],
        glowColor: .purple,
        coreGlowIntensity: 1.2
    )
    var body: some View {
        ZStack {
            VStack(spacing: 120) {
                moview
                HStack(spacing: 24) {
                    ZStack {
                        WheelControl(value: $xValue, range: xRange, orientation: .horizontal)
                            .frame(width: 160, height: 24)

                        WheelControl(value: $yValue, range: yRange, orientation: .vertical)
                            .frame(width: 24, height: 160)

                        OrbView(configuration: mysticOrb)
                            .frame(width: 32, height: 32)
                            .scaleEffect(1.53)
                            .blur(radius: 5)
                    }
                    .background {
                        dotsGrid
                            .clipShape(Circle())
                    }
                    .background(backgroundContainer)
                    .overlay(alignment: .bottom) {
                        Text("pan-tilt")
                            .offset(x: 0, y: 32)
                    }

                    WheelControl(value: $zoom, range: zoomRange, orientation: .vertical)
                        .frame(width: 24, height: 132)
                        .padding(.all, 12)
                        .background(rotationBack(CGFloat(self.zoom)))
                        .overlay(alignment: .bottom) {
                            Text("zoom")
                                .offset(x: 0, y: 35)
                        }

                    WheelControl(value: $roll, range: rollRange, orientation: .vertical)
                        .frame(width: 24, height: 132)
                        .padding(.all, 12)
                        .background(rotationBack(CGFloat(self.roll)))
                        .overlay(alignment: .bottom) {
                            Text("roll")
                                .offset(x: 0, y: 35)
                        }
                }
            }
            .maxWidth(.infinity)
            .padding(.top, 44)
            .padding(.bottom, 32)
            .padding(.vertical, 44)
        }
//        .frame(width: modelWidth, height: modelHeight)
        .font(.caption2)
        .fontDesign(.monospaced)
    }

    private var dotsGrid: some View {
        GeometryReader { _ in
            let rows = Int(160 / 20)
            let cols = Int(240 / 20)

            ZStack {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        Circle()
//                            .fill(circleColor.opacity(dotOpacity(row: row, col: col)))
                            .frame(width: 2, height: 2)
                            .position(self.dotPosition(row: row, col: col))
                            .opacity(0.3)
                    }
                }
            }
            .background(Color.clear)
            .padding(11)
        }
    }

    // 初始网格点位置
    private func initialDotPosition(row: Int, col: Int) -> CGPoint {
        CGPoint(x: CGFloat(col) * 20, y: CGFloat(row) * 20)
    }

    private func dotPosition(row: Int, col: Int) -> CGPoint {
        return initialDotPosition(row: row, col: col)
    }

    var moview: some View {
        ZStack {
            Image("movie2")
                .resizable()
                .scaledToFill()
                .frame(width: 238, height: 238 / 1280 * 768, alignment: .center)
                .clipped()

            // 第三个方块 (底层, 偏移量为 position 的 1/3)
            MovementRectangle(position: CGPoint(
                x: position.x / 6,
                y: position.y / 6
            ), axisX: CGFloat(self.xValue / 6), axisY: CGFloat(self.yValue / 6), zoom: CGFloat(self.zoom / 6), roll: CGFloat(self.roll / 6))

            // 第三个方块 (底层, 偏移量为 position 的 1/3)
            MovementRectangle(position: CGPoint(
                x: position.x / 3,
                y: position.y / 3
            ), axisX: CGFloat(self.xValue / 3), axisY: CGFloat(self.yValue / 3), zoom: CGFloat(self.zoom / 3), roll: CGFloat(self.roll / 3))

            // 第二个方块 (中层, 偏移量为 position 的 2/3)
            MovementRectangle(position: CGPoint(
                x: position.x * 2 / 3,
                y: position.y * 2 / 3
            ), axisX: CGFloat(self.xValue * 2 / 3), axisY: CGFloat(self.yValue * 2 / 3), zoom: CGFloat(self.zoom * 2 / 3), roll: CGFloat(self.roll * 2 / 3))

            // 第一个方块 (顶层, 完整偏移量)
            MovementRectangle(position: position,
                              axisX: CGFloat(self.xValue), axisY: CGFloat(self.yValue), showIcon: true, zoom: CGFloat(self.zoom / 1), roll: CGFloat(self.roll))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let frameWidth: CGFloat = 238
                            let frameHeight: CGFloat = 238 / 1280 * 768

                            position = CGPoint(
                                x: value.location.x - frameWidth / 2,
                                y: value.location.y - frameHeight / 2
                            )
                        }
                )
        }
    }

    // 背景容器
    var backgroundContainer: some View {
//        RoundedRectangle(cornerRadius: 25)
        Circle()
            .fill(Color(hex: "282828"))
            ////            .frame(width: modelWidth, height: modelHeight)
            .overlay(
                ZStack {
                    // 外部描边渐变
                    Circle()
//                    RoundedRectangle(cornerRadius: 25)
                        .stroke(lineWidth: 3)
                        .foregroundStyle(.linearGradient(.init(colors: [.init(hex: "4D4D4D"), .clear, .clear]), startPoint: .top, endPoint: .bottom))

                    // 添加内阴影
                    Circle()
//                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.23), lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: 0, y: 0)
                        .mask(
                            Circle()
                                .fill(LinearGradient(colors: [.white, .clear],
                                                     startPoint: .leading,
                                                     endPoint: .trailing))
                        )
                }
            )
            .shadow(color: .black.opacity(0.62), radius: 8, x: 0, y: 6)
    }

    func rotationBack(_ v: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(hex: "282828"))
            .overlay(
                ZStack {
                    // 外部描边渐变
                    RoundedRectangle(cornerRadius: 6)
//                    RoundedRectangle(cornerRadius: 25)
                        .stroke(lineWidth: 3)
                        .foregroundStyle(.linearGradient(.init(colors: [.init(hex: "4D4D4D"), .clear, .clear]), startPoint: .top, endPoint: .bottom))
                        .changeEffect(.glow(color: .white.opacity(0.618)), value: v)

                    // 添加内阴影
                    RoundedRectangle(cornerRadius: 6)
//                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.23), lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: 0, y: 0)
                        .mask(
                            Circle()
                                .fill(LinearGradient(colors: [.white, .clear],
                                                     startPoint: .leading,
                                                     endPoint: .trailing))
                        )
                }
            )
            .shadow(color: .black.opacity(0.62), radius: 8, x: 0, y: 6)
    }
}

// 抽取方块视图为独立组件
struct MovementRectangle: View {
    let position: CGPoint
    let axisX: CGFloat
    let axisY: CGFloat
    var showIcon: Bool = false
    var zoom: CGFloat
    var roll: CGFloat

    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.22))
            .frame(width: 238, height: 238 / 1280 * 768, alignment: .center)
            .overlay(alignment: .center) {
                Rectangle()
                    .stroke(lineWidth: 1)
                    .frame(width: 238, height: 238 / 1280 * 768, alignment: .center)
                    .foregroundColor(.white)
            }
            .overlay(alignment: .center) {
                XMDesgin.XMIcon(systemName: "camera", size: 24, color: .white, withBackCricle: false, backColor: .clear)
                    .ifshow(show: showIcon)
            }
            .offset(x: position.x, y: position.y)
            // 修改这里的旋转实现
            .rotation3DEffect(.degrees(axisX / 100 * 30), axis: (x: 0, y: 1, z: 0)) // 围绕Y轴旋转
            .rotation3DEffect(.degrees(axisY / 100 * 30), axis: (x: 1, y: 0, z: 0)) // 围绕X轴旋转
            .scaleEffect(1 + zoom)
            .rotationEffect(.init(degrees: roll))
    }
}

#Preview {
    FilmView()
}
