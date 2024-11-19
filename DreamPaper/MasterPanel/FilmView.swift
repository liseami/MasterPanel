//
//  FilmView.swift
//  FilmFinder
//
//  Created by Todd Hamilton on 10/28/24.
//  55.55 CNY per Codeline
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
    
    // UI State
    @State private var initImage: UIImage?
    @State private var showInitImage = false
    @State private var isLoading = false
    @State private var showingDetails = false
    @State private var counter = 0
    @State private var origin = CGPoint(x: 0.5, y: 0.5)
    @State private var targetAction: CameraAction = .none
    @State private var movieIsRendering = false
    @State private var selectedTab = 0
    
    // Video State
    @State private var videoIndex = 0
    @State private var avplayer = AVPlayer()
    
    // AI State
    @State private var aiMessage = AIMessage(
        messageState: .waiting,
        message: "dfasdfasdfsadfasdfasdfasdfasdfasdfasasdf",
        timeLeft: 0
    )
    
    let SW = UIScreen.main.bounds.width
    // Constants
    private let white = Color(hex: "E5E5E5")
    
    @Bindable private var controller = ComplexWaveController()
    private let date = Date()
    @Observable
    fileprivate class ComplexWaveController {
        var speed: CGFloat = 0.3
        var frequency: CGFloat = 8
        var strength: CGFloat = 22
    }
    
    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundLayers
            
            VStack(spacing: 12) {
                headerView
                videoPlayerView
                Spacer()
            }
            .blur(radius:selectedTab == 0 ? 0 : 12)
            aiControlPanel
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Background Views

    private var backgroundLayers: some View {
        ZStack {
            Color(hex: "#1F1F1F").ignoresSafeArea()
                .modifier(RippleEffect(at: origin, trigger: counter))
            
            ForEach([100, -120], id: \.self) { offset in
                backgroundImageLayer(yOffset: offset)
                    .equatable(by: self.videoIndex)
            }
        }
    }
    
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

    private var aiControlPanel: some View {
        VStack(alignment: .center, spacing: 20) {
            AIWorkMessage(message: $aiMessage)
            masterPanelView
        }
        .padding(.all, 16)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, self.selectedTab == 2 ? 56 :  12)
        .animation(.smooth, value: self.selectedTab)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var masterPanelView: some View {
        VStack(spacing: 16) {
            switch self.selectedTab {
            case 0:
                GenreSelectorView(targetAction: $targetAction) { cameraAction in
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

    private var videoPlayerView: some View {
        VStack(alignment: .center, spacing: 0) {
            mainVideoContent
            videoControlBar
        }
        .frame(width: SW)
    }
    
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
//                                .transition(.movingParts.move(.leading).animation(.smooth(duration: 1)))
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

    private var moviewPlaceHolder: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(Color(hex: "282828"))
            .height(SW / 1280 * 768)
            .overlay(alignment: .center) {
                photoSelectorButton
            }
    }
    
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

    private func handleCameraAction(_ cameraAction: CameraAction) {
        aiMessage.timeLeft += 0.005
        print(cameraAction.rawValue)
    }
    
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
    
    private func presentPhotoSelector() {
        Apphelper.shared.presentPanSheet(
            SinglePhotoSelector(allowsEditing: false) { image in
                handlePhotoSelection(image)
            }
            .colorScheme(.dark),
            style: .sheet
        )
    }
    
    private func handlePhotoSelection(_ image: UIImage) {
        initImage = image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showInitImage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                counter += 1
            }
        }
    }
    
    private func startRender() {
        if videoIndex == 0 {
            handleInitialRender()
        } else {
            handleSubsequentRender()
        }
    }
    
    private func handleInitialRender() {
        aiMessage.message = "Smooth Lateral Dolly Pullback | Dialogue Composition Preserved..."
        aiMessage.messageState = .working
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            beginRenderingProcess()
        }
    }
    
    private func handleSubsequentRender() {
        aiMessage.messageState = .working
        aiMessage.message = videoIndex == 1 ? "Vertical Tracking Shot | Slow Dolly Upward...Maintain Active Dialogue Framing" : "A cinematic tornado of motion, spiraling into the secret universe of a single bloom..."
        beginRenderingProcess()
    }
    
    private func beginRenderingProcess() {
        movieIsRendering = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            videoIndex += 1
            counter += 1
            playVideo()
            movieIsRendering = false
        }
    }
    
    private func playVideo() {
        if let url = Bundle.main.url(forResource: "\(videoIndex)", withExtension: "mp4") {
            avplayer = .init(url: url)
            avplayer.play()
            updateAIMessage()
        }
    }
    
    private func updateAIMessage() {
        aiMessage.messageState = .complete
        aiMessage.timeLeft = 0
        aiMessage.message = "最后一帧已获取，可继续操作"
    }
}

// MARK: - Supporting Types

private struct MovieData {
    let id: String
    let title: String
    let releaseDate: String
    let poster: String
    let backdrop: String
    let overview: String
}

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
    
    private func tabIcon(for title: String) -> some View {
        Image(iconName(for: title))
            .resizable()
            .renderingMode(.template)
            .frame(width: 24, height: 24, alignment: .center)
            .foregroundColor(.init(hex: "E5E5E5"))
    }
    
    private func iconName(for title: String) -> String {
        switch title {
        case "镜头": return "111"
        case "旋转": return "222"
        default: return "333"
        }
    }
}
