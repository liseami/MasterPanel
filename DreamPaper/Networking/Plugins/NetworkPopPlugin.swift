//
//  WarningPlugin.swift
//  FantasyChat
//
//  Created by 赵翔宇 on 2022/8/1.
//

import Alamofire
import Foundation
import Moya

/// 通用网络插件
public class NetworkPopPlugin: PluginType {
    public init() {}

    /// 即将发送请求
    public func willSend(_: RequestType, target: TargetType) {}

    /// 收到返回结果时，一切返回结果都会走这里
    @MainActor
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success:

            switch result.HttpCode {
            case 206:
                break
            case 200:
                switch result.messageCode {
                case 408:
//                    Apphelper.shared.presentPanSheet(MembershipView(), style: .fullScreen)
                    Apphelper.shared.pushNotification(type: .info(message: result.message.or("请订阅会员。")))
                case 500:
                    guard result.message.contains("订阅") == false else { return }
                    Apphelper.shared.pushNotification(type: .error(message: result.message.or("未知错误")))
                default:
                    break
                }
            case 400:
                // 用户未登录的时候，不报登录过期
                guard UserManager.shared.Logged else { return }
                UserManager.shared.logOutUser()
                Apphelper.shared.pushNotification(type: .info(message: result.message.or("登录过期。请重新登录")))
            case 401:
                // 没有传Header
                guard UserManager.shared.Logged else { return }
                Apphelper.shared.pushNotification(type: .info(message: result.message.or("请登录后使用。")))
            case 407:
                UserManager.shared.logOutUser()
                Apphelper.shared.pushNotification(type: .info(message: result.message.or("用户已被封禁")))
            case 500:
                Apphelper.shared.pushNotification(type: .error(message: result.message.or("服务出错。请联系开发者")))
            case 502:
                Apphelper.shared.pushNotification(type: .info(message: "服务器重启中，请稍后"))
            default:
                Apphelper.shared.pushNotification(type: .error(message: result.message.or("未知错误")))
            }

        case .failure:
            Apphelper.shared.pushNotification(type: .error(message: result.message.or("网络错误")))
        }
    }
}
