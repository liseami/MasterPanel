//
//  NetworkPlugin.swift
//  fenJianXiao_iOS
//
//  Created by liangze on 2019/12/17.
//  Copyright © 2019 liangze. All rights reserved.
//

import Foundation
import Moya

/// 通用网络插件
public class NetworkingLogger: PluginType {
    /// 开始请求字典
    private static var startDates: [String: Date] = [:]

    public init() {}

    /// 即将发送请求
    public func willSend(_: RequestType, target: TargetType) {
        // 设置当前时间
        NetworkingLogger.startDates[String(describing: target)] = Date()
    }

    /// 收到请求时
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        guard let startDate = NetworkingLogger.startDates[String(describing: target)] else { return }
        logRequest(target, startDate: startDate, result: result)
        #endif
    }

    #if DEBUG
    private func logRequest(_ target: TargetType, startDate: Date, result: Result<Response, MoyaError>) {
        let requestDate = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
        print(target.path.logMessage)

        print("URL : \(target.baseURL)\(target.path)")
        print("请求方式：\(target.method.rawValue)")
        print("请求时间 : \(String(format: "%.3f", requestDate))s")

        if let header = target.headers {
            print("请求头 : \(header)")
        }

        if let request = result.rawReponse?.request {
            switch target.task {
            case .requestPlain, .uploadMultipart: break
            case let .requestParameters(parameters, _), let .uploadCompositeMultipart(_, parameters):
                print("请求参数 : ", parameters)
            default:
                if let requestBody = request.httpBody {
                    print("请求参数 : \(requestBody)")
                }
            }
        }

        switch result {
        case let .success(response):
            if let data = String(data: response.data, encoding: .utf8) {
                print("""
                code : \(result.code)
                http_Code : \(result.HttpCode)
                message_Code :\(result.messageCode)
                message : \(result.message)
                data：\r \(data))
                """)
            } else {
                let message = (try? response.map(String.self, atKeyPath: "error_description")) ?? ""
                print("message: \(message)")
            }
        case let .failure(error):
            print("请求错误：\(error)")
        }

        print("🔺🔺🔺🔺🔺🔺🔺🔺\(target.path)🔺🔺🔺🔺🔺🔺🔺🔺")
    }
    #endif
}

#if DEBUG
private extension String {
    var logMessage: String {
        return "🟢🟢🟢🟢🟢🟢🟢\(self)🟢🟢🟢🟢🟢🟢🟢"
    }
}
#endif
