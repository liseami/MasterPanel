

import KakaJSON
import Moya
import SwiftyJSON

enum ReportAPI: XMTargetType {
    ///  短信验证码注册
    case user(id: String)
    case voice(id: String)
    var group: String {
        return "/api/v1/report"
    }

    var method: HTTPRequestMethod {
        switch self {
        default: return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .user(let id): return ["id": id]
        case .voice(let id): return ["id": id]
        }
    }
}
