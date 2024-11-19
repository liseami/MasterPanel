//
//  HtmlManager.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/6/18.
//

import SwiftUI

import Foundation

class BaiduManager {
    private static let baidu_search_url = "http://www.baidu.com/s?ie=utf-8&tn=baidu&wd="
        
    private static let userAgents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36",
        "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/49.0.2623.108 Chrome/49.0.2623.108 Safari/537.36",
        "Mozilla/5.0 (Windows; U; Windows NT 5.1; pt-BR) AppleWebKit/533.3 (KHTML, like Gecko)  QtWeb Internet Browser/3.7 http://www.QtWeb.net",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
        "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/532.2 (KHTML, like Gecko) ChromePlus/4.0.222.3 Chrome/4.0.222.3 Safari/532.2",
        "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.4pre) Gecko/20070404 K-Ninja/2.1.3",
        "Mozilla/5.0 (Future Star Technologies Corp.; Star-Blade OS; x86_64; U; en-US) iNet Browser 4.7",
        "Mozilla/5.0 (Windows; U; Windows NT 6.1; rv:2.2) Gecko/20110201",
        "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.13) Gecko/20080414 Firefox/2.0.0.13 Pogo/2.0.0.13.6866"
    ]
        
    static func fetchResponseFromBaidu(keyword: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: baidu_search_url + keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            completion(nil)
            return
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8", forHTTPHeaderField: "Accept")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.setValue(userAgents.randomElement(), forHTTPHeaderField: "User-Agent")
//        request.setValue("https://www.baidu.com/", forHTTPHeaderField: "Referer")
//        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
//        request.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
                
            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                completion(nil)
                return
            }
                
            guard let data = data, let responseText = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
                
            completion(responseText)
        }
            
        task.resume()
    }
    
    static func fetchResponseFromBaidu(keyword: String) async -> String? {
        guard let url = URL(string: baidu_search_url + keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Apifox/1.0.0 (https://apifox.com)", forHTTPHeaderField: "User-Agent")
        request.setValue("https://www.baidu.com/", forHTTPHeaderField: "Referer")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("zh-CN,zh;q=0.9", forHTTPHeaderField: "Accept-Language")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                return nil
            }
            if let responseText = String(data: data, encoding: .utf8) {
                return responseText
            } else {
                return nil
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
