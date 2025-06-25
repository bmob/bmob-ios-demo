import SwiftUI

// 其他功能页面，包含云函数、支付、服务器时间、网络超时设置等示例
struct OtherView: View {
    @State private var result: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("其他功能示例")
                .font(.title2)
                .padding()
            
            Button("调用云函数") {
                callCloudFunction()
            }
            Button("发起支付请求") {
                payRequest()
            }
            Button("获取服务器时间") {
                getServerTime()
            }
            Button("设置网络超时时间") {
                setNetworkTimeout()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("其他功能")
    }
    
    // 调用云函数
    func callCloudFunction() {
        BmobCloud.callFunction(inBackground: "hello", withParameters: nil) { obj, error in
            if let error = error {
                self.result = "云函数调用失败：\(error.localizedDescription)"
            } else {
                self.result = "云函数返回：\(obj ?? "无返回")"
            }
        }
    }
    
    // 发起支付请求（需服务端支持，示例为伪代码）
    func payRequest() {
        // 这里只做演示，实际支付需服务端配合
        self.result = "支付功能需服务端配合，详见 Bmob 支付文档"
    }
    
    // 获取服务器时间
    func getServerTime() {
        DispatchQueue.global().async {
            let timeString = Bmob.getServerTimestamp()
            DispatchQueue.main.async {
                self.result = "服务器时间戳：\(timeString ?? "获取失败")"
            }
        }
    }
    
    // 设置网络超时时间
    func setNetworkTimeout() {
        Bmob.setBmobRequestTimeOut(15)
        self.result = "已设置网络超时时间为 15 秒"
    }
} 