import SwiftUI
import UniformTypeIdentifiers

// 文件选择器封装
struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                onPick(url)
            }
        }
    }
}

// 文件管理页面，包含文件上传、下载、删除示例
struct FileView: View {
    @State private var result: String = ""
    @State private var fileUrl: String? = nil
    @State private var showDocumentPicker = false
    @State private var pickedFileURL: URL? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("文件管理示例")
                .font(.title2)
                .padding()
            
            Button("选择本地文件上传") {
                showDocumentPicker = true
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    pickedFileURL = url
                    showDocumentPicker = false
                    uploadPickedFile()
                }
            }
            
            Button("上传默认图片 test.png") {
                uploadFile()
            }
            Button("下载文件") {
                downloadFile()
            }
            Button("删除文件") {
                deleteFile()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("文件管理")
    }
    
    // 上传默认 test.png
    func uploadFile() {
        if let path = Bundle.main.path(forResource: "test", ofType: "png"),
           let data = NSData(contentsOfFile: path) {
            let file = BmobFile(fileName: "test.png", withFileData: data as Data)
            file?.save(inBackground: { isSuccessful, error in
                if isSuccessful {
                    self.result = "上传成功，文件URL：\(file?.url ?? "")"
                    self.fileUrl = file?.url
                } else {
                    self.result = "上传失败：\(error?.localizedDescription ?? "未知错误")"
                }
            })
        } else {
            self.result = "未找到本地 test.png 文件"
        }
    }
    
    // 上传用户选择的文件
    func uploadPickedFile() {
        guard let url = pickedFileURL else {
            self.result = "未选择文件"
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            let file = BmobFile(fileName: fileName, withFileData: data)
            file?.save(inBackground: { isSuccessful, error in
                if isSuccessful {
                    self.result = "上传成功，文件URL：\(file?.url ?? "")"
                    self.fileUrl = file?.url
                } else {
                    self.result = "上传失败：\(error?.localizedDescription ?? "未知错误")"
                }
            })
        } catch {
            self.result = "读取文件失败：\(error.localizedDescription)"
        }
    }
    
    // 下载文件
    func downloadFile() {
        guard let url = fileUrl, let fileURL = URL(string: url) else {
            self.result = "请先上传文件"
            return
        }
        let task = URLSession.shared.dataTask(with: fileURL) { data, response, error in
            if let data = data {
                let filePath = NSTemporaryDirectory() + "downloaded_test.png"
                FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                DispatchQueue.main.async {
                    self.result = "下载成功，保存路径：\(filePath)"
                }
            } else {
                DispatchQueue.main.async {
                    self.result = "下载失败：\(error?.localizedDescription ?? "未知错误")"
                }
            }
        }
        task.resume()
    }
    
    // 删除文件
    func deleteFile() {
//        guard let url = fileUrl else {
//            self.result = "请先上传文件"
//            return
//        }
//        let file = BmobFile(filePath: url)
//        file?.deleteInBackground({ isSuccessful, error in
//            if isSuccessful {
//                self.result = "删除成功"
//                self.fileUrl = nil
//            } else {
//                self.result = "删除失败：\(error?.localizedDescription ?? "未知错误")"
//            }
//        })
    }
} 
