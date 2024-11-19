//
//  MoyaProviderTypeExtension.swift
//  SwiftComponentsDemo
//
//  Created by liangze on 2020/9/4.
//  Copyright © 2020 liangze. All rights reserved.
//

import Foundation
import KakaJSON
import Moya

// 所有网络请求都将经过这三个函数
public extension MoyaProviderType {
    @discardableResult
    func requestObject<T: Convertible>(_ target: Target,
                                       modeType _: T.Type,
                                       atKeyPath keyPath: String? = nil,
                                       callbackQueue: DispatchQueue? = .none,
                                       progress: Moya.ProgressBlock? = .none,
                                       completion: @escaping (MoyaResult, T?) -> Void) -> Moya.Cancellable {
        request(target, callbackQueue: callbackQueue, progress: progress) { r in
            let m = r.mapObject(T.self, atKeyPath: keyPath)
            completion(r, m)
        }
    }

    @discardableResult
    func requestWithNoObject(_ target: Target,
                             callbackQueue: DispatchQueue? = .none,
                             progress: Moya.ProgressBlock? = .none,
                             completion: @escaping (MoyaResult) -> Void) -> Moya.Cancellable {
        request(target, callbackQueue: callbackQueue, progress: progress) { r in
            completion(r)
        }
    }

    @discardableResult
    func requestArray<T: Convertible>(_ target: Target,
                                      modeType _: T.Type,
                                      atKeyPath keyPath: String? = nil,
                                      callbackQueue: DispatchQueue? = .none,
                                      progress: Moya.ProgressBlock? = .none,
                                      completion: @escaping (MoyaResult, [T]?) -> Void) -> Moya.Cancellable {
        request(target, callbackQueue: callbackQueue, progress: progress) { r in
            let ms = r.mapArray(T.self, atKeyPath: keyPath)
            completion(r, ms)
        }
    }
}
