//
//  PublicFuncs.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/25.
//

import Foundation
import JDStatusBarNotification
import Kingfisher
import Lantern
import PanModal
import Photos
import SPAlert
import StoreKit
import SwiftUIX
import UIKit

/*
 模拟延时
 */
func waitme(sec: Double = 3) async {
    do {
        try await Task.sleep(nanoseconds: UInt64(sec * 1000000000)) // 等待1秒钟
    } catch {}
}

/*
 强制等待任务
 */
@MainActor public func LoadingTask(loadingMessage: String, task: @escaping () async -> Void) {
    guard let window = Apphelper.shared.getWindow() else { return }

    // 创建模糊效果的视图
    if let blurView = VisualEffectBlurView(blurStyle: .light)
        .edgesIgnoringSafeArea(.all).host().view
    {
        blurView.size = CGSize(width: Screen.main.bounds.width, height: Screen.main.bounds.height)
        blurView.backgroundColor = UIColor.clear
        blurView.alpha = 0.0 // 初始时设置为透明
        blurView.tag = 1
        blurView.center = CGPoint(x: Screen.main.bounds.width * 0.5, y: Screen.main.bounds.height * 0.5)

        // 将模糊效果的视图添加到窗口上
        window.addSubview(blurView)

        // 显示loading消息
        Apphelper.shared.pushNotification(type: .loading(message: loadingMessage))

        // 使用UIView.animate实现渐显动画
        UIView.animate(withDuration: 1) {
            blurView.alpha = 1.0 // 设置为完全不透明
        }
        // 异步执行任务
        Task { @MainActor in
            await waitme(sec: 0.5)
            await task()
            // 使用UIView.animate实现淡出动画
            UIView.animate(withDuration: 0.3) {
                blurView.alpha = 0.0 // 设置为透明
            } completion: { _ in
                blurView.removeFromSuperview() // 移除模糊效果的视图
            }
            NotificationPresenter.shared.dismiss()
        }
    }
}

class Apphelper: NSObject {
    static let shared: Apphelper = .init()

    enum ReportType {
        case user
        case voice
    }

    @MainActor
    func report(id: String, type: ReportType) async -> Bool {
        let t = type == .user ? ReportAPI.user(id: id) : ReportAPI.voice(id: id)
        let r = await Networking.request_async(t)
        let success = r.is200Ok
        if success {
            Apphelper.shared.pushNotification(type: .info(message: "收到反馈，感谢维护社区"))
        }
        return success
    }

    /*
     保存图片到相册
     */

    @MainActor
    func saveImageToPhotosAlbum(uiimage: UIImage) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()

