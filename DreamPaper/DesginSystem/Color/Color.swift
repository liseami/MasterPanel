//
//  Color.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/27.
//

import Foundation
import SwiftUI

extension Color {
    enum xm {
        static let main : Color = Color.init(hex: "FFC700")
        static let b1: Color = Color.init(hex: "FFFFFF")
        static let b2: Color = Color.init(hex: "C8C8C8")
        static let b3: Color = Color.init(hex: "5A5A5A")
        static let f1: Color = Color.init(hex: "111111")
        static let f2: Color = Color.init(hex: "303030")
        static let f3: Color = Color.init(hex: "CDCDCD")
//        static let error : Color = .init(hex:"BE2925")
//        static let blue : Color = .init(hex:"854DF4")
//        static let yellow : Color = .init(hex:"FFC551")
//        static let orange : Color = .init(hex:"FE6F41")
    }
    
}
extension View{
    func fcolor(_ color : Color) -> some View  {
        self.foregroundStyle(color)
    }
}

