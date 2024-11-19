

import KakaJSON
import Moya
import SwiftyJSON

struct AlarmUpdate : Convertible{
var gender: Int?
var voice_from: String?
var alarm_time: String?
var is_active: Bool?
}
enum AlarmAPI: XMTargetType {
    ///  短信验证码注册

    case setting
    case update(p:AlarmUpdate)

    var group: String {
        return "/api/v1/alarm"
    }

    var method: HTTPRequestMethod {
        switch self {
        case .setting : return .get
        default: return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .update(let p) : return p.kj.JSONObject()
        default: return nil
        }
    }
}
