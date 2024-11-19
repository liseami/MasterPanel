//
//  AppConfig.swift
//  Looper
//
//  Created by 赵翔宇 on 2022/6/20.
//

import Foundation

public enum AppConfig {
    #if DEBUG
        static let env = Env.dev
    #else
        static let env = Env.prod
    #endif

    // 环境
    public enum Env: String {
        case dev
        case prod
    }

    static var testUrl : String {
        ""
    }
    // baseURL
    static var baseUrl: String {
        switch env {
        case .dev: return ""
        case .prod: return ""
        }
    }

    /// 主页
    static let domain: String = ""
    /// 用户协议
    static let UserAgreement: String = domain + ""
    /// 隐私政策
    static let UserPrivacyPolicy: String = domain + "blog/yszc"
    /// iOS教程链接
    static let iOSGuide: String = domain + "blog/iosjiaocheng"
    /// 声音贡献教程链接
    static let SoundGuide: String = domain + "blog/soundjiaocheng"
    /// Apple商店链接
    static var AppStoreURL: URL { URL(string: "https://apps.apple.com/cn/app/id" + AppleStoreAppID)! }
    /// 友盟
    static var UMAPPKEY: String {
        self.readPlist(key: "UMAPPKEY")
    }

    /// 极光APPKEY
    static var JIGUANGAPPKEY: String {
        self.readPlist(key: "JIGUANGAPPKEY")
    }

    // 极光APP SECRET
    static var JIGUANGAPPSECRET: String {
        self.readPlist(key: "JIGUANGAPPSECRET")
    }

    static func readPlist(key: String) -> String {
        guard let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
              let configDict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = configDict[key] as? String
        else { return "" }
        return value
    }

    /// 当前版本
    static var AppVersion: String { (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0" }
    /// AppID
    static var AppleStoreAppID: String { "" }

    /// 测试图片
    static var mokImage: URL? {
        let int = Int.random(in: 180 ... 220)
        return URL(string: "https://picsum.photos/\(int)/\(int)")
    }
}
