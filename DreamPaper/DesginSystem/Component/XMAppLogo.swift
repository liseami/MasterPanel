//
//  XMAppLogo.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/10.
//

import SwiftUI


#Preview {
    XMAppLogo()
}



struct XMAppLogo: View {
    let size: CGFloat
    init(size: CGFloat = UIScreen.main.bounds.width * 0.22) {
        self.size = size
    }

    var body: some View {
        Image("Speech manager")
            .resizable()
            .scaledToFill()
            .frame(
                width: size,
                height: size,
                alignment: .center)

    }
}

