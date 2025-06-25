import SwiftUI

// 地理位置页面，包含添加地理位置、查询地理位置示例
struct GeoView: View {
    @State private var result: String = ""
    @State private var lastObjectId: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("地理位置示例")
                .font(.title2)
                .padding()
            
            Button("添加地理位置") {
                addGeoPoint()
            }
            Button("查询地理位置") {
                queryGeoPoint()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("地理位置")
    }
    
    // 添加地理位置
    func addGeoPoint() {
        let point = BmobGeoPoint(longitude: 116.397, withLatitude: 39.908)
        let obj = BmobObject(className: "LocationTest")
        obj?.setObject(point, forKey: "location")
        obj?.saveInBackground { isSuccessful, error in
            if isSuccessful {
                self.result = "添加地理位置成功"
                self.lastObjectId = obj?.objectId
            } else {
                self.result = "添加失败：\(error?.localizedDescription ?? "未知错误")"
            }
        }
    }
    
    // 查询地理位置
    func queryGeoPoint() {
        let query = BmobQuery(className: "LocationTest")
        let point = BmobGeoPoint(longitude: 116.397, withLatitude: 39.908)
        query?.whereKey("location", nearGeoPoint: point)
        query?.limit = 1
        query?.findObjectsInBackground({ array, error in
            if let error = error {
                self.result = "查询失败：\(error.localizedDescription)"
            } else if let array = array as? [BmobObject], let first = array.first {
                if let loc = first.object(forKey: "location") as? BmobGeoPoint {
                    self.result = "查询到地理位置：经度\(loc.longitude)，纬度\(loc.latitude)"
                } else {
                    self.result = "查询到数据，但无地理位置"
                }
            } else {
                self.result = "没有数据"
            }
        })
    }
} 