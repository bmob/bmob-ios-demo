import SwiftUI

// 数据库操作页面，包含增删改查示例
struct DatabaseView: View {
    @State private var result: String = ""
    @State private var lastObjectId: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Chat 表操作示例")
                .font(.title2)
                .padding()
            
            Button("添加数据") {
                addData()
            }
            Button("查询数据") {
                queryData()
            }
            Button("更新数据") {
                updateData()
            }
            Button("删除数据") {
                deleteData()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("数据库操作")
    }
    
    // 添加数据
    func addData() {
        let chat = BmobObject(className: "Chat")
        chat?.setObject("https://example.com/avatar.png", forKey: "avatarUrl")
        chat?.setObject("你好，Bmob！", forKey: "content")
        chat?.setObject("小明", forKey: "nickName")
        // own 字段为 Pointer，关联当前用户
//        if let user = BmobUser.currentUser() {
//            chat?.setObject(user, forKey: "own")
//        }
        chat?.saveInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "添加数据成功"
                self.lastObjectId = chat?.objectId
            } else {
                self.result = "添加失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 查询数据
    func queryData() {
        let query = BmobQuery(className: "Chat")
        query?.order(byDescending: "createdAt")
        query?.limit = 1
        query?.includeKey("own") // 查询时包含 own 关联用户信息
        query?.findObjectsInBackground({ array, error in
            if let error = error {
                self.result = "查询失败：\(error.localizedDescription)"
            } else if let array = array as? [BmobObject], let first = array.first {
                let avatarUrl = first.object(forKey: "avatarUrl") as? String ?? ""
                let content = first.object(forKey: "content") as? String ?? ""
                let nickName = first.object(forKey: "nickName") as? String ?? ""
                let own = first.object(forKey: "own") as? BmobUser
                let ownName = own?.username ?? ""
                self.result = "内容：\(content)\n昵称：\(nickName)\n头像：\(avatarUrl)\n用户：\(ownName)"
                self.lastObjectId = first.objectId
            } else {
                self.result = "没有数据"
            }
        })
    }
    
    // 更新数据
    func updateData() {
        guard let objectId = lastObjectId else {
            self.result = "请先添加或查询一条数据"
            return
        }
//        let chat = BmobObject(outDataWithClassName: "Chat", objectId: objectId)
//        chat?.setObject("更新后的内容", forKey: "content")
//        chat?.updateInBackground({ isSuccessful, error in
//            if isSuccessful {
//                self.result = "更新成功"
//            } else {
//                self.result = "更新失败：\(error?.localizedDescription ?? "未知错误")"
//            }
//        })
    }
    
    // 删除数据
    func deleteData() {
        guard let objectId = lastObjectId else {
            self.result = "请先添加或查询一条数据"
            return
        }
        let chat = BmobObject(outDataWithClassName: "Chat", objectId: objectId)
        chat?.deleteInBackground({ isSuccessful, error in
            if isSuccessful {
                self.result = "删除成功"
                self.lastObjectId = nil
            } else {
                self.result = "删除失败：\(error?.localizedDescription ?? "未知错误")"
            }
        })
    }
} 
