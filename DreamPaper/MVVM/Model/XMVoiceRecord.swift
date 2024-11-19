//
//  XMVoiceRecord.swift
//  StrangerBell
//
//  Created by 赵翔宇 on 2024/9/25.
//

import SwiftUI

import Foundation

struct XMVoiceRecord: Convertible, Identifiable {
    var avatar : String = ""
    var id: String = ""
    var username: String = ""
    var name: String = ""
    var update_time: String = ""
    var is_deleted: Bool = false
    var listen_count: Int = 0
    var like_count: Int = 0
    var transcription: String = ""
    var created_time: String = ""
    var url: String = ""
    var content: String = ""
    var is_public: Bool = false
    var content_review_status: String = ""
    var user_id: String = ""
    var duration: Int = 0
    var is_liked: Bool = false
    var is_collectioned: Bool = false
    var collection_count: Int = 0
}
