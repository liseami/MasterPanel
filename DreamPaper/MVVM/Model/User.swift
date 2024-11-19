//
//  User.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/4.
//

import Foundation
import KakaJSON

struct XMTokenInfo: Convertible {
    var access_token: String = ""
}

struct XMUserInfo: Convertible, Identifiable {
    var id: String = ""
    var short_id: String = ""
    var records_count: Int = 0
    var username: String = ""
    var avatar: String = ""
    var bio: String = ""
    var gender: Int = 0
    var brithday: String = ""
    var created_time: String = ""
    var phone_number: String = ""
    var daily_token_limit: Int = 3000
    var my_vip_name: String = ""
    var profile_picture: String = ""
    var did_get_free_vip: Bool = false
    var invite_code: String = ""
    var invite_count: Int = 0
    var invite_by: String = ""
    var is_subscribed: Bool = false
    var subscribe_number: Int = 0
    var like_number: Int = 0
    var is_vip: Bool = false
    var is_new_user: Bool = true
//    var vip_level: Int = 0
//    var vip_expire_time: String = ""

//    移除
//    var shortId: String = ""
//    var history_used_token: Int = 0
//    var home_page_title: String = ""
//    var current_day_token_useage: Int = 0

    // 改名
    

    var isme: Bool {
        id == UserManager.shared.user.id
    }

    var maybeAudit: Bool {
        Locale.current.language.languageCode?.identifier != "zh" &&
            (username.contains("苹果") || username.contains("胃之书用户") || username.contains("AppleOnly"))
    }
}

// 主页信息，每次进入主页请求
struct HomePageInfo: Convertible {
    var home_page_title: String = ""
}

struct TodayMealCompleteInfo: Convertible, Identifiable {
    var id: String = UUID().uuidString
    var complete: Bool = false
    var photo_url: String = ""
}

// 综合使用情况，每次进入个人中心的使用情况页请求
struct UserUseageInfo: Convertible {
    var current_day_token_useage: Int = 0
    var history_token_useage: Int = 0
    var daily_token_limit: Int = 0
    var vipbanner_title: String = ""
    var today_meal_recored_number: Int = 0
    var daily_meal_recored_limit: Int = 0
}

struct CollectionViewInfo: Convertible {
    var did_use_daily_report: Bool = true
    var did_user_floder_create: Bool = true
}

struct UserRelationshipRequest: Identifiable, Convertible {
    var id: String = UUID().uuidString
    var requestid: String = ""
    var userid: String = ""
    var username: String = ""
    var avatar: String = ""
    var status: String = ""
}
