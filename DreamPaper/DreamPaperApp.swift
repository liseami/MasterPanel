//
//  CyberLifeApp.swift
//  CyberLife
//
//  Created by 赵翔宇 on 2024/11/15.
//

@_exported import Combine
@_exported import KakaJSON
@_exported import Pow
@_exported import SwifterSwift
@_exported import SwiftUI


@main
struct DreamPaperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var userManager: UserManager = .shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastActiveTime: Date = .init()
    var body: some Scene {
        WindowGroup {
            FilmView()
        }
    }
}
