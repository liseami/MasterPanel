//
//  MookTool.swift
//  FantasyChat
//
//  Created by 赵翔宇 on 2022/8/26.
//

import Foundation
import KakaJSON
import SwiftyJSON

struct MockTool {
    static func jsonForFile(_ fileName: String) -> JSON? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"), let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSON(data: data)
    }

    static func readObject<T: Convertible>(_ type: T.Type, fileName: String, atKeyPath keyPath: String? = "data") -> T? {
        let json = jsonForFile(fileName)

        if let keyPath = keyPath {
            guard let originDic = (json?.dictionaryObject as NSDictionary?)?.value(forKeyPath: keyPath) else {
                return nil
            }

            return JSON(originDic).dictionaryObject?.kj.model(T.self)
        }

        return json?.dictionaryObject?.kj.model(T.self)
    }

    static func readArray<T: Convertible>(_ type: T.Type, fileName: String, atKeyPath keyPath: String? = "data") -> [T]? {
        let json = jsonForFile(fileName)

        if let keyPath = keyPath {
            guard let originDic = (json?.dictionaryObject as NSDictionary?)?.value(forKeyPath: keyPath) else {
                return nil
            }

            return JSON(originDic).arrayObject?.kj.modelArray(T.self)
        }

        return json?.arrayObject?.kj.modelArray(T.self)
    }

    /// 示例
    static func using() {
//        let arr = MockTool.readArray(LangModel.self, fileName: "codepower_langs")
        print("")
    }
}
