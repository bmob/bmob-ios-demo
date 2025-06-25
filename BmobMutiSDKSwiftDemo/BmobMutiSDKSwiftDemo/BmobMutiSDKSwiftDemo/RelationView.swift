import SwiftUI

// 关系关联页面，包含 Pointer 和 Relation 的添加与查询示例
struct RelationView: View {
    @State private var result: String = ""
    @State private var postId: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("关系关联示例")
                .font(.title2)
                .padding()
            
            Button("添加 Pointer 关联") {
                addPointer()
            }
            Button("添加 Relation 关联") {
                addRelation()
            }
            Button("查询 Pointer 关联") {
                queryPointer()
            }
            Button("查询 Relation 关联") {
                queryRelation()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("关系关联")
    }
    
    // 添加 Pointer 关联
    func addPointer() {
        // 假设有一个 _User 表的 objectId
        let author = BmobUser(outDataWithClassName: "_User", objectId: "用户objectId")
        let post = BmobObject(className: "Post")
        post?.setObject("标题", forKey: "title")
        post?.setObject(author, forKey: "author")
        post?.saveInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "Pointer 关联添加成功"
                self.postId = post?.objectId
            } else {
                self.result = "添加失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 添加 Relation 关联
    func addRelation() {
        guard let postId = postId else {
            self.result = "请先添加一条 Post"
            return
        }
        let post = BmobObject(outDataWithClassName: "Post", objectId: postId)
        let relation = BmobRelation()
        let user = BmobUser(outDataWithClassName: "_User", objectId: "用户objectId")
        relation.add(user)
        post?.add(relation, forKey: "likes")
        post?.updateInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "Relation 关联添加成功"
            } else {
                self.result = "添加失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 查询 Pointer 关联
    func queryPointer() {
        let query = BmobQuery(className: "Post")
        query?.includeKey("author")
        query?.findObjectsInBackground({ array, error in
            if let error = error {
                self.result = "查询失败：\(error.localizedDescription)"
            } else if let array = array as? [BmobObject], let first = array.first {
                if let author = first.object(forKey: "author") as? BmobUser {
                    self.result = "查询到 Post，作者：\(author.username ?? "")"
                } else {
                    self.result = "查询到数据，但无作者"
                }
            } else {
                self.result = "没有数据"
            }
        })
    }
    
    // 查询 Relation 关联
    func queryRelation() {
        guard let postId = postId else {
            self.result = "请先添加一条 Post"
            return
        }
        let post = BmobObject(outDataWithClassName: "Post", objectId: postId)
        let query = BmobQuery(className: "_User")
        query?.whereObjectKey("likes", relatedTo: post)
        query?.findObjectsInBackground({ array, error in
            if let error = error {
                self.result = "查询失败：\(error.localizedDescription)"
            } else if let array = array as? [BmobUser], let first = array.first {
                self.result = "查询到喜欢该帖子的用户：\(first.username ?? "")"
            } else {
                self.result = "没有数据"
            }
        })
    }
} 