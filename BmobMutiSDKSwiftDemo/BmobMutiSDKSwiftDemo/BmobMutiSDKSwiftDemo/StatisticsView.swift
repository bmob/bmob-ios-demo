import SwiftUI

// 统计与分组页面，包含总和、平均值、最大值、最小值、分组统计示例
struct StatisticsView: View {
    @State private var result: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("统计与分组示例")
                .font(.title2)
                .padding()
            
            Button("计算总和") {
                calcSum()
            }
            Button("计算平均值") {
                calcAverage()
            }
            Button("计算最大值") {
                calcMax()
            }
            Button("计算最小值") {
                calcMin()
            }
            Button("分组统计") {
                groupByStatistics()
            }
            
            ScrollView {
                Text(result)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            Spacer()
        }
        .padding()
        .navigationTitle("统计与分组")
    }
    
    // 计算总和
    func calcSum() {
        let query = BmobQuery(className: "GameScore")
        query?.sumKeys(["score"])
        query?.calcInBackground({ array, error in
            if let error = error {
                self.result = "统计失败：\(error.localizedDescription)"
            } else if let array = array as? [NSDictionary], let dic = array.first {
                let sum = dic["_sumScore"] ?? 0
                self.result = "分数总和：\(sum)"
            } else {
                self.result = "没有数据"
            }
        })
    }
    
    // 计算平均值
    func calcAverage() {
        let query = BmobQuery(className: "GameScore")
        query?.averageKeys(["score"])
        query?.calcInBackground({ array, error in
            if let error = error {
                self.result = "统计失败：\(error.localizedDescription)"
            } else if let array = array as? [NSDictionary], let dic = array.first {
                let avg = dic["_avgScore"] ?? 0
                self.result = "分数平均值：\(avg)"
            } else {
                self.result = "没有数据"
            }
        })
    }
    
    // 计算最大值
    func calcMax() {
        let query = BmobQuery(className: "GameScore")
        query?.maxKeys(["score"])
        query?.calcInBackground({ array, error in
            if let error = error {
                self.result = "统计失败：\(error.localizedDescription)"
            } else if let array = array as? [NSDictionary], let dic = array.first {
                let max = dic["_maxScore"] ?? 0
                self.result = "分数最大值：\(max)"
            } else {
                self.result = "没有数据"
            }
        })
    }
    
    // 计算最小值
    func calcMin() {
        let query = BmobQuery(className: "GameScore")
        query?.minKeys(["score"])
        query?.calcInBackground({ array, error in
            if let error = error {
                self.result = "统计失败：\(error.localizedDescription)"
            } else if let array = array as? [NSDictionary], let dic = array.first {
                let min = dic["_minScore"] ?? 0
                self.result = "分数最小值：\(min)"
            } else {
                self.result = "没有数据"
            }
        })
    }
    
    // 分组统计
    func groupByStatistics() {
        let query = BmobQuery(className: "GameScore")
        query?.groupbyKeys(["playerName"])
        query?.sumKeys(["score"])
        query?.calcInBackground({ array, error in
            if let error = error {
                self.result = "分组统计失败：\(error.localizedDescription)"
            } else if let array = array as? [NSDictionary] {
                var text = ""
                for dic in array {
                    let name = dic["playerName"] ?? ""
                    let sum = dic["_sumScore"] ?? 0
                    text += "玩家：\(name) 总分：\(sum)\n"
                }
                self.result = text.isEmpty ? "没有数据" : text
            } else {
                self.result = "没有数据"
            }
        })
    }
} 