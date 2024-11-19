//
//  Public.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/23.
//

import Foundation
import KakaJSON



struct LabelInfo {
    var name: String
    var icon: String
    var subline: String
}

struct SettingItem:Identifiable,Hashable {
    var id : String = UUID().uuidString
    var name: String
    var iconName: String?
    var children: [SettingItem]? = []
}

struct XMUserOSSTokenInfo: Encodable, Decodable, Convertible {
    /// OSS服务的访问端点
    var endpoint: String = ""
    /// 访问密钥ID
    var accessKeyId: String = ""
    /// 访问密钥秘钥
    var accessKeySecret: String = ""
    /// 安全令牌
    var securityToken: String = ""
    /// 过期时间戳
    var expiration: String = ""
}

struct BellyBookEnums : Convertible{
    var meal_people_type_list : [String] = []
    var meal_source_type_list : [String] = []
    var food_type_list : [String] = []
    var food_type_current_user_can_see:[String] = []
}
struct LastListenTime: Convertible {
    var create_time: String = ""
}
