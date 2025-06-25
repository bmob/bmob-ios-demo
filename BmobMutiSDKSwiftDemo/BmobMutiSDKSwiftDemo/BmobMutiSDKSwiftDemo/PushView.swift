import SwiftUI

// 推送服务页面，包含推送消息示例
struct PushView: View {
    @State private var result: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("推送服务示例")
                .font(.title2)
                .padding()
            
            Button("推送消息") {
                pushMessage()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("推送服务")
    }
    
    // 推送消息
    func pushMessage() {
        let push = BmobPush()
        push.setMessage("Hello, Bmob 推送！")
        push.sendInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "推送成功"
            } else {
                self.result = "推送失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
} 