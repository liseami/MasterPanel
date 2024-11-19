//
//  XMAlarm.swift
//  StrangerBell
//
//  Created by 赵翔宇 on 2024/9/27.
//

import SwiftUI

// 定义枚举类型来表示各种设置选项
enum Gender: Int, CaseIterable, Identifiable {
    case random = 0 // 未知
    case male = 1    // 男
    case female = 2  // 女
    var id: Self { self }

    var localizedString: LocalizedStringKey {
        switch self {
        case .random: return "随机"
        case .male: return "男"
        case .female: return "女"
        }
    }
}

enum VoiceFrom: String, CaseIterable, Identifiable {
    case all
    case sub
    var id: Self { self }

    var localizedString: LocalizedStringKey {
        switch self {
        case .all: return "全世界"
        case .sub: return "我的订阅"
        }
    }
}

struct XMAlarmSetting: Convertible {
    var voice_from: VoiceFrom = .all
    var is_active: Bool = true
    var gender: Gender = .male
    var alarm_time: String = "08:00"
    var is_active_string_key: LocalizedStringKey {
        return is_active ? "开启" : "关闭"
    }
    
    init() {}
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        return property.name
    }
    
    func kj_modelValue(from jsonValue: Any?, _ property: Property) -> Any? {
        switch property.name {
        case "gender":
            if let genderInt = jsonValue as? Int {
                return Gender(rawValue: genderInt) ?? Gender.random
            }
        case "voice_from":
            if let voiceFromString = jsonValue as? String {
                let voiceFrom = VoiceFrom(rawValue: voiceFromString) ?? VoiceFrom.all
                return voiceFrom
            }
        default:
            break
        }
        return jsonValue
    }
    
    mutating func kj_willConvertToModel(from json: [String: Any]) {}
    
    mutating func kj_didConvertToModel(from json: [String: Any]) {}
}
