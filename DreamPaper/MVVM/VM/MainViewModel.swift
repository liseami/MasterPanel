//
//  MainViewModel.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/23.
//

import Foundation

class MainViewModel: XMModRequestViewModel<HomePageInfo> {
    static let shared = MainViewModel(currentTabbar: .home)
       
    @Published var currentTabbar: TabbarItem
    @Published var pathPages: NavigationPath
    @Published var tabbarBadge: [Int]
    
    init(currentTabbar: TabbarItem) {
        self.currentTabbar = currentTabbar
        self.pathPages = .init()
        self.tabbarBadge = [0, 0, 0]
        super.init(pageName: "") {
            PublicAPI.config
        }
    }
       
    enum TabbarItem: CaseIterable {
        case home
        case collections
        case work
//        case profile
           
        var badgeCount: Int {
            if let index = TabbarItem.allCases.firstIndex(of: self) {
                return MainViewModel.shared.tabbarBadge[index]
            }
            return 0
        }
           
        var labelInfo: (name: LocalizedStringKey, icon: String) {
            switch self {
            case .home:
                return (LocalizedStringKey("对话"), "tabbar_home")
            case .collections:
                return (LocalizedStringKey("收藏"), "tabbar_record")
            case .work:
                return (LocalizedStringKey("工作"), "tabbar_collection")
//            case .profile:
//                return (LocalizedStringKey("我的"), "tabbar_profile")
            }
        }
    }
       
    func setBadgeToTabbar(_ tab: TabbarItem, number: Int) {
        if let index = TabbarItem.allCases.firstIndex(of: tab) {
            withAnimation {
                self.tabbarBadge[index] = number
            }
        }
    }

    enum PagePath: Hashable, Decodable {
        case floderDetail(floderId: String)
        case profile(userId: String)
        case search
        case addfriend
        case food_history(foodname: String)
        case foodtypelist(type: String)
        case foodtypedetial(type: String)
        case mealdetail(meal_id: String)
        case floder(floder_id: String)
        case collection_detail(collection_id: String)
        case cyberFloder(floder_id: String)
        case aboutApp
        case sdkinfo
        case mysub
    }
}
