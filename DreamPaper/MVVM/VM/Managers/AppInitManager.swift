//
//  AppInitManager.swift
//  FantasyChat
//
//  Created by 赵翔宇 on 2022/8/18.
//

import Foundation
import Kingfisher

class AppInitManager: NSObject {
    static let shared: AppInitManager = .init()
    @MainActor
    func ThridPartInit() {
        KingFisherSetup() // Kingfisher 设置
        UISetup() // UI设置
//        StoreSetUp() // 商店初始化
        UMCommonSetup() // 友盟初始化
    }


    /// 友盟配置
    private func UMCommonSetup() {
        // 友盟初始化
//        UMCommonSwift().run()

        // 友盟统计
        // UMAnalyticsSwift().run()
    }

    private func UISetup() {
        // ▼ 清除通知红点
        UIApplication.shared.applicationIconBadgeNumber = -1
        // ▼ 改变navigationbackbar的样式
        changeNavigaitonBarBackIcon()
    }

    /// KingFisher配置
    private func KingFisherSetup() {
        let cache = ImageCache.default
        cache.memoryStorage.config.expiration = .seconds(600)
        cache.diskStorage.config.expiration = .never
    }

    func changeNavigaitonBarBackIcon() {
        let backBarBtnImage = UIImage(named: "system_backbar")?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(UIColor.black)
            .resize(35, 19)
        UINavigationBar.appearance().backIndicatorImage = backBarBtnImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backBarBtnImage
    }
}
