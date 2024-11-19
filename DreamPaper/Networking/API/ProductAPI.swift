

import KakaJSON
import Moya
import SwiftyJSON

enum ProductAPI: XMTargetType {
    ///  短信验证码注册
    case all
    case red_book_free_vip(url:String)
    case apple_payment_validate(transaction_id: String)
    case check_user_current_subscription_status(transaction_id: String)
    case my_subscription
    var group: String {
        return "/api/v1/product"
    }

    var method: HTTPRequestMethod {
        switch self {
        
        case .all,.my_subscription: return .get
        default: return .post
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .red_book_free_vip(let url) : return ["url":url]
        case .check_user_current_subscription_status(let transaction_id): return ["transaction_id": transaction_id]
        case .apple_payment_validate(let transaction_id): return ["transaction_id": transaction_id]
        default: return nil
        }
    }
}
