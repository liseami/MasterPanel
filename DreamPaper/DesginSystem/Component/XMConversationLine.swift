//
//  XMConversationLine.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/9.
//

import SwiftUI

struct XMConversationLine: View {
    let avatar : String
    let nickname : String
    let date : Date
    let lastmessage : String
    let userid : String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            XMUserAvatar(str: avatar, userId: userid)
            VStack(alignment: .leading, spacing: 12, content: {
                HStack {
                    Text(nickname)
                        .font(.XMFont.f1b.v1)
                    Spacer()
                    Text(date.string(withFormat: "HH:mm"))
                        .font(.XMFont.f2.v1)
                        .fcolor(.xmf2)
                }
                Text(lastmessage)
                    .lineLimit(2)
                    .font(.XMFont.f2.v1)
                    .fcolor(.xmf2)
            })
        }
        
    }
}

#Preview {
    XMConversationLine(avatar: "dsajsjdf", nickname: "用户名", date: .now, lastmessage: "最后一条消息", userid: "29329429")
}


