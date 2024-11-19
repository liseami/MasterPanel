//
//  NDTargetType.swift
//  SwiftUIRoute
//
//  Created by 梁泽 on 2023/9/27.
//

import Moya
import SwifterSwift

// MARK: - Moya 扩展

extension XMTargetType {
    var headers: [String: String]? {
        var headers: [String: String] = [:]

//        var deviceTokenString = ""
//        for byte in UserDefaults.standard.data(forKey: "kUMessageUserDefaultKeyForDeviceToken")! {
//            deviceTokenString += String(format: "%02X", byte)
//        }
//        print("64-bit DeviceToken: \(deviceTokenString)")
        // 常规信息
        let standardHeader = [
            "channel": "ios",
            "version": AppConfig.AppVersion,
            "device": UIDevice.current.name,
            "os": UIDevice.current.systemVersion,
            "model": UIDevice.current.modelName,
            "device_token": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        headers["Client-Info"] = standardHeader.jsonString()
        headers["channel"] = "ios"
        headers["timezone"] = (TimeZone.current.secondsFromGMT() * 1000).string

         #if targetEnvironment(simulator)
        headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MzE1NDQ4MjUsInN1YiI6IjZkYjQ1MjUzLWZmMjYtNDlkMi1iZDM4LTk2MTIwM2Q3NmVmYSJ9.pwVQQ2ORYtahtnDTIv-1te-8jP_krOBb54GlktAIeM0"
         #else
        if !UserManager.shared.tokenInfo.access_token.isEmpty {
            headers["Authorization"] = "Bearer " + UserManager.shared.tokenInfo.access_token
        }
         #endif

        if !UserManager.shared.tokenInfo.access_token.isEmpty {
            headers["Authorization"] = "Bearer " + UserManager.shared.tokenInfo.access_token
        }
        return headers
    }
}

public typealias HTTPRequestMethod = Moya.Method

protocol XMTargetType: TargetType {
    var parameters: [String: Any]? { get }
    var parameterEncoding: ParameterEncoding { get }
    var group: String { get }
    func updatingParameters(_ newPage: Int) -> XMTargetType
}

// MARK: - 自有扩展

extension XMTargetType {
    var parameters: [String: Any]? { nil }
    var parameterEncoding: ParameterEncoding {
        switch method {
        case .get: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }

    var enumName: String {
        String(describing: self).components(separatedBy: "(").first!
    }
}

extension XMTargetType {
    /*
     翻页函数，搭配 XMStatusView()使用
     */
    func updatingParameters(_ newPage: Int) -> XMTargetType {
        return self
    }

    var baseURL: URL {
        URL(string: AppConfig.baseUrl) ?? URL(string: "https://test.com")!
    }

    var path: String {
        return group + "/" + enumName
    }

    var group: String { "" }

    var sampleData: Data {
        "".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch method {
        case .get:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        case .post, .put, .delete:
            return .requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)

        default:
            return .requestPlain
        }
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)

        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }
}
