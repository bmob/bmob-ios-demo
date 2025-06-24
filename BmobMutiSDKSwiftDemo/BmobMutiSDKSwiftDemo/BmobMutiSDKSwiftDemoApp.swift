//
//  BmobMutiSDKSwiftDemoApp.swift
//  BmobMutiSDKSwiftDemo
//
//  Created by magic on 2025/6/24.
//

import SwiftUI



@main
struct BmobMutiSDKSwiftDemoApp: App {
    init() {
        // 初始化 Bmob SDK
        Bmob.register(withAppKey: "f79b0cca258383c91bf6843b1a692c0e")
        print("Bmob SDK 初始化完成")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
