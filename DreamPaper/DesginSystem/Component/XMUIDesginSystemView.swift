//
//  XMUIDesginSystemView.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/2/26.
//

import SwiftUI
import SwiftUIX
import JDStatusBarNotification

struct XMUIDesginSystemView: View {
    var body: some View {
        List {
            Section("小按钮") {
                XMDesgin.SmallBtn {}
            }

            Section("图标") {
                XMDesgin.XMIcon(iconName: "setting_notification")
            }

            Section("SwiftUIX用例") {
                Text("View/statusItem(id:image:) - 添加一个状态栏项目，配置为在单击时显示弹出窗口")
            }
            
            Text("小通知")
                .onTapGesture {
                    Apphelper.shared.pushNotification(type: .info(message: "成功！"))
                }
            
        }

    }
}

#Preview {
    XMUIDesginSystemView()
}


