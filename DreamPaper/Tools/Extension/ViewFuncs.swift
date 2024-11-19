//
//  ViewFuncs.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/25.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect
import SwiftUIX
@_spi(Advanced) import SwiftUIIntrospect

// MARK: - TostaToShare

// 创建分享卡片的视图修饰器

struct TostaToShare<RenderContent: View>: ViewModifier where RenderContent: View {
    @State private var showShareCard: Bool = false
    @State private var showShareSheet: Bool = false

    @Binding var isScrolling: Bool
    var showText: Bool = false
    let renderContent: () -> RenderContent

    init(content: @escaping () -> RenderContent, isScrolling: Binding<Bool>, showText: Bool = false) {
        self.renderContent = content
        self._isScrolling = isScrolling
        self.showText = showText
    }

    func body(content: Content) -> some View {
        return content.toolbar {
            toolbar
        }
        .overlay(alignment: .top) {
            shareShowCardView
        }
        .background {
            renderView.opacity(0)
        }
    }

    @Weak var uiScrollView: UIScrollView?
    @MainActor
    var renderView: some View {
        ScrollView(.vertical) {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                renderContent()
            }
        }
        .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { scrollView in
            if self.uiScrollView == nil {
                self.uiScrollView = scrollView
            }
        }
        .environment(\.colorScheme, .light)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }

    var shareShowCardView: some View {
        ZStack(alignment: .top) {
            BlurEffectView(style: .systemThinMaterialLight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
                .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0.6)), removal: .opacity))
                .ifshow(show: showShareCard)
            renderContent()
                .scaleEffect(showShareSheet ? 0.747 : 1, anchor: .top)
                .transition(.asymmetric(insertion: .movingParts.move(edge: .bottom),
                                        removal: .movingParts.move(edge: .bottom).combined(with: .opacity)))
                .ifshow(show: showShareCard)
        }
        .animation(.spring, value: showShareSheet)
        .animation(.spring, value: showShareCard)
    }

    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            XMDesgin.XMButton {
                Task {
                    if let uiScrollView {
                        self.showShareCard = true
                        let uiimage = await Apphelper.shared.captureScrollView(uiScrollView)
                        if let uiimage {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showShareSheet = true
                            }
                        }
                    }
                }
            } label: {
                let btn = XMDesgin.XMIcon(iconName: "meal_tosta", color: isScrolling ? .xmf1 : .xmb1, withBackCricle: true, backColor: isScrolling ? .clear : .xmf1.opacity(0.5))
                    .animation(.easeInOut, value: self.isScrolling)
                if showText {
                    HStack(alignment: .center, spacing: 0) {
                        btn
                        Text("制作分享卡片")
                            .font(.custom("youyou-yisong", size: 16))
                    }
                    .padding(.trailing, 6)
                    .addCardBack()
                } else {
                    btn
                }
            }
        }
    }
}

extension View {
    func addTostaToShareCard(content: AnyView, isScrolling: Binding<Bool> = .constant(true), showText: Bool = false) -> some View {
        self.modifier(TostaToShare(content: {
            content
        }, isScrolling: isScrolling, showText: showText))
    }
}

// MARK: - IfShow

// 条件性显示视图的扩展

extension View {
    func ifshow(show: Bool) -> some View {
        Group {
            if show {
                self
            } else {
                EmptyView()
            }
        }.hidden(!show)
    }
}

// MARK: - IfShow

// 条件性显示视图的扩展

extension View {
    func pixellate(_ f: CGFloat = 3) -> some View {
        if #available(iOS 17.0, *) {
            return self
                .distortionEffect(
                    ShaderLibrary.pixellate(
                        .float(f)
                    ),
                    maxSampleOffset: .zero
                )
        } else {
            return self
        }
    }
}

