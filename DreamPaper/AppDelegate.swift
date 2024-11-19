//
//  AppDelegate.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/24.
//

import AudioToolbox
import Foundation
import UIKit
import UserNotifications
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var blurredWindow: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupNotifications()
        setupThirdPartyServices(with: launchOptions)
        return true
    }
    

    // MARK: - 通知处理

    // 当应用在前台时收到通知
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // 处理通知内容
//        await handleNotification(notification.request.content)
        // 返回通知的展示方式:横幅、声音和角标
        return [.banner, .sound, .badge]
    }

    // 用户点击通知或选择通知中的操作时调用
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
    ) async {
        // 处理通知内容
        await handleNotification(response.notification.request.content)
    }

    // 用户通过系统设置更改了应用的通知权限
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?
    ) {
        print("用户修改了通知设置")
        // 可以在这里执行一些操作，比如更新应用内的设置状态
    }

    // MARK: - 远程通知处理

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02X", $0) }.joined()
        print("设备令牌：", tokenString)
//        JPUSHService.registerDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("注册远程通知失败：", error.localizedDescription)
    }

    func application(
        _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("接收到远程通知：", userInfo)
        // 处理远程通知
        // 根据通知内容更新应用状态
        completionHandler(.newData)
    }

    // MARK: - 私有辅助方法

    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }

    private func setupThirdPartyServices(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    {
        AppInitManager.shared.ThridPartInit()
        // Bugly.start(withAppId: "e5008c5623")
//        JPUSHService.setup(
//            withOption: launchOptions,
//            appKey: AppConfig.JIGUANGAPPKEY,
//            channel: "AppStroe",
//            apsForProduction: AppConfig.env == .prod,
//            advertisingIdentifier: nil
//        )
    }

    private func handleNotification(_ content: UNNotificationContent) async {
    
    }
}
