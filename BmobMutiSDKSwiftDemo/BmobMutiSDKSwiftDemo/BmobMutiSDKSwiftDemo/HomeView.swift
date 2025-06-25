import SwiftUI

// 首页视图，导航到各功能页面
struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("数据库操作", destination: DatabaseView())
                NavigationLink("用户管理", destination: UserView())
                NavigationLink("文件管理", destination: FileView())
                NavigationLink("短信服务", destination: SMSView())
                NavigationLink("推送服务", destination: PushView())
                NavigationLink("地理位置", destination: GeoView())
                NavigationLink("关系关联", destination: RelationView())
                NavigationLink("ACL 权限管理", destination: ACLView())
                NavigationLink("统计与分组", destination: StatisticsView())
                NavigationLink("其他功能", destination: OtherView())
            }
            .navigationTitle("Bmob SDK Demo")
        }
    }
} 