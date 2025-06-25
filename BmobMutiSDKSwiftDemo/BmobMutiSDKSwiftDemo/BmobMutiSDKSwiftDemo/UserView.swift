import SwiftUI

// 用户管理页面，包含注册、登录、查询、更新、登出等示例
struct UserView: View {
    @State private var result: String = ""
    @State private var lastUser: BmobUser? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("用户管理示例")
                .font(.title2)
                .padding()
            
            Button("注册用户") {
                registerUser()
            }
            Button("用户登录") {
                loginUser()
            }
            Button("查询用户") {
                queryUser()
            }
            Button("查询所有用户") {
                queryAllUsers()
            }
            Button("更新用户") {
                updateUser()
            }
            Button("用户登出") {
                logoutUser()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("用户管理")
    }
    
    // 注册用户
    func registerUser() {
        let user = BmobUser()
        user.username = "testuser\(Int.random(in: 1000...9999))"
        user.password = "123456"
        user.setObject(NSNumber(value: 18), forKey: "age")
        user.signUpInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "注册成功，用户名：\(user.username ?? "")"
                self.lastUser = user
            } else {
                self.result = "注册失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 用户登录
    func loginUser() {
        BmobUser.loginWithUsername(inBackground: "testuser", password: "123456") { user, error in
            if let user = user {
                self.result = "登录成功，用户名：\(user.username ?? "")"
                self.lastUser = user
            } else {
                self.result = "登录失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 查询用户
    func queryUser() {
        let query = BmobUser.query()
        query?.whereKey("username", equalTo: "testuser")
        query?.findObjectsInBackground({ array, error in
            if let error = error {
                self.result = "查询失败：\(error.localizedDescription)"
            } else if let array = array as? [BmobUser], let user = array.first {
                self.result = "查询到用户：\(user.username ?? "")"
                self.lastUser = user
            } else {
                self.result = "没有查到用户"
            }
        })
    }
    
    // 查询所有用户
    func queryAllUsers() {
        let query = BmobUser.query()
        query?.findObjectsInBackground({ array, error in
            if let error = error {
                self.result = "查询所有用户失败：\(error.localizedDescription)"
            } else if let array = array as? [BmobUser], !array.isEmpty {
                let names = array.compactMap { $0.username ?? $0.objectId }
                self.result = "所有用户：\n" + names.joined(separator: "\n")
            } else {
                self.result = "没有用户数据"
            }
        })
    }
    
    // 更新用户
    func updateUser() {
        guard let user = BmobUser.getCurrent() else {
            self.result = "请先登录"
            return
        }
        user.setObject(NSNumber(value: 30), forKey: "age")
        user.updateInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "更新用户信息成功"
            } else {
                self.result = "更新失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 用户登出
    func logoutUser() {
        BmobUser.logout()
        self.result = "已登出"
    }
} 