        switch photoAuthorizationStatus {
        case .authorized:
            // 已经获取权限,可以保存图片
            saveImageToAlbum(uiimage: uiimage)
        case .notDetermined:
            // 请求相册权限
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // 获取权限成功,保存图片
                    self.saveImageToAlbum(uiimage: uiimage)
                } else {
                    // 没有获取权限
                    DispatchQueue.main.async {
                        self.pushNotification(type: .error(message: "无法访问照片,请允许访问照片权限"))
                    }
                }
            }
        case .restricted, .denied:
            // 没有权限
            DispatchQueue.main.async {
                self.pushNotification(type: .error(message: "无法访问照片,请允许访问照片权限"))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.openAppPrivacySettings()
                }
            }
        default:
            break
        }
    }

    @MainActor
    private func saveImageToAlbum(uiimage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiimage, self, #selector(imageSaved(image:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func imageSaved(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if error != nil {
            DispatchQueue.main.async {
                self.pushNotification(type: .error(message: "保存失败"))
            }
        } else {
            DispatchQueue.main.async {
                self.pushNotification(type: .success(message: "图片保存成功。"))
                self.closeSheet()
                NotificationCenter.default.post(name: Notification.Name.SaveImageToAlbumSuccess, object: nil)
            }
        }
    }

    func openAppPrivacySettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            print("无法创建设置页面URL")
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:]) { success in
                if success {
                    print("成功打开设置页面")
                } else {
                    print("打开设置页面失败")
                }
            }
        } else {
            print("无法打开设置页面URL")
        }
    }

    /*
     关闭键盘
     */
    func closeKeyBoard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /*
     分享App
     */
    func shareApp(text: String = "我正在用陌生人闹钟，由陌生人的随机语音开启美好一天。现邀请你加入。 ") {
        // 要分享的内容
        let shareText = text // 分享时附带的介绍语
        let appURL = AppConfig.AppStoreURL // 你应用在App Store的链接
        // 创建分享项目数组
        let objectsToShare = [shareText, appURL] as [Any]
        // 创建分享视图控制器
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        // 设置可以在分享视图中显示的活动类型(例如邮件、Twitter等)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        // 显示分享视图
        Apphelper.shared.topMostViewController()?.present(activityVC, animated: true, completion: nil)
    }

    /*
     关闭sheet
     */

    func closeSheet() {
        if let presentedVC = topMostViewController()?.presentedViewController {
            presentedVC.dismiss(animated: true)
        } else {
            topMostViewController()?.dismiss(animated: true, completion: nil)
        }
    }

    /*
     弹出Alert弹窗
     */

    @MainActor
    func pushAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        actions.forEach { UIAlertAction in
            alertController.addAction(UIAlertAction)
        }
        topMostViewController()?.present(alertController, animated: true, completion: nil)
    }

    /*
     请求用户评分
     */

    func requestReviewApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }

    /*
     打开URL
     */

    enum URLOpenType {
        case inside
        case outside
    }

    func openURL(url: URL, type: URLOpenType) {
        switch type {
        case .inside:
            mada(style: .rigid)
            presentPanSheet(InAppBrowser(url: url)
                .preferredColorScheme(.dark), style: .sheet)
        case .outside:
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.pushNotification(type: .error(message: "无法打开链接。"))
                }
            }
        }
    }

    /*
     马达
     */

    func mada(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.prepare()
        impactFeedback.impactOccurred(intensity: intensity)
    }

    func nofimada(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func getWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
        for scene in connectedScenes {
            if let sceneDelegate = scene.delegate as? UIWindowSceneDelegate {
                if let window = sceneDelegate.window {
                    return window
                }
            }
        }
        return nil
    }

    /*
     全局最高级ViewController
     */

    func topMostViewController() -> UIViewController? {
        let vc = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }.first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .topMostViewController()

        return vc
    }

    /*
     推送系统sheet
     */
    func present<V: View>(_ view: V,
                          named name: AnyHashable? = nil,
                          onDismiss: @escaping () -> Void = {},
                          presentationStyle: ModalPresentationStyle? = nil,
                          completion: @escaping () -> Void = {})
    {
        topMostViewController()?.present(view.environment(\.colorScheme, .light), named: name, onDismiss: onDismiss, presentationStyle: presentationStyle, completion: completion)
    }

    /*
     推送PanSheet页面
     */
    func presentPanSheet<T: View>(_ view: T, style: PanPresentStyle) {
        topMostViewController()?.presentPanModal(PanViewBox(content: view, style: style))
    }

    enum NotificationType {
        case success(message: String)
        case info(message: String)
        case warning(message: String)
        case error(message: String)
        case loading(message: String)
    }

    func ifVip(doVipFunc: @escaping () -> Void) {
        if UserManager.shared.user.is_vip {
            doVipFunc()
        } else {
//            Apphelper.shared.presentPanSheet(MembershipView(), style: .setting)
        }
    }

    /*
     弹出小提示
     */
    @MainActor
    func pushNotification(type: NotificationType) {
        let message: String
        var textColor = UIColor(Color.xmf1)

        switch type {
        case let .info(msg):
            message = msg
            textColor = UIColor(Color.xmf1)

        case let .success(msg):
            message = msg
            textColor = UIColor(Color.xmf1)

        case let .warning(msg):
            message = msg
            textColor = UIColor(Color.orange)

        case let .error(msg):
            message = msg
            textColor = UIColor(.xmerror)

        case let .loading(msg):
            message = msg
            textColor = UIColor(Color.xmf1)
        }

        // update default style
        NotificationPresenter.shared.updateDefaultStyle { style in
            let style: StatusBarNotificationStyle = style
            style.backgroundStyle.backgroundColor = UIColor(Color.xmb1)
            style.textStyle.textColor = textColor

            style.textStyle.font = UIFont(name: "Fusion-Pixel-10px-Monospaced-zh_hans-Regular", size: 17)

            style.canSwipeToDismiss = false
            style.animationType = .move

            return style
        }

        switch type {
        case let .success(message):
            AlertKitAPI.present(
                title: message,
                icon: .done,
                style: .iOS17AppleMusic,
                haptic: .success
            )
            NotificationPresenter.shared.dismiss(animated: true, after: 0.2) { _ in
            }
        case .info, .error, .warning:
            NotificationPresenter.shared.present(message, subtitle: nil, styleName: nil, duration: 2, completion: { _ in
                // completion block
            })

        case let .loading(msg):
            NotificationPresenter.shared.present(msg)
            NotificationPresenter.shared.displayActivityIndicator(true)
        }
    }

    @MainActor
    func closeNotificationSheet() {
        NotificationPresenter.shared.dismiss(animated: true, after: 0.2) { _ in
        }
    }

    func pushProgressNotification(text: String, progress: @escaping (NotificationPresenter) -> Void) {
        // update default style
        NotificationPresenter.shared.updateDefaultStyle { style in
            let style: StatusBarNotificationStyle = style
            style.backgroundStyle.backgroundColor = UIColor(Color.xmb1)
            style.textStyle.textColor = UIColor(Color.xmf1)
            style.textStyle.font = UIFont.boldSystemFont(ofSize: 16)
            style.canSwipeToDismiss = false
            style.animationType = .fade
            return style
        }
        NotificationPresenter.shared.present(text) { presenter in
            progress(presenter)
        }
    }

    /*
     点击查看图片详情
     */
    @MainActor
    func tapToShowImage(tapUrl: String, rect: CGRect? = nil, urls: [String]? = nil) {
        let lantern = Lantern()

        lantern.numberOfItems = {
            if let urls {
                return urls.count
            } else {
                return 1
            }
        }
        lantern.reloadCellAtIndex = { context in
            let urlStr = urls?[context.index] ?? tapUrl
            // 调用 KingfisherManager.shared.retrieveImage 方法
            guard let url = URL(string: urlStr) else { return }
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case let .success(imageResult):
                    // 成功下载图片，获取 UIImage
                    let uiImage = imageResult.image
                    // 使用获取到的UIImage进行后续操作
                    let lanternCell = context.cell as? LanternImageCell
                    lanternCell?.imageView.image = uiImage

                    guard let rect else { return }
                    lantern.transitionAnimator = LanternSmoothZoomAnimator(transitionViewAndFrame: { _, _ -> LanternSmoothZoomAnimator.TransitionViewAndFrame? in
                        let transitionView = UIImageView(image: uiImage)
                        transitionView.contentMode = transitionView.contentMode
                        transitionView.clipsToBounds = true
                        let thumbnailFrame = rect
                        return (transitionView, thumbnailFrame)
                    })
                case let .failure(error):
                    // 下载图片失败，处理错误
                    print("Error: \(error)")
                }
            }
        }
        lantern.pageIndex = urls?.firstIndex(of: tapUrl) ?? 0
        lantern.transitionAnimator = LanternFadeAnimator()
        lantern.pageIndicator = LanternNumberPageIndicator()
        lantern.show()
    }

    func pushActionSheet(title: String?, message: String?, actions: [UIAlertAction], completion: (() -> Void)? = nil) {
        var alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        if let title = title, !title.isEmpty, let message = message, !message.isEmpty {
            alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        } else {
            alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }

        alertController.overrideUserInterfaceStyle = .light
        for action in actions {
            alertController.addAction(action)
        }

        alertController.addAction(.init(title: "取消", style: .cancel, handler: { _ in

        }))

        // 设置模式为黑暗模式
        alertController.view.tintColor = UIColor(Color.xmf1)

        if let viewController = topMostViewController() {
            alertController.popoverPresentationController?.sourceView = viewController.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            alertController.popoverPresentationController?.permittedArrowDirections = []
        }

        topMostViewController()?.present(alertController, animated: true, completion: completion)
    }

    /*
     从ScrollView截图
     */

    enum VoiceSheetType {
        case player
        case alarm
    }

    @MainActor
    func openVoiceSheet(_ id: String, type: VoiceSheetType = .player) {
//        switch type {
//        case .player:
//            Apphelper.shared.presentPanSheet(VoicePlayView(id, style: type), style: .sheet)
//        case .alarm:
//            Apphelper.shared.presentPanSheet(VoicePlayView(id, style: type), style: .hard_fullScreen)
//        }
    }

    @MainActor
    func captureScrollView(_ scrollView: UIScrollView) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            var image: UIImage?
            let contentSize = scrollView.contentSize

            // 开始一个新的图形上下文
            UIGraphicsBeginImageContextWithOptions(contentSize, true, UIScreen.main.scale)

            // 调整 scrollView 的框架以包含整个内容
            scrollView.frame = CGRect(origin: .zero, size: contentSize)

            // 在当前上下文中渲染 scrollView 的层
            scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)

            // 从当前上下文获取图像
            image = UIGraphicsGetImageFromCurrentImageContext()

            // 结束图形上下文
            UIGraphicsEndImageContext()

            continuation.resume(returning: image)
        }
    }
}

