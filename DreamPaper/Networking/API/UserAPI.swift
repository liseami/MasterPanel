

import KakaJSON
import Moya
import SwiftyJSON

enum UserAPI: XMTargetType {
    case me
    case profile(id: String)
    case subscribe(id: String)
    case send_recommend(id: String)
    case update(p: UserUpdate)
    case input_invite_code(invite_code: String)
    case subscribed(page: Int, page_size: Int)
    case recommend(page: Int, page_size: Int)
    case block(id: String)

    var group: String {
        return "/api/v1/user"
    }

    var method: HTTPRequestMethod {
        switch self {
        case .me: return .get
        default: return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .subscribed(let page, let page_size): return ["page": page, "page_size": page_size]
        case .profile(let id): return ["id": id]
        case .subscribe(let id): return ["id": id]
        case .send_recommend(let id): return ["id": id]
        case .update(let p): return p.kj.JSONObject()
        case .input_invite_code(let invite_code): return ["invite_code": invite_code]
        case .recommend(let page, let page_size): return ["page": page, "page_size": page_size]
        case .block(let id): return ["id": id]
        default: return nil
        }
    }
}

extension UserAPI {
    // MARK: - Request

    struct AppleLoginReqMod: Convertible {
        var uid: String = ""
        var identity_token: String = ""
        var code: String = ""
    }

    struct UserUpdate: Convertible {
        var username: String?
        var avatar: String?
        var gender: Int?
    }
}
