////
////  NotificationRequestView.swift
////  StrangerBell
////
////  Created by 赵翔宇 on 2024/9/27.
////
//
//import SwiftUI
//
//struct NotificationRequestView: View {
//    @State var show: Bool = false
//    var body: some View {
//        VStack(alignment: .center, spacing: 24, content: {
//            Spacer().height(80)
//            Image("sound")
//                .resizable()
//                .frame(width: 120, height: 120)
//            Text("陌生人闹钟需要通知权限，以便更好地为你推送语音闹钟")
//                .font(.XMFont.big1.v1)
//
//            alertCard
//                .transition(.movingParts.flip.animation(.easeInOut(duration: 0.2)).combined(with: .movingParts.glare.animation(.easeInOut(duration: 0.5))))
//                .ifshow(show: show)
//            Spacer()
//            XMDesgin.XMButton {
//                Apphelper.shared.closeSheet()
//                LocalNotificationManager.shared.did_presentSheet = false
//            } label: {
//                Text("稍后再说")
//                    .font(.XMFont.f1.v1)
//                    .fcolor(.xmf1.opacity(0.3))
//                    .padding(.bottom, 44)
//            }
//
//        })
//        .task {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                self.show = true
//            }
//        }
//        .padding(.horizontal, 24)
//        .ignoresSafeArea()
//        .background(Color.xmb2)
//    }
//
//    var alertCard: some View {
//        VStack(alignment: .center, spacing: 0) {
//            Text("“陌生人闹钟”想给你发送通知")
//                .font(.XMFont.f1.v1)
//                .fixedSize(horizontal: false, vertical: true)
//                .padding(.vertical, 12)
//            Text("通知可能包括提醒、声音和图表标记。这些可以在设置中配置。")
//                .font(.XMFont.f3.v1)
//                .fixedSize(horizontal: false, vertical: true)
//                .padding(.horizontal, 24)
//                .padding(.vertical, 12)
//            Image("Alert_driver")
//                .resizable()
//                .scaledToFit()
//                .padding(.top, 12)
//            XMDesgin.XMButton.init {
//                await LocalNotificationManager.shared.requestNotificationPermission()
//            } label: {
//                Text("允许")
//                    .fcolor(.xmb2)
//                    .padding(.vertical, 12)
//                    .maxWidth(.infinity)
//                    .background(Color.accentColor.conditionalEffect(.repeat(.glow(color: .white), every: 1), condition: true))
//                    .overlay(alignment: .center) {
//                        Image("hand")
//                            .resizable()
//                            .frame(width: 44, height: 44)
//                            .offset(x: 32, y: 24)
//                            .conditionalEffect(.repeat(.jump(height: 12), every: 1), condition: true)
//                    }
//                    .zIndex(3)
//            }
//
//            Group {
//                Image("Alert_driver")
//                    .resizable()
//                    .scaledToFit()
//                Text("在定时推送摘要中允许")
//                    .padding(.vertical, 12)
//                Image("Alert_driver")
//                    .resizable()
//                    .scaledToFit()
//                Text("不允许")
//                    .padding(.vertical, 12)
//                    .onTapGesture {
//                        Apphelper.shared.closeSheet()
//                        LocalNotificationManager.shared.did_presentSheet = false
//                    }
//            }
//            .zIndex(0)
//        }
//        .font(.XMFont.f1.v1)
//        .padding(.vertical, 24)
//        .background(
//            Image("Alert_back")
//                .resizable()
//        )
//        .padding(.horizontal, 36)
//    }
//}
//
//#Preview {
//    NotificationRequestView()
//}