extension View {
    func addOS9Shadow(status : XMDesgin.SBButtonStatus) -> some View {
        if status == .凹{
            return self
                .shadow(color: .init(hex: "808080"), x: 0, y: -2, blur: 0)
                .shadow(color: .init(hex: "808080"), x: -2, y: 0, blur: 0)
                .shadow(color: .init(hex: "ffffff"), x: 0, y: 2, blur: 0)
                .shadow(color: .init(hex: "ffffff"), x: 2, y: 0, blur: 0)
        }else{
            return self
                .shadow(color: .init(hex: "808080"), x: 2, y: 0, blur: 0)
                .shadow(color: .init(hex: "808080"), x: 0, y: 2, blur: 0)
                .shadow(color: .init(hex: "ffffff"), x: -2, y: 0, blur: 0)
                .shadow(color: .init(hex: "ffffff"), x: 0, y: -2, blur: 0)
        }
    }



    func addOS9Shadow_card() -> some View {
        return self
            .overlay(alignment: .center) {
                Rectangle()
                    .stroke(lineWidth: 1)
                    .fcolor(.init(hex: "262626"))
            }
            .shadow(color: .init(hex: "262626"), x: 1, y: 1, blur: 0)
            .shadow(color: .init(hex: "808080"), x: -2, y: 2, blur: 0)
            .shadow(color: .init(hex: "808080"), x: 0, y: -2, blur: 0)
            .shadow(color: .init(hex: "ffffff"), x: 2, y: 0, blur: 0)
            .shadow(color: .init(hex: "ffffff"), x: 0, y: 2, blur: 0)
    }
}

