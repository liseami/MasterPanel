

import KakaJSON
import Moya
import SwiftyJSON

enum LoginAPI: XMTargetType {
    ///  短信验证码注册
    case request_sms_code(phone_number:String)
    case signup_and_login_with_mobile_phone_and_sms_code(phone_number:String,sms_code:String)
    case appple_login(id_token:String,name: String?)

    var group: String {
        return "/api/v1/login"
    }

    var method: HTTPRequestMethod {
        switch self {
        default: return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .appple_login(let id_token, let name ) : return name == nil ? ["id_token":id_token] : ["id_token":id_token,"name":name!]
        case .request_sms_code(let phone_number) : return ["phone_number" : phone_number]
        case .signup_and_login_with_mobile_phone_and_sms_code(let phone_number,let  sms_code) : return ["phone_number" : phone_number,"sms_code" : sms_code]
        }
    }
}

