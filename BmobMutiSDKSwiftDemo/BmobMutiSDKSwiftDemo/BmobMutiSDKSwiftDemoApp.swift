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
        // Bmob.register(withAppKey: "f79b0cca258383c91bf6843b1a692c0e")
        // Bmob 示例appkey
        Bmob.register(withAppKey: "2b515d918cf5e1b45b5ad89164fcd7ff")
        print("Bmob SDK 初始化完成")
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
