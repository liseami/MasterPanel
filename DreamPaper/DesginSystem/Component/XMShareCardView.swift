//
//  XMShareCardView.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/6/15.
//

import SwiftUI

struct XMShareCardView<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            /// 用户信息
            VStack(alignment: .leading, spacing: 16) {
                userInfoLine
                Divider()
            }
            content()
            Divider()
            XMBrandLine()
        }
        .font(.XMFont.f1b.v2)
        .padding(.all, 16)
        .background(Color.xmb1
            .clipShape(RoundedRectangle(cornerRadius: 11.9))
            .addCardShadow())
        .padding(.all, 24)
    }

    var user: XMUserInfo {
        UserManager.shared.user
    }

    var userInfoLine: some View {
        HStack(spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                XMUserAvatar(str: user.avatar, userId: user.id, size: 36)
                Text(UserManager.shared.user.username)
                    .font(.XMFont.f2b.v2)
                    .fcolor(.xmf1)
            }
            XMDesgin.XMIcon(iconName: "member_tag")
                .ifshow(show: UserManager.shared.user.is_vip)
        }
    }
}

#Preview {
    XMShareCardView.init {
        Color.red
    }
}
