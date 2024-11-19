//
//  NewVersionSheet.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/4/20.
//

import SwiftUI

struct NewVersionSheet: View {
    let versionInfo: XMVersionInfo
    let justRead: Bool
    init(_ versionInfo: XMVersionInfo, justRead: Bool = false) {
        self.versionInfo = versionInfo
        self.justRead = justRead
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer()
            Image("voice_mp3")
                .resizable()
                .frame(width: 120, height: 120)

            VStack(alignment: .center, spacing: 8) {
                // 版本号
                versionNumberText
                // 功能说明
                newFunLine
            }
            Spacer()
            button
            Spacer()
        }
        .padding(.horizontal, 12)
        .ignoresSafeArea()
        .background(Color.xmb2.ignoresSafeArea())
    }

    var button: some View {
        Group {
            if justRead {
                XMDesgin.SmallBtn(text: String(localized: "我知道啦"), enable: true) {
                    Apphelper.shared.closeSheet()
                    let currentVersionNumber = AppConfig.AppVersion.replacingOccurrences(of: ".", with: "").int ?? 0
                    UserDefaults.standard.setValue(currentVersionNumber, forKey: "last_read_version_number")
                }
            } else {
                XMDesgin.SmallBtn(text: String(localized: "更新"), enable: true) {
                    Apphelper.shared.openURL(url: URL(string: versionInfo.url_ios) ?? AppConfig.AppStoreURL, type: .outside)
                }
            }
        }
        .conditionalEffect(.repeat(.shine(duration: 1), every: 1), condition: true)
    }

    var newFunLine: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(versionInfo.release_notes, id: \.self) { note in
                if let index = versionInfo.release_notes.firstIndex(where: { $0 == note }) {
                    Text(note)
                        .font(.XMFont.f2.v1)
                        .transition(.asymmetric(insertion: .movingParts.move(edge: .leading).combined(with: .opacity).animation(.bouncy.delay(Double(index) * 0.1)), removal: .movingParts.poof.animation(.easeInOut(duration: 0.5))))
                }
            }
        }
    }

    @ViewBuilder
    var versionNumberText: some View {
        let title = justRead ? "新版本V\(versionInfo.version_name)摘要" : "V\(versionInfo.version_name)版本现已发布"
//        ColorSharderView()
//            .frame(height: 120)
//            .mask {
//                XMTyperText(text: title)
//                    .fcolor(.xmf1)
//                    .font(.XMFont.big2b.v1)
//                    .padding(.horizontal, 24)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 44, alignment: .center)
//                    .shadow(.drop(color: Color.xmf1.opacity(0.5), radius: 12, x: 0, y: 0))
//            }
//            .frame(height: 44)
        XMTyperText(text: title)
            .fcolor(.xmf1)
            .font(.XMFont.big2b.v1)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .frame(height: 44, alignment: .center)
            .shadow(.drop(color: Color.xmf1.opacity(0.5), radius: 12, x: 0, y: 0))
    }
}

#Preview {
    Color.red
        .onAppear(perform: {
            Apphelper.shared.presentPanSheet(NewVersionSheet(
                """
                    {
                                                    "channel": "ios",
                                                    "create_time": "1715612014864",
                                                    "release_notes": [
                                                        "一个迟到的，但无比强大的版本：",
                                                        "支持修改单位、数量、日期、对话期间拍照。",
                                                                        "一个迟到的，但无比强大的版本：",
                                                                        "支持修改单位、数量、日期、对话期间拍照。"
                                                    ],
                                                    "id": 11,
                                                    "version_number": 107,
                                                    "force_update": true,
                                                    "version_name": "1.0.7",
                                                    "url": "https://apps.apple.com/app/id6479637639"
                                                }
                """.kj.model(XMVersionInfo.self)!

            ), style: .hard_harf_sheet)
        })
}
