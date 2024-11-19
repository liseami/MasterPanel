//
//  MainView.swift
//  CyberLife
//
//  Created by 赵翔宇 on 2024/11/16.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var vm: MainViewModel = .shared
    var body: some View {
        NavigationView {
            ZStack {
                Color.xm.b1
                    .ignoresSafeArea()
              
                switch vm.currentTabbar {
                case .home:
                    HomeView()
                case .collections:
                    CardFlowView()
                case .work:
                    WorkFlowView()
                }
                MainTabbar()
            }

            .task {}
            .navigationBarTransparent(true)
            .navigationDestination(for: MainViewModel.PagePath.self) { path in
                Group {
                    switch path {
                    default:
                        Text("NavigationSubView")
                    }
                }
                .navigationBarTransparent(false)
                .toolbarRole(.editor)
            }
        }
    }
}

#Preview {
    MainView()
}
