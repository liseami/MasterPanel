

import KakaJSON
import Moya
import SwiftyJSON

struct AudioUpdate: Convertible {
    var id: String?
    var name: String?
    var content: String?
    var is_public: Bool?
}

enum AudioAPI: XMTargetType {
    ///  短信验证码注册

    case random
    case all(page: Int, page_size: Int)
    case like(id: String)
    case collection(id: String)
    case collection_list(page: Int, page_size: Int)
    case delete(id: String)
    case detail(id: String)
    case complete(id: String)
    case update(p: AudioUpdate)
    case last_listened

    var group: String {
        return "/api/v1/audio"
    }

    var method: HTTPRequestMethod {
        switch self {
        case .last_listened, .random: return .get
        default: return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .complete(let id): return ["id": id]
        case .all(let page, let page_size): return ["page": page, "page_size": page_size]
        case .like(let id): return ["id": id]
        case .collection(let id): return ["id": id]
        case .collection_list(let page, let page_size): return ["page": page, "page_size": page_size]
        case .delete(let id): return ["id": id]
        case .detail(let id): return ["id": id]
        case .update(let p): return p.kj.JSONObject()
        default: return nil
        }
    }
}