extension View {
    func addOS9Back(enable: Bool = true) -> some View {
        Group {
            if !enable {
                self
            } else {
                self
                    .background(
                        Image("belly_setting_background")
                            .resizable()
                            .scaledToFill()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(.drop(color: .xmf1, radius: 0, x: 6, y: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(lineWidth: 2)
                            .fcolor(.xmf1)
                    )
            }
        }
    }
}

// MARK: - AddTagBack

// 为视图添加标签背景的扩展

extension View {
    func addTagBack(backColor: Color = .xmb1) -> some View {
        self
            .padding(.horizontal, 4)
            .padding(.trailing, 6)
            .background(backColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - AddCardBack

// 为视图添加卡片背景的扩展

extension View {
    func addCardBack() -> some View {
        background(Color.xmb1)
            .clipShape(RoundedRectangle(cornerRadius: 11.9))
            .shadow(.drop(color: .xmf1.opacity(0.039), radius: 24, x: 0, y: 0))
    }
}

// MARK: - AddCardShadow

// 为视图添加卡片阴影效果的扩展

extension View {
    func addCardShadow() -> some View {
        self
            .shadow(.drop(color: .xmf1.opacity(0.2), radius: 1, x: 0, y: 2))
            .shadow(.drop(color: .xmf1.opacity(0.2), radius: 24, x: 0, y: 2))
            .shadow(.drop(color: .xmf1.opacity(0.1), radius: 32, x: 0, y: 2))
            .transition(.asymmetric(insertion: .movingParts.move(edge: .bottom).animation(.easeInOut), removal: .movingParts.vanish(.xmb1).animation(.easeInOut)))
    }
}

// MARK: - Host

// 将SwiftUI视图转换为UIViewController的扩展

extension View {
    func host() -> UIViewController {
        return UIHostingController(rootView: self)
    }
}

// MARK: - ShakeViewModifier

// 为视图添加摇晃效果的修饰器

struct ShakeViewModifier: ViewModifier {
    @State var shake: Int = 0
    var action: () -> Void
    var enable: Bool = true

    init(enable: Bool = true, action: @escaping () -> Void) {
        self.action = action
        self.enable = enable
    }

    func body(content: Content) -> some View {
        XMDesgin.XMButton {
            guard enable else { shake += 1; return }
            action()
        } label: {
            content
        }
        .changeEffect(.shake(rate: .fast), value: self.shake)
    }
}

extension View {
    func isShakeBtn(enable: Bool, action: @escaping () -> Void) -> some View {
        disabled(true).modifier(ShakeViewModifier(enable: enable, action: action))
    }
}

// MARK: - KeyBoardFocusModifier

// 自动打开键盘并聚焦的修饰器

struct KeyBoardFocusModifier: ViewModifier {
    @FocusState var input
    func body(content: Content) -> some View {
        content.focused(self.$input)
            .onAppear {
                input = true
            }
    }
}

extension View {
    func autoOpenKeyboard(_ enable: Bool = true) -> some View {
        Group {
            if enable {
                self.modifier(KeyBoardFocusModifier())
            } else {
                self
            }
        }
    }
}

// MARK: - MoveTo

// 将视图移动到指定对齐位置的扩展

extension View {
    func moveTo(alignment: SwiftUI.Alignment) -> some View {
        return frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

// MARK: - CanSkip

// 添加可跳过功能的扩展

extension View {
    func canSkip(action: @escaping () -> Void) -> some View {
        overlay {
            XMDesgin.XMButton {
                action()
            } label: {
                Text("跳过").font(.XMFont.f1.v1)
                    .fcolor(.xmf2)
            }
            .padding(.all)
            .padding(.bottom, 22)
            .moveTo(alignment: .bottomLeading)
        }
    }
}

// MARK: - BackLoadingColorBorder

// 添加彩色加载边框的修饰器

struct BackLoadingColorBorder: ViewModifier {
    let cornerRadius: CGFloat
    let opacity: CGFloat
    let show: Bool
    let isOverLayer: Bool

    init(cornerRadius: CGFloat, opacity: CGFloat, show: Bool, isOverLayer: Bool) {
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.show = show
        self.isOverLayer = isOverLayer
    }

    func body(content: Content) -> some View {
        Group {
            if self.isOverLayer {
                content.overlay(alignment: .center) {
                    colorBorder
                }
            } else {
                content
                    .background(alignment: .center) {
                        colorBorder
                    }
            }
        }
    }

    var colorBorder: some View {
        Group {
            if show {
                TimelineView(.animation) { timeline in
                    let circle = Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color("#6831D8"),
                                    Color("#52B1F4"),
                                    Color("#9548D7"),
                                    Color("#F5B542"),
                                    Color("#E93E56"),
                                    Color("#F07F49"),
                                    Color("#6831D8")
                                ]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            )
                        )

                    let maskRectangle = RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(lineWidth: 8)
                        .frame(maxWidth: .infinity)

                    ZStack(alignment: .center) {
                        ForEach([133, -133], id: \.self) { angle in
                            GeometryReader(content: { _ in
                                circle
                                    .scaleEffect(9)
                                    .rotationEffect(.degrees(timeline.date.timeIntervalSince1970 * Double(angle)))
                            })
                            .mask(alignment: .center) {
                                maskRectangle.blur(radius: angle > 0 ? 12 + 6 * sin(timeline.date.timeIntervalSince1970 * 2) : 5 + 3 * sin(timeline.date.timeIntervalSince1970 * 4))
                            }
                        }
                    }
                    .opacity(opacity)
                }
                .allowsHitTesting(false)
            } else {
                EmptyView()
            }
        }
        .transition(.opacity.animation(.easeInOut(duration: 1.2)))
    }
}

extension View {
    func addBackLoadingColorBorder(cornerRadius: CGFloat = 24, opacity: CGFloat = 0.666, show: Bool = true, isOverLayer: Bool = false) -> some View {
        self.modifier(BackLoadingColorBorder(cornerRadius: cornerRadius, opacity: opacity, show: show, isOverLayer: isOverLayer))
    }
}

// MARK: - AnimatedGradientShader

// 添加动画渐变着色器效果的修饰器

@available(iOS 17.0, *)
struct AnimatedGradientShader: ViewModifier {
    private let startDate = Date()

    func body(content: Content) -> some View {
        TimelineView(.animation) { _ in
            content.visualEffect { content, proxy in
                content
                    .colorEffect(
                        ShaderLibrary.animatedGradient(
                            .float2(proxy.size),
                            .float(startDate.timeIntervalSinceNow * 2)
                        )
                    )
            }
        }
    }
}

@available(iOS 17.0, *)
extension View {
    func animatedGradientShader() -> some View {
        modifier(AnimatedGradientShader())
    }
}
