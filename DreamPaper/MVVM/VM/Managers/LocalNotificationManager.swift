////
////  LocalNotificationManager.swift
////  StrangerBell
////
////  Created by 赵翔宇 on 2024/9/27.
////
//
//import AVFoundation
//import SwiftUI
//
//class JPUSHSE: NSObject, JPUSHRegisterDelegate {
//    func jpushNotificationCenter(
//        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (Int) -> Void) {}
//
//    func jpushNotificationCenter(
//        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) ->
//            Void)
//    {
//        // 处理通知展示
//        completionHandler([.sound]) // 示例：展示警告和声音
//    }
//
//    func jpushNotificationCenter(
//        _ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions
//    {
//        // 处理通知展示
//        return [.sound] // 示例：返回展示警告和声音
//    }
//
//    func jpushNotificationCenter(
//        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async
//    {
//        // 处理通知响应
//    }
//
//    func jpushNotificationCenter(
//        _ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification)
//    {
//        // 打开设置
//    }
//
//    func jpushNotificationAuthorization(
//        _ status: JPAuthorizationStatus, withInfo info: [AnyHashable: Any]?)
//    {
//        // 处理授权状态
//    }
//}
//
//// 本地通知管理类
//class LocalNotificationManager: ObservableObject {
//    static let shared = LocalNotificationManager()
//    private var player: AVAudioPlayer?
//    var did_presentSheet: Bool = false
//
//    var authorizationStatus: Bool {
//        let semaphore = DispatchSemaphore(value: 0)
//        var isAuthorized = false
//
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            isAuthorized = settings.authorizationStatus == .authorized
//            semaphore.signal()
//        }
//
//        semaphore.wait()
//        return isAuthorized
//    }
//
//    /// 检查通知权限并引导用户开启
//    @MainActor
//    func checkNotificationPermission() async {
//        guard UserManager.shared.Logged else { return }
//        let settings = await UNUserNotificationCenter.current().notificationSettings()
//        switch settings.authorizationStatus {
//        case .notDetermined, .denied, .provisional:
//            print("通知权限未授权")
//            guard self.did_presentSheet == false else { return }
//            Apphelper.shared.presentPanSheet(NotificationRequestView(), style: .setting)
//            self.did_presentSheet = true
//        case .authorized:
//            Apphelper.shared.closeSheet()
//            self.did_presentSheet = false
//            print("通知权限已授权")
//        case .ephemeral:
//            print("应用被临时授权发送通知")
//        @unknown default:
//            print("未知的授权状态")
//        }
//    }
//
//    func closeSheet() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            Apphelper.shared.closeSheet()
//            self.did_presentSheet = false
//            self.objectWillChange.send()
//        }
//    }
//
//    /// 请求通知权限
//    /// 此函数向用户请求发送通知的权限。
//    /// - Returns: 一个布尔值，表示是否获得了权限。
//    @MainActor
//    func requestNotificationPermission() async {
//        let settings = await UNUserNotificationCenter.current().notificationSettings()
//        let center = UNUserNotificationCenter.current()
//        switch settings.authorizationStatus {
//        case .notDetermined, .provisional:
//            do {
//                //                 注册远程通知
//                //                let entity = JPUSHRegisterEntity()
//                //                entity.types = NSInteger(UNAuthorizationOptions.alert.rawValue |
//                //                    UNAuthorizationOptions.badge.rawValue |
//                //                    UNAuthorizationOptions.sound.rawValue |
//                //                    UNAuthorizationOptions.providesAppNotificationSettings.rawValue)
//                //                JPUSHService.register(forRemoteNotificationConfig: entity, delegate: JPUSHSE())
//
//                let ok = try await center.requestAuthorization(options: [
//                    .alert, .sound, .badge, .criticalAlert
//                ])
//                if ok {
//                    self.closeSheet()
//                    print(
//                        settings.authorizationStatus == .notDetermined
//                            ? "用户首次授权通知权限" : "用户同意升级为完全通知权限")
//                } else {
//                    if settings.authorizationStatus == .notDetermined {
//                        print("用户拒绝了通知权限")
//                        self.closeSheet()
//                    } else {
//                        print("用户保持临时通知权限")
//                        self.closeSheet()
//                    }
//                }
//            } catch {
//                print("请求通知权限失败: \(error.localizedDescription)")
//                if settings.authorizationStatus == .notDetermined {
//                    await self.showNotificationPermissionAlert()
//                } else {
//                    self.closeSheet()
//                }
//            }
//
//        case .denied:
//            print("通知权限被拒绝")
//            await self.showNotificationPermissionAlert()
//
//        case .authorized, .ephemeral:
//            break
//
//        @unknown default:
//            print("未知的授权状态")
//            self.closeSheet()
//        }
//    }
//
//    /// 显示通知权限提醒弹窗
//    /// 当通知权限被拒绝时，此函数会显示一个弹窗，提醒用户开启通知权限，并提供直接跳转到设置的选项。
//    @MainActor
//    private func showNotificationPermissionAlert() async {
//        Apphelper.shared.pushAlert(
//            title: "你之前拒绝了通知权限的请求", message: "需要去设置页面手动开启通知权限。",
//            actions: [
//                UIAlertAction(
//                    title: "去设置", style: .default,
//                    handler: { _ in
//                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
//                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                        }
//                    })
//            ])
//    }
//
//    /// 创建多个通知
//    /// 此函数负责创建和设置多个闹钟通知内容。
//
//    func createLocalNotification(alarmDate: Date, voice: XMVoiceRecord) async throws {
//        await self.clearAllNotifications()
//
//        let timeInterval = voice.duration - 1
//        for i in 0 ..< 32 {
//            let content = UNMutableNotificationContent()
//            content.title = "陌生人闹钟"
//            content.subtitle = "@\(voice.username)来信"
//            content.body = voice.transcription
//            content.sound = UNNotificationSound.criticalSoundNamed(
//                UNNotificationSoundName("downloadedAlarm.wav"), withAudioVolume: 1.0)
//            content.interruptionLevel = .timeSensitive
//
//            content.threadIdentifier = "LocalAlarm"
//            content.categoryIdentifier = "AlarmCategory"
//            content.badge = 1
//            let userinfo = voice.kj.JSONObject()
//            content.userInfo = userinfo
//            content.targetContentIdentifier = "AlarmScene"
//            content.relevanceScore = 1.0
//            if #available(iOS 16.0, *) {
//                content.filterCriteria = "AlarmFilter"
//            }
//            let trigger: UNNotificationTrigger
//
//            /// 这里 +6 s 秒是为了：如果应用没有被杀死，时间到了后会直接播放音乐并取消所有带声音的通知
//            /// 会添加一些无声的通知
//            let delaySec = (i * timeInterval) + 6
//            let notificationDate = Calendar.current.date(
//                byAdding: .second, value: delaySec, to: alarmDate)!
//            let components = Calendar.current.dateComponents(
//                [.year, .month, .day, .hour, .minute, .second], from: notificationDate)
//            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
//
//            let request = UNNotificationRequest(
//                identifier: "alarmNotification\(i)", content: content, trigger: trigger)
//            do {
//                try await UNUserNotificationCenter.current().add(request)
//                #if DEBUG
//                    print("闹钟 \(i + 1) 设置成功")
//                #else
//                    print("闹钟 \(i + 1) 设置成功，时间：\(notificationDate)")
//                #endif
//            } catch {
//                print("闹钟 \(i + 1) 设置失败: \(error.localizedDescription)")
//                await self.clearAllNotifications()
//                throw AlarmError.failedToSetLocalNotification
//            }
//        }
//
//        print("所有32个闹钟设置完成")
//    }
//
//    /// 创建多个无声通知
//    /// 此函数负责创建和设置多个无声通知，从当前时间开始，每3秒钟一个。
//    func createSilentLocalNotifications(voice: XMVoiceRecord, count: Int = 50) async throws {
//        await self.clearAllNotifications()
//        for i in 0 ..< count {
//            let content = UNMutableNotificationContent()
//            content.title = "陌生人闹钟"
//            content.subtitle = "@\(voice.username)来信"
//            content.body = voice.transcription
//
//            content.threadIdentifier = "SilentLocalAlarm"
//            content.categoryIdentifier = "SilentAlarmCategory"
//            content.badge = 1
//            let userinfo = voice.kj.JSONObject()
//            content.userInfo = userinfo
//            content.targetContentIdentifier = "SilentAlarmScene"
//            content.relevanceScore = 1.0
//            if #available(iOS 16.0, *) {
//                content.filterCriteria = "SilentAlarmFilter"
//            }
//            let timeInterval = TimeInterval(3 * (i + 1))
//            let trigger = UNTimeIntervalNotificationTrigger(
//                timeInterval: timeInterval, repeats: false)
//            let request = UNNotificationRequest(
//                identifier: "silentAlarmNotification\(i)", content: content, trigger: trigger)
//            do {
//                try await UNUserNotificationCenter.current().add(request)
//                print("无声通知 \(i + 1) 设置成功")
//            } catch {
//                print("无声通知 \(i + 1) 设置失败: \(error.localizedDescription)")
//                await self.clearAllNotifications()
//                throw AlarmError.failedToSetLocalNotification
//            }
//        }
//        print("所有\(count)个无声通知设置完成")
//    }
//
//    /// 清除所有通知
//    /// 此函数用于清除所有待发送和已发送的通知。
//    @MainActor
//    func clearAllNotifications() async {
//        let center = UNUserNotificationCenter.current()
//
//        // 移除所有待发送的通知请求
//        center.removeAllPendingNotificationRequests()
//
//        // 移除所有已发送的通知
//        center.removeAllDeliveredNotifications()
//
//        // 重置应用程序图标上的角标数字
//        center.setBadgeCount(0) { _ in
//        }
//
//        print("所有通知已清除")
//    }
//}
