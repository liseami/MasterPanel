

import KakaJSON
import Moya
import SwiftyJSON

enum AIAPI: XMTargetType {
    ///  短信验证码注册
    case audio_upload(url:String,duration:Int)
    
    var group: String {
        return "/api/v1/ai"
    } 

    var method: HTTPRequestMethod {
        switch self {
        default: return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .audio_upload(let url, let duration) : return ["url":url,"duration":duration]
        }
    }
}

