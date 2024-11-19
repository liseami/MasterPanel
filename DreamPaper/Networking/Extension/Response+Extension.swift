////
////  Response+KakaJson.swift
////  SwiftComponentsDemo
////
////  Created by liangze on 2020/9/4.
////  Copyright © 2020 liangze. All rights reserved.
////
//
// import Combine
// import Foundation
// import KakaJSON
// import Moya
// import SwiftyJSON
//

// MARK: - 原始

//
// public extension Response {
//    var json: JSON? { // 原始Response 转data
//        try? JSON(data: data)
//    }
//
//    // MARK: - 自定义的
//
//    var code: Int {
//        json?["code"].intValue ?? -1000
//    }
//
//    var message: String {
//        json?["message"].stringValue ?? ""
//    }
//
//    // 有个字段叫 data
//    var rawData: Any? {
//        json?["data"].rawValue
//    }
//
//    var dataJson: JSON? {
//        json?["data"]
//    }
//
//    // MARK: - 其他
//
//    var isSuccess: Bool {
//        code == 0
//    }
// }
//

// MARK: - KakaJson

//
// public extension Response {
//    /// keyPath默认是data
//    func mapObject<T: Convertible>(_: T.Type, atKeyPath keyPath: String? = nil) -> T? {
//        if let keyPath = keyPath {
//            guard let originDic = (json?.dictionaryObject as NSDictionary?)?.value(forKeyPath: keyPath) else {
//                return nil
//            }
//
//            return JSON(originDic).dictionaryObject?.kj.model(T.self)
//        }
//
//        return json?.dictionaryObject?.kj.model(T.self)
//    }
//
//    /// keyPath默认是data
//    func mapArray<T: Convertible>(_: T.Type, atKeyPath keyPath: String? = nil) -> [T] {
//        if let keyPath = keyPath {
//            guard let originDic = (json?.dictionaryObject as NSDictionary?)?.value(forKeyPath: keyPath) else {
//                return []
//            }
//
//            return JSON(originDic).arrayObject?.kj.modelArray(T.self) ?? []
//        }
//
//        return json?.arrayObject?.kj.modelArray(T.self) ?? []
//    }
// }
//

// MARK: - Combine

//
// @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
// public extension AnyPublisher where Output == Response, Failure == MoyaError {
//    func mapObject<T: Convertible>(_: T.Type, atKeyPath keyPath: String? = nil) -> AnyPublisher<T?, MoyaError> {
//        mt_unwrapThrowable { response in
//            response.mapObject(T.self, atKeyPath: keyPath)
//        }
//    }
//
//    func mapArray<T: Convertible>(_: T.Type, atKeyPath keyPath: String? = nil) -> AnyPublisher<[T], MoyaError> {
//        mt_unwrapThrowable { response in
//            response.mapArray(T.self, atKeyPath: keyPath)
//        }
//    }
// }
//

// MARK: - 辅助方法

//
// extension AnyPublisher where Failure == MoyaError {
//    // Workaround for a lot of things, actually. We don't have Publishers.Once, flatMap
//    // that can throw and a lot more. So this monster was created because of that. Sorry.
//    private func mt_unwrapThrowable<T>(throwable: @escaping (Output) throws -> T) -> AnyPublisher<T, MoyaError> {
//        tryMap { element in
//            try throwable(element)
//        }
//        .mapError { error -> MoyaError in
//            if let moyaError = error as? MoyaError {
//                return moyaError
//            } else {
//                return .underlying(error, nil)
//            }
//        }
//        .eraseToAnyPublisher()
//    }
// }
