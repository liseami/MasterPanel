//
//  XMProduct.swift
//  GetGirlsMoney
//
//  Created by 赵翔宇 on 2024/9/18.
//

struct XMProduct : Convertible,Equatable {
   var  title: String = ""
   var  original_price: Double = 0
   var  current_price: Double = 0
   var  description: String = ""
   var  type: String = ""
   var  apple_product_id: String = ""
   var  android_product_id: String = ""
}
struct XMProductInfo : Convertible,Equatable {
    var products : [XMProduct] = []
    var lifetime_vip_user_count : Int = 0
}


