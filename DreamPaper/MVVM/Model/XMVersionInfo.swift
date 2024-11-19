//
//  VersionInfo.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/4/19.
//

import Foundation


struct XMVersionInfo : Convertible {
    var url_ios : String = ""
    var version_name : String = "" // : "1.0.0",
    var version_number: Int = 100 //": 100,
    var force_update: Bool = false //": True,
    var release_notes: [String] = []
}
