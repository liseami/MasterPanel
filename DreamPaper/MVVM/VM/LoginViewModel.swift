//
//  LoginViewModel.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/3/16.
//

import AuthenticationServices
import Foundation
import JDStatusBarNotification

/// 登录主视图模型
final class LoginMainViewModel: ObservableObject {
    /// 当前登录步骤
    @Published var loginStep: LoginStep = .macOS9
    var show_in_profile: Bool = false
    /// 初始化方法
    /// - Parameter welcomeStep: 初始登录步骤，默认为 .macOS9
    init(_ welcomeStep: LoginStep = LoginStep.macOS9, show_in_profile: Bool = false) {
        self.loginStep = welcomeStep
        self.show_in_profile = show_in_profile
        // self.playAnimation_step1()
        // 在设置页重播时，不可能跳过
        guard show_in_profile == false else { return }
        let skipShow = {
//            self.loginStep = .login_landing
        }

        // 看过动画不再看动画
        if UserDefaults.standard.bool(forKey: "DidSeeMacOS9") {
            skipShow()
        }
        // 审核员不看动画
        if self.isPossibleReviewer {
            skipShow()
        }
        
    }

    /// 计算属性：判断用户是否可能是审核人员
    var isPossibleReviewer: Bool {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let isEnglishLanguage = Locale.current.language.languageCode?.identifier == "en"
        let isEnglishRegion = Locale.current.region?.identifier == "US" || Locale.current.region?.identifier == "GB"
        return isIPad || isEnglishLanguage || isEnglishRegion
    }

    /// 登录步骤枚举
    enum LoginStep: CaseIterable {
        case macOS9
        case login_landing
        case phone_number_input
        case vcode_input
    }

    /// 屏幕宽度
    let w = UIScreen.main.bounds.width
    /// 屏幕高度
    let h = UIScreen.main.bounds.height

    /// 桌面应用枚举
    enum DeckTopApp: CaseIterable {
        case secret
        case app
        case login
        // case quit

        /// 获取图标名称
        var iconName: String {
            switch self {
            case .secret: return "login_note"
            case .app: return "login_floder"
            case .login: return "login_login"
            }
        }

        /// 获取标题
        var title: String {
            switch self {
            case .secret: return String(localized: "秘密")
            case .app: return String(localized: "废弃项目")
            case .login: return String(localized: "登录")
            }
        }
    }

    /// 是否已开始
    @Published var isStarted: Bool = false
    /// 选中的应用
    @Published var selectedApp: DeckTopApp?
    /// 选中的动画
    @Published var selectedAnimation: DeckTopApp?
    /// 打开的应用
    @Published var openApp: DeckTopApp?
    /// 显示的按钮
    @Published var showBtn: DeckTopApp?
    /// 是否不遗憾
    @Published var notPity: Bool = false
    /// 是否不遗憾文字出现
    @Published var notPityShowText: Bool = false
    /// 是否显示闹钟应用
    @Published var showBellApp: Bool = false

    /// 重置所有值
    func resetValues() {
        self.openApp = nil
        self.selectedApp = nil
        self.selectedAnimation = nil
        self.showBtn = nil
    }

    /// 驱动鼠标打开应用
    /// - Parameters:
    ///   - targetApp: 目标应用
    ///   - lastaction_delay: 最后动作延迟时间
    ///   - onComplete: 完成回调
    func openApp(targetApp: DeckTopApp, lastaction_delay: Double, onComplete: @escaping () -> ()) {
        withAnimation(.easeOut(duration: 0.5)) {
            resetValues()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.66) {
                withAnimation(.easeOut(duration: 0.5)) {
                    self.selectedApp = targetApp
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.selectedAnimation = targetApp
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                            self.openApp = targetApp
                            DispatchQueue.main.asyncAfter(deadline: .now() + lastaction_delay) {
                                onComplete()
                            }
                        }
                    }
                }
            }
        }
    }

    /// 播放动画步骤1
    func playAnimation_step1() {
        self.isStarted = true
        self.openApp(targetApp: .secret, lastaction_delay: 9) {
            self.showBtn = .secret
        }
    }

    /// 播放动画步骤2
    func playAnimation_step2() {
        self.openApp(targetApp: .app, lastaction_delay: 4) {
            self.showBtn = .app
        }
    }

    /// 播放动画步骤3
    func playAnimation_step3() {
        withAnimation(.easeOut(duration: 0.5)) {
            notPity = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.notPityShowText = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    self.showBellApp = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showBtn = .login
                    }
                }
            }
        }
    }

    /// 播放动画步骤4
    func playAnimation_step4() {
        self.openApp(targetApp: .login, lastaction_delay: 0.45) {
            if self.show_in_profile {
                DispatchQueue.main.async {
                    Apphelper.shared.closeSheet()
                }
            } else {
                self.nextPage()
                UserDefaults.standard.setValue(true, forKey: "DidSeeMacOS9")
            }
        }
    }

    /// 定义登录步骤的顺序
    private let loginSteps: [LoginStep] = LoginStep.allCases

    /// 向下翻页
    func nextPage() {
        guard let currentIndex = loginSteps.firstIndex(of: loginStep),
              currentIndex < loginSteps.count - 1 else { return }
        self.loginStep = self.loginSteps[currentIndex + 1]
    }

    /// 向前翻页
    func previousPage() {
        guard let currentIndex = loginSteps.firstIndex(of: loginStep),
              currentIndex > 0 else { return }
        self.loginStep = self.loginSteps[currentIndex - 1]
    }

    /// 手机号输入
    @Published var phoneInput: String = ""

    /// 短信验证码输入
    @Published var smscodeInput: String = ""

    /// 请求短信验证码
    @MainActor
    func request_sms_code() async {
        let t = LoginAPI.request_sms_code(phone_number: self.phoneInput)
        let r = await Networking.request_async(t)
        if r.is200Ok {
            Apphelper.shared.pushNotification(type: .success(message: "验证码已经发送。"))
            self.loginStep = .vcode_input
        }
    }

    /// 使用手机号和短信验证码注册或登录
    @MainActor
    func signup_or_login_with_mobile_phone_and_sms_code() async {
        let t = LoginAPI.signup_and_login_with_mobile_phone_and_sms_code(phone_number: self.phoneInput, sms_code: self.smscodeInput)
        let r = await Networking.request_async(t)
        if r.is200Ok, let tokenInfo = r.mapObject(XMTokenInfo.self) {
            UserManager.shared.tokenInfo = tokenInfo
            await UserManager.shared.logedUserTask()
        }
    }

    /// 苹果登录接口
    /// - Parameters:
    ///   - id_token: 苹果提供的 ID 令牌
    ///   - name: 用户名（可选）
    @MainActor
    func appleLogin(_ id_token: String, name: String?) async {
        let t = LoginAPI.appple_login(id_token: id_token, name: name)
        let r = await Networking.request_async(t)
        if r.is200Ok, let tokenInfo = r.mapObject(XMTokenInfo.self) {
            UserManager.shared.tokenInfo = tokenInfo
            await UserManager.shared.logedUserTask()
            NotificationPresenter.shared.dismiss()
        }
    }
}

// 检查手机号输入是否正确
extension LoginMainViewModel {
    /// 检查手机号输入是否有效
    var phontInputIsOK: Bool {
        return self.phoneInput.isDigits && self.phoneInput.count == 11
    }

    /// 检查短信验证码输入是否有效
    var smsCodeIsOK: Bool {
        return self.smscodeInput.isDigits && self.smscodeInput.count == 4
    }
}
