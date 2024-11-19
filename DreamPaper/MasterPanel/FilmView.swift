//
//  FilmView.swift
//  DreamPaper
//

import AVKit
import Foundation
import Orb
import SwiftUI
import UIKit

// MARK: - FilmView

/// 主视图控制器,负责电影播放和AI交互功能
struct FilmView: View {
    // MARK: - Properties
    
    // UI 状态管理
    @State private var initImage: UIImage? // 初始图片
    @State private var showInitImage = false // 是否显示初始图片
    @State private var isLoading = false // 加载状态
    @State private var showingDetails = false // 是否显示详情
    @State private var counter = 0 // 计数器,用于触发波纹效果
    @State private var origin = CGPoint(x: 0.5, y: 0.5) // 波纹起始点
    @State private var targetAction: CameraAction = .none // 当前相机动作
    @State private var movieIsRendering = false // 视频是否正在渲染
    @State private var selectedTab = 0 // 当前选中的标签页
    
    // 视频状态管理
    @State private var videoIndex = 0 // 当前视频索引
    @State private var avplayer = AVPlayer() // 视频播放器
    
    // AI 状态管理
    @State private var aiMessage = AIMessage(
        messageState: .waiting,
        message: "dfasdfasdfsadfasdfasdfasdfasdfasdfasasdf",
        timeLeft: 0
    )
    
    // 屏幕宽度常量
    let SW = UIScreen.main.bounds.width
    // 白色常量
    private let white = Color(hex: "E5E5E5")
    
    // 波浪控制器
    @Bindable private var controller = ComplexWaveController()
    private let date = Date()
    
    // 波浪控制器类
    @Observable
    fileprivate class ComplexWaveController {
        var speed: CGFloat = 0.3 // 波浪速度
        var frequency: CGFloat = 8 // 波浪频率
        var strength: CGFloat = 22 // 波浪强度
    }
    
    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundLayers // 背景层
            
            VStack(spacing: 12) {
                headerView // 顶部标题栏
                videoPlayerView // 视频播放器
                Spacer()
            }
            .blur(radius:selectedTab == 0 ? 0 : 12) // 非首页时添加模糊效果
            aiControlPanel // AI控制面板
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Background Views

    /// 背景层视图
    private var backgroundLayers: some View {
        ZStack {
            // 背景颜色
            Color(hex: "#1F1F1F").ignoresSafeArea()
                .modifier(RippleEffect(at: origin, trigger: counter))
            
            // 双层背景图片
            ForEach([100, -120], id: \.self) { offset in
                backgroundImageLayer(yOffset: offset)
                    .equatable(by: self.videoIndex)
            }
        }
    }
    
