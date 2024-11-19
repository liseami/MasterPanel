//
//  XMMemberShipInfo.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/3/19.
//

import SwiftUI

struct XMMemberShipInfo: Identifiable, Convertible {
    var id: Int = 0
    var name: String = "" //
    var desc: String = "" //: str
    var price: String = "" //: str
    var original_price : String = ""
    var time_long: String = "" //: str
    var desc_long: String = "" //: str
    var apple_product_id: String = "" //: str
    var tag : String = ""
    var function: [String] = []
}


struct ProductInCardInfo: Convertible {
    var title: String = ""
    var subline: String = ""
    var products: [XMMemberShipInfo] = []
}
