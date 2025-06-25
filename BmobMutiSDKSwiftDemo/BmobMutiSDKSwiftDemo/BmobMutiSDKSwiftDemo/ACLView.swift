import SwiftUI

// ACL 权限管理页面，包含不同权限设置示例
struct ACLView: View {
    @State private var result: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ACL 权限管理示例")
                .font(.title2)
                .padding()
            
            Button("设置公开读写权限") {
                setPublicACL()
            }
            Button("设置仅自己读写权限") {
                setPrivateACL()
            }
            Button("设置指定用户/角色权限") {
                setUserRoleACL()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("ACL 权限管理")
    }
    
    // 设置公开读写权限
    func setPublicACL() {
        let obj = BmobObject(className: "TestACL")
        let acl = BmobACL()
        acl.setPublicReadAccess()
        acl.setPublicWriteAccess()
//        obj?.ACL = acl
        obj?.saveInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "设置公开读写权限成功"
            } else {
                self.result = "设置失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 设置仅自己读写权限
    func setPrivateACL() {
//        guard let user = BmobUser.currentUser() else {
//            self.result = "请先登录"
//            return
//        }
//        let obj = BmobObject(className: "TestACL")
//        let acl = BmobACL()
//        acl.setReadAccessForUser(user)
//        acl.setWriteAccessForUser(user)
//        obj?.ACL = acl
//        obj?.saveInBackground { isSuccessful, error in
//            if isSuccessful {
//                self.result = "设置仅自己读写权限成功"
//            } else {
//                self.result = "设置失败：\(error?.localizedDescription ?? "未知错误")"
//            }
//        }
    }
    
    // 设置指定用户/角色权限
    func setUserRoleACL() {
        let obj = BmobObject(className: "TestACL")
        let acl = BmobACL()
//        acl.setReadAccessForRole("admin")
//        acl.setWriteAccessForRole("admin")
//        obj?.ACL = acl
        obj?.saveInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "设置指定角色权限成功"
            } else {
                self.result = "设置失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
} 
