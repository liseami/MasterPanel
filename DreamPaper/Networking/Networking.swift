//
//  Networking.swift
//  SwiftUIRoute
//
//  Created by 梁泽 on 2023/9/27.
//



import Moya
import KakaJSON
import SwiftyJSON


struct Networking {
    static var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 120
        return config
    }

    static let plugins: [PluginType] = [NetworkingLogger(), NetworkPopPlugin()]

    static let defaultProvider = MoyaProvider<MultiTarget>(
        session: Session(configuration: configuration),
        plugins: [NetworkingLogger(), NetworkPopPlugin()]
    )
}

// MARK: - 普通请求
extension Networking {
    @discardableResult
    static func request(_ target: TargetType, completion: @escaping Completion) -> Moya.Cancellable {
        defaultProvider.requestWithNoObject(.init(target), completion: completion)
    }

    @discardableResult
    static func requestObject<T: Convertible>(_ target: TargetType, modeType: T.Type, atKeyPath keyPath: String? = "data", completion: @escaping (MoyaResult, T?) -> Void) -> Moya.Cancellable {
        defaultProvider.requestObject(.init(target), modeType: modeType, atKeyPath: keyPath, completion: completion)
    }

    @discardableResult
    static func requestArray<T: Convertible>(_ target: TargetType, modeType: T.Type, atKeyPath keyPath: String? = "data", completion: @escaping (MoyaResult, [T]?) -> Void) -> Moya.Cancellable {
        defaultProvider.requestArray(.init(target), modeType: modeType, atKeyPath: keyPath, completion: completion)
    }
}

// MARK: - async 函数
extension Networking {
    /// 直接 result.mapObject  .mapArray
    static func request_async(_ target: TargetType) async -> MoyaResult {
        await withCheckedContinuation { configuration in
            request(target) { result in
                configuration.resume(returning: result)
            }
        }
    }

//    static func requestObject_async<T: Convertible>(_ target: TargetType, modeType: T.Type, atKeyPath keyPath: String? = "data") async -> (MoyaResult, T?) {
//        return await withCheckedContinuation { configuration in
//            requestObject(target, modeType: modeType, atKeyPath: keyPath) { r, t in
//                configuration.resume(returning: (r, t))
//            }
//        }
//    }
//
//    static func requestArray_async<T: Convertible>(_ target: TargetType, modeType: T.Type, atKeyPath keyPath: String? = "data") async -> (MoyaResult, [T]?) {
//        return await withCheckedContinuation { configuration in
//            requestArray(target, modeType: modeType, atKeyPath: keyPath) { r, list in
//                configuration.resume(returning: (r, list))
//            }
//        }
//    }
}
