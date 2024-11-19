//
//  CustomResponse.swift
//  fenJianXiao_iOS
//
//  Created by liangze on 2019/12/18.
//  Copyright © 2019 liangze. All rights reserved.
//

import Foundation
import KakaJSON
import Moya
import SwiftyJSON

public typealias MoyaResult = Result<Moya.Response, MoyaError>

public struct NetworkResponse<T: Convertible> {
    public var code = 200
    public var message = ""
    public var data: T?
}

// MARK: - Result 扩展

public extension Result where Success == Moya.Response {
    var rawReponse: Moya.Response? { // 原始的 Response
        try? get()
    }

    var json: JSON? { // 原始Response 转data
        guard let data = rawReponse?.data else {
            return nil
        }
        return try? JSON(data: data)
    }

    // MARK: - 自定义的

    var code: Int {
        json?["code"].int ?? 0
    }

    var HttpCode: Int {
        rawReponse?.statusCode ?? -1
    }

    var message: String {
        json?["message"].string ?? json?["detail"].string ?? ""
    }

    var messageCode: Int {
        json?["code"].int ?? json?["code"].string?.int ?? 0
    }

    // 有个字段叫 data
    var rawData: Any? {
        json?["data"].rawValue
    }

    var dataJson: JSON? {
        json?["data"]
    }

    // MARK: - 其他

    // Http状态码
    var isSuccess: Bool {
        rawReponse?.statusCode == 200
    }

    // 那朵后端状态码
    var is200Ok: Bool {
        (json?["code"].int ?? json?["code"].string?.int ?? 0) == 200
    }
}

public extension Result where Failure == MoyaError {
    var error: MoyaError? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}

// MARK: - 数据解析

public extension Result where Success == Moya.Response {
    func mapObject<T: Convertible>(_: T.Type, atKeyPath keyPath: String? = "data") -> T? {
        if let keyPath = keyPath {
            guard let originDic = (json?.dictionaryObject as NSDictionary?)?.value(forKeyPath: keyPath) else {
                return nil
            }

            return JSON(originDic).dictionaryObject?.kj.model(T.self)
        }

        return json?.dictionaryObject?.kj.model(T.self)
    }

    func mapArray<T: Convertible>(_: T.Type, atKeyPath keyPath: String? = "data") -> [T]? {
        if let keyPath = keyPath {
            guard let originDic = (json?.dictionaryObject as NSDictionary?)?.value(forKeyPath: keyPath) else {
                return nil
            }

            return JSON(originDic).arrayObject?.kj.modelArray(T.self)
        }

        return json?.arrayObject?.kj.modelArray(T.self)
    }
}
