//
//  ContentView.swift
//  BmobMutiSDKSwiftDemo
//
//  Created by magic on 2025/6/23.
// 81f39d4b023b93d62a48178c9db3c30e

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button("测试查询用户表") {
                print("开始查询用户表...")
                let query = BmobQuery(className: "_User")
                print("query对象创建状态: \(query != nil ? "成功" : "失败")")
                
                query?.findObjectsInBackground { array, error in
                    print("进入查询回调...")
                    if let error = error {
                        print("查询失败，错误详情:")
                        print("错误码: \(error._code)")
                        print("错误信息: \(error.localizedDescription)")
                        print("原始错误: \(error)")
                    } else if let users = array {
                        print("查询成功，用户数量: \(users.count)")
                        for user in users {
                            if let user = user as? BmobObject {
                                print("用户信息: \(user.description)")
                            }
                        }
                    } else {
                        print("查询结果为空，且没有错误信息")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("测试分片上传文件") {
                showingFilePicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedFileURL = url
                    uploadFile(url: url)
                }
            case .failure(let error):
                print("文件选择失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func uploadFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("无法访问文件")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let file = BmobFile(filePath: url.path)
        file?.saveInBackground(byDataSharding: { isSuccessful, error in
            if isSuccessful {
                print("文件上传成功")
                print("文件名: \(file?.name ?? "未知")")
                print("文件URL: \(file?.url ?? "未知")")
            
        
                
                // 创建一个对象来保存文件信息
                let obj = BmobObject(className: "FileTest")
                obj?.setObject(file, forKey: "file")
                // 保存文件名
                obj?.setObject(file?.name, forKey: "fileName")
                // 保存文件URL
                obj?.setObject(file?.url, forKey: "fileUrl")
        
                
                obj?.saveInBackground { success, error in
                    if success {
                        print("文件信息保存成功")
                        // 打印保存的对象ID
                        print("保存的对象ID: \(obj?.objectId ?? "未知")")
                    } else {
                        print("文件信息保存失败: \(error?.localizedDescription ?? "")")
                    }
                }
            } else {
                print("文件上传失败: \(error?.localizedDescription ?? "")")
            }
        })
    }
}

#Preview {
    ContentView()
}
