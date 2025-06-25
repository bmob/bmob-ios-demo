import SwiftUI

// 短信服务页面，包含发送验证码、验证验证码示例
struct SMSView: View {
    @State private var result: String = ""
    @State private var phone: String = "13800138000"
    @State private var code: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("短信服务示例")
                .font(.title2)
                .padding()
            
            TextField("手机号", text: $phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("验证码", text: $code)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("发送验证码") {
                sendSMSCode()
            }
            Button("验证验证码") {
                verifySMSCode()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("短信服务")
    }
    
    // 发送验证码
    func sendSMSCode() {
        BmobSMS.requestCodeInBackground(withPhoneNumber: phone, andTemplate: "your_template") { msgId, error in
            if error == nil {
                self.result = "发送成功，smsId：\(msgId)"
            } else {
                self.result = "发送失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 验证验证码
    func verifySMSCode() {
        BmobSMS.verifySMSCodeInBackground(withPhoneNumber: phone, andSMSCode: code) { isSuccessful, error in
            if isSuccessful {
                self.result = "验证成功"
            } else {
                self.result = "验证失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
} 