    /// 背景图片层
    private func backgroundImageLayer(yOffset: CGFloat) -> some View {
        Color.clear
            .edgesIgnoringSafeArea(.all)
            .background(
                TimelineView(.animation) { context in
                    let time = context.date.timeIntervalSince1970 - date.timeIntervalSince1970

                    Image("movie\(self.videoIndex)")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.9)
                        .grayscale(0.25)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .blur(radius: 44)
                        .offset(x: 0, y: yOffset)
                        .modifier(ComplexWaveModifierVFX(
                            controller: controller,
                            time: time
                        ))
                }
                .transition(.opacity.animation(.easeInOut(duration: 2)))
            )
            .modifier(RippleEffect(at: origin, trigger: counter))
    }
    
    /// 复杂波浪效果修饰器
    private struct ComplexWaveModifierVFX: ViewModifier {
        @Bindable var controller: ComplexWaveController
        var time: CGFloat
        
        func body(content: Content) -> some View {
            content
                .visualEffect { content, proxy in
                    content
                        .distortionEffect(
                            ShaderLibrary.complexWave(
                                .float(time),
                                .float(controller.speed),
                                .float(controller.frequency),
                                .float(controller.strength),
                                .float2(proxy.size)
                            ),
                            maxSampleOffset: .zero
                        )
                }
        }
    }
    
    // MARK: - Header View

    /// 顶部标题栏视图
    private var headerView: some View {
        Text("MasterPanel")
            .font(.custom("DotoRounded-Black", size: 32))
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Image("icons8-play-96")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 36, height: 36)
                    .foregroundColor(white)
                    .padding(.horizontal)
            }
    }
    
    // MARK: - AI Control Panel

    /// AI控制面板视图
    private var aiControlPanel: some View {
        VStack(alignment: .center, spacing: 20) {
            masterPanelView
        }
        .padding(.all, 16)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, self.selectedTab == 2 ? 56 :  12)
        .animation(.smooth, value: self.selectedTab)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    /// 主控制面板视图
    private var masterPanelView: some View {
        VStack(spacing: 16) {
            switch self.selectedTab {
            case 0:
                MasterPanelView(targetAction: $targetAction) { cameraAction in
                    handleCameraAction(cameraAction)
                }
                .onChange(of: targetAction) { _, newValue in
                    handleTargetActionChange(newValue)
                }
            case 1:
                CameraMoveView()
            case 2:
                PromptView()
            default: EmptyView()
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .padding(.all, 16)
        .background(masterPanelBackground)
    }
    
    /// 主控制面板背景
    private var masterPanelBackground: some View {
        ZStack {
            RainbowLine()
                .blur(radius: 12)
                .drawingGroup()
                .equatable(by: true)
                .frame(width: 320, height: 220)
                .rotationEffect(.degrees(-32))
                .offset(x: -70, y: -50)
                .blur(radius: 40)
            
            RoundedRectangle(cornerRadius: 32)
                .fill(.thinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(lineWidth: 3)
                .foregroundColor(white.opacity(0.14))
        )
    }
    
    // MARK: - Video Player Views

    /// 视频播放器视图
    private var videoPlayerView: some View {
        VStack(alignment: .center, spacing: 0) {
            mainVideoContent
            videoControlBar
        }
        .frame(width: SW)
    }
    
    /// 主视频内容视图
    private var mainVideoContent: some View {
        ZStack(alignment: .top) {
            if let initImage {
                initialImageView(image: initImage)
            } else {
                moviewPlaceHolder
            }
            
            if videoIndex > 0 {
                activeVideoPlayer
            }
            
            if movieIsRendering {
                renderingOverlay
            }
        }
        .frame(width: SW)
        .height(SW / 1280 * 768)
    }
    
    /// 初始图片视图
    private func initialImageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: SW)
            .height(SW / 1280 * 768)
            .clipped()
            .modifier(RippleEffect(at: origin, trigger: counter))
            .transition(.movingParts.move(edge: .bottom).combined(with: .scale(scale: 0.5)).animation(.smooth))
            .ifshow(show: showInitImage)
    }
    
    /// 活动视频播放器
    private var activeVideoPlayer: some View {
        VideoPlayer(player: avplayer)
            .frame(width: SW, height: SW / 1280 * 768)
            .scaleEffect(1.1, anchor: .top)
            .frame(width: SW, height: SW / 1280 * 768)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(colors: [Color.black, .clear], startPoint: .bottom, endPoint: .top)
                    .height(40)
            }
    }
    
    /// 渲染遮罩层
    private var renderingOverlay: some View {
        Group {
            let startDate = Date.now
            Rectangle()
                .fill(Color.black.opacity(0.3))
            TimelineView(.animation) { context in
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.white, lineWidth: 3)
                    .colorEffect(
                        ShaderLibrary.default.circleMesh(.boundingRect, .float(context.date.timeIntervalSince1970 - startDate.timeIntervalSince1970))
                    )
            }
        }
    }
    
    /// 视频控制栏
    private var videoControlBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(.black.opacity(0.3))
                .frame(height: 44)
            
            HStack(alignment: .center, spacing: 0) {
                ForEach(0 ... Int(videoIndex), id: \.self) { index in
                    Group {
                        if index == 0, initImage == nil {
                            EmptyView()
                        } else {
                            Image("movie\(index)")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 36)
                                .transition(.movingParts.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                Spacer()
            }
            .grayscale(0.7)
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 99)
                .fill(Color.white.gradient)
                .frame(width: 3, height: 44, alignment: .center)
                .offset(x: 12 + CGFloat(Double(videoIndex + 1) * 60 - 16), y: 0)
                .animation(.linear(duration: 5.5), value: self.videoIndex)
                .ifshow(show: self.initImage != nil)
        }
    }
    
    // MARK: - Movie Placeholder

    /// 视频占位符视图
    private var moviewPlaceHolder: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(Color(hex: "282828"))
            .height(SW / 1280 * 768)
            .overlay(alignment: .center) {
                photoSelectorButton
            }
    }
    
    /// 照片选择按钮
    private var photoSelectorButton: some View {
        XMDesgin.XMButton {
            presentPhotoSelector()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 80, height: 44, alignment: .center)
                    .foregroundStyle(Color(hex: "393939"))
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(lineWidth: 2.5)
                            .foregroundColor(.init(hex: "404040"))
                    }
                    .transition(.opacity.combined(with: .scale))
                Image(systemName: "plus")
                    .font(.title2)
                    
            }
        }
    }
    
    // MARK: - Methods

    /// 处理相机动作
    private func handleCameraAction(_ cameraAction: CameraAction) {
        aiMessage.timeLeft += 0.005
        print(cameraAction.rawValue)
    }
    
    /// 处理目标动作变化
    private func handleTargetActionChange(_ newValue: CameraAction) {
        if newValue == .none {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startRender()
            }
        } else {
            aiMessage.messageState = .waiting
            aiMessage.timeLeft = 0
        }
    }
    
    /// 显示照片选择器
    private func presentPhotoSelector() {
        Apphelper.shared.presentPanSheet(
            SinglePhotoSelector(allowsEditing: false) { image in
                handlePhotoSelection(image)
            }
            .colorScheme(.dark),
            style: .sheet
        )
    }
    
    /// 处理照片选择
    private func handlePhotoSelection(_ image: UIImage) {
        initImage = image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showInitImage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                counter += 1
            }
        }
    }
    
    /// 开始渲染
    private func startRender() {
        if videoIndex == 0 {
            handleInitialRender()
        } else {
            handleSubsequentRender()
        }
    }
    
    /// 处理初始渲染
    private func handleInitialRender() {
        aiMessage.message = "Smooth Lateral Dolly Pullback | Dialogue Composition Preserved..."
        aiMessage.messageState = .working
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            beginRenderingProcess()
        }
    }
    
    /// 处理后续渲染
    private func handleSubsequentRender() {
        aiMessage.messageState = .working
        aiMessage.message = videoIndex == 1 ? "Vertical Tracking Shot | Slow Dolly Upward...Maintain Active Dialogue Framing" : "A cinematic tornado of motion, spiraling into the secret universe of a single bloom..."
        beginRenderingProcess()
    }
    
    /// 开始渲染过程
    private func beginRenderingProcess() {
        movieIsRendering = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            videoIndex += 1
            counter += 1
            playVideo()
            movieIsRendering = false
        }
    }
    
    /// 播放视频
    private func playVideo() {
        if let url = Bundle.main.url(forResource: "\(videoIndex)", withExtension: "mp4") {
            avplayer = .init(url: url)
            avplayer.play()
            updateAIMessage()
        }
    }
    
    /// 更新AI消息
    private func updateAIMessage() {
        aiMessage.messageState = .complete
        aiMessage.timeLeft = 0
        aiMessage.message = "最后一帧已获取，可继续操作"
    }
}

// MARK: - Supporting Types

/// 电影数据模型
private struct MovieData {
    let id: String
    let title: String
    let releaseDate: String
    let poster: String
    let backdrop: String
    let overview: String
}

/// Orb配置扩展
private extension OrbConfiguration {
    static func cosmic(white: Color) -> OrbConfiguration {
        OrbConfiguration(
            backgroundColors: [.purple, .pink, .blue],
            glowColor: white,
            coreGlowIntensity: 1.5,
            speed: 90
        )
    }
}

#Preview {
    FilmView()
}

// MARK: - Custom Tab Bar

/// 自定义标签栏
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    private let tabs = ["镜头", "旋转", "特效"]
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, title in
                tabButton(for: title, at: index)
            }
        }
        .padding(.horizontal)
    }
    
    /// 标签按钮
    private func tabButton(for title: String, at index: Int) -> some View {
        let selected = selectedTab == index
        
        return Button {
            withAnimation(.smooth) {
                selectedTab = index
            }
        } label: {
            ZStack {
                if selected {
                    selectedBackground
                }
                tabIcon(for: title)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    /// 选中背景
    private var selectedBackground: some View {
        Capsule()
            .frame(width: 80, height: 44, alignment: .center)
            .foregroundStyle(Color(hex: "393939"))
            .overlay(alignment: .center) {
                Capsule()
                    .stroke(lineWidth: 2.5)
                    .foregroundColor(.init(hex: "404040"))
            }
            .transition(.opacity.combined(with: .scale))
    }
    
    /// 标签图标
    private func tabIcon(for title: String) -> some View {
        Image(iconName(for: title))
            .resizable()
            .renderingMode(.template)
            .frame(width: 24, height: 24, alignment: .center)
            .foregroundColor(.init(hex: "E5E5E5"))
    }
    
    /// 获取图标名称
    private func iconName(for title: String) -> String {
        switch title {
        case "镜头": return "111"
        case "旋转": return "222"
        default: return "333"
        }
    }
}
