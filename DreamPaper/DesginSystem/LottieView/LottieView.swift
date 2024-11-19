//
//  LottieView.swift
//  TimeMachine (iOS)
//
//  Created by Liseami on 2021/9/27.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    // 声明文件名作为Lottie变量以便于重复使用
    var lottieFliesName: String
    @Binding var animationView: LottieAnimationView
    
    typealias UIViewType = UIView
    // 装载洛丽塔动画
    // ——————————————————————————————————————————————————————————————————————————
    func makeUIView(context _: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animation = LottieAnimation.named(lottieFliesName)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor), animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        return view
    }

    //    —————————————————————————————————————————————————————————————————————
    func updateUIView(_: UIView, context _: UIViewRepresentableContext<LottieView>) {}
}

struct AutoLottieView: UIViewRepresentable {
    // 声明文件名作为Lottie变量以便于重复使用
    var lottieFliesName: String
    var loopMode: LottieLoopMode
    var speed: CGFloat = 1

    typealias UIViewType = UIView
    // 装载洛丽塔动画
    // ——————————————————————————————————————————————————————————————————————————
    func makeUIView(context _: UIViewRepresentableContext<AutoLottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(lottieFliesName)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        // 播放模式
        animationView.loopMode = loopMode
        // 播放速度
        animationView.animationSpeed = speed
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor), animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        return view
    }

    //    —————————————————————————————————————————————————————————————————————
    func updateUIView(_: UIView, context _: UIViewRepresentableContext<AutoLottieView>) {}
}
