import SwiftUI

@main
struct BmobMutiSDKSwiftDemoApp: App {
    init() {
        // 初始化 Bmob SDK
        Bmob.register(withAppKey: "81f39d4b023b93d62a48178c9db3c30e")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
} 