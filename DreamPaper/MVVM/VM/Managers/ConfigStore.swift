//
//  ConfigStore.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/4/11.
//

import SwiftUI

import SwiftUI

class ConfigStore: ObservableObject {
    static let shared = ConfigStore()

    init() {
        self.appConfig = .init()
        self.appConfig = loadModel(type: XMAPPConfig.self)

        Task {
            // 获取App信息
            await self.getAppConfig()
            print(appConfig)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMembershipBuySuccess), name: Notification.Name.MemberShipBuySucccess, object: nil)
    }

    @objc private func handleMembershipBuySuccess() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @Published var versionInfo: XMVersionInfo = .init()

    func reset() {
        self.appConfig = .init()
    }

    @Published var appConfig: XMAPPConfig {
        didSet {
            savaModel(model: self.appConfig)
        }
    }

    // 从接口获取AppConfig
    @MainActor
    func getAppConfig() async {
        let t = PublicAPI.config
        let r = await Networking.request_async(t)
        if r.is200Ok, let config = r.mapObject(XMAPPConfig.self) {
            self.appConfig = config
        }
    }

//
//    /*
//     版本信息
//     */
    @MainActor
    func get_version_info() async {
        // 登录且不是新用户时请求
        guard UserManager.shared.Logged, UserManager.shared.user.is_new_user == false else { return }
        let t = PublicAPI.version
        let r = await Networking.request_async(t)
        if r.is200Ok, let version = r.mapObject(XMVersionInfo.self) {
            self.versionInfo = version
            let currentVersionNumber = AppConfig.AppVersion.replacingOccurrences(of: ".", with: "").int ?? 0
            // 当前版本小于服务器版本，弹出弹窗，按照是否强制更新，选择sheet style
            if currentVersionNumber < version.version_number {
                Apphelper.shared.presentPanSheet(NewVersionSheet(version), style: version.force_update ? .hard_harf_sheet : .harf_sheet)
                // 如果被动更新到了最新版本(AppStore会自动更新，安卓商店也会夜间更新），那也需要让用户读一次最新版本的信息。
                // 所以NewVersionSheet需要入参，并缓存用户上一次读过的版本号
            } else if currentVersionNumber == version.version_number {
                if UserDefaults.standard.integer(forKey: "last_read_version_number") < version.version_number {
                    Apphelper.shared.presentPanSheet(NewVersionSheet(version, justRead: true), style: .harf_sheet)
                }
            }
        }
    }
}

extension ConfigStore {
    // 持久化：模型的Model to JsonString
    func savaModel<M: Convertible>(model: M) {
        let jsonString = model.kj.JSONString()
        // 仅得到TypeName，例如“UserModel”
        let modelName = String(describing: type(of: model))
        // 以TypeName作为键，存入StringJson
        UserDefaults.standard.setValue(jsonString, forKey: modelName)
    }

    // 读数据：模型的JsonString to Model
    func loadModel<M: Convertible>(type: Convertible.Type) -> M {
        // 仅得到TypeName，例如“UserModel”
        let modelName = String(describing: type).components(separatedBy: "(").first!
        // 以TypeName作为键，找寻数据
        if let data = UserDefaults.standard.string(forKey: modelName),
           // JsonString to ConvertibleModel
           let model = data.kj.model(type: type)
        {
            return model as! M
        } else {
            return .init()
        }
    }
}
