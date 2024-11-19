//
//  GetStartedTip.swift
//  FilmFinder
//
//  Created by Todd Hamilton on 10/31/24.
//

import SwiftUI
import TipKit

// Tooltip for first time users
struct GetStartedTip: Tip {
    var title: Text {
        Text("长按中心，推进镜头")
    }
    var message: Text? {
        Text("“推镜头”是指摄影机向画面中心推进。")
    }
}
