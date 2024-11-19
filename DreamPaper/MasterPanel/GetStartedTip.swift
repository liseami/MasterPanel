//
//  GetStartedTip.swift
//  DreamPaper
//  新手引导提示视图

import SwiftUI
import TipKit

/// 新手引导提示
/// 用于向首次使用的用户展示如何操作推进镜头的功能提示
struct GetStartedTip: Tip {
    /// 提示标题
    /// 简洁说明操作方式:"长按中心，推进镜头"
    var title: Text {
        Text("长按中心，推进镜头")
    }
    
    /// 提示详细说明
    /// 解释"推镜头"这个专业术语的具体含义
    var message: Text? {
        Text("推镜头是指摄影机向画面中心推进。")
    }
}
