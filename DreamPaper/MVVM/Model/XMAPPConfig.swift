//
//  XMAPPConfig.swift
//  GetGirlsMoney
//
//  Created by 赵翔宇 on 2024/9/21.
//

import Foundation
struct XMAPPConfig :Convertible{
    var home_page_title : String = "" // home_page_title,
    var oss_endpoint : String = "" // endpoint,
    var oss_accessKeyId : String = "" // token['Credentials']['AccessKeyId'],
    var oss_accessKeySecret : String = "" // token['Credentials']['AccessKeySecret'],
    var oss_securityToken : String = "" // token['Credentials']['SecurityToken'],
    var oss_expiration : String = "" // token['Credentials']['Expiration']
    var membership_voice_url :String = ""
}
