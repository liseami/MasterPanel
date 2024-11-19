

import KakaJSON
import Moya
import SwiftyJSON

enum PublicAPI: XMTargetType {
  
    case config
    case version
    

    var group: String {
        return "/api/v1/public"
    }

    var method: HTTPRequestMethod {
        switch self {
        default: return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        default: return nil
        }
    }
}