#Preview {
    List {
        let msg = String.randomChineseString(length: 12)
        XMDesgin.XMListRow(.init(name: "Info", icon: "", subline: "")) {
            Apphelper.shared.pushNotification(type: .info(message: msg))
        }
        XMDesgin.XMListRow(.init(name: "Success", icon: "", subline: "")) {
            Apphelper.shared.pushNotification(type: .success(message: msg))
        }
        XMDesgin.XMListRow(.init(name: "Warning", icon: "", subline: "")) {
            Apphelper.shared.pushNotification(type: .warning(message: msg))
        }
        XMDesgin.XMListRow(.init(name: "Error", icon: "", subline: "")) {
            Apphelper.shared.pushNotification(type: .error(message: msg))
        }
        XMDesgin.XMListRow(.init(name: msg, icon: "", subline: "")) {
            Apphelper.shared.pushNotification(type: .loading(message: "正在加载..."))
        }
        XMDesgin.XMListRow(.init(name: "Progress", icon: "", subline: "")) {
            Apphelper.shared.pushProgressNotification(text: "正在加载...") { presenter in
                presenter.displayProgressBar(at: 0.4)
            }
        }
        XMDesgin.XMListRow(.init(name: "ShowActionSheet", icon: "", subline: "")) {
            Apphelper.shared.pushActionSheet(title: "操作表单", message: "hello,world", actions: [UIAlertAction(title: "保存", style: .default, handler: { _ in
            }), UIAlertAction(title: "删除", style: .destructive, handler: { _ in

            })])
        }
        XMDesgin.XMListRow(.init(name: "强制等待任务", icon: "", subline: "")) {
            LoadingTask(loadingMessage: "请等待") {}
        }
    }
}
