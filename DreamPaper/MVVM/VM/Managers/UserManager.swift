import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()

    // 本地用户个人信息
    @Published var user: XMUserInfo {
        didSet {
            savaModel(model: user)
        }
    }

    // 本地用户登录信息
    @Published var tokenInfo: XMTokenInfo {
        didSet {
            savaModel(model: tokenInfo)
        }
    }

    private init() {
        user = .init()
        tokenInfo = .init()
        user = loadModel(type: XMUserInfo.self)
        tokenInfo = loadModel(type: XMTokenInfo.self)
        guard Logged else { return }
        Task {
            // 仅针对已登陆用户
            await logedUserTask()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleMembershipBuySuccess), name: Notification.Name.MemberShipBuySucccess, object: nil)
    }

    @objc private func handleMembershipBuySuccess() {
//        MainViewModel.shared.currentTabbar = .profile
        Task {
            await self.get_user_info()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var Logged: Bool {
        tokenInfo.access_token.isEmpty == false
    }

    /*
     登录用户关键数据获取
     */
    @MainActor func logedUserTask() async {
        loadUserInfoError = false
        // 绑定个推别名
        let alias = AppConfig.env.rawValue + user.id
//        GeTuiSdk.bindAlias(alias, andSequenceNum: UUID().uuidString)
        // 商店初始化
//        let _ = StoreManager.shared
        // 应用关键信息：OSS凭证、当前版本等
        let _ = ConfigStore.shared
//        await configStore.getBellyBookEnmus()
        // 请求用户信息
        await get_user_info()
        // 登录成功，开始保活
//        await AlarmManager.shared.startBackgroundKeepAlive()
        MainViewModel.shared.currentTabbar = .home
        isInLogedUserTask = false
    }

    @Published var isInLogedUserTask: Bool = true
    @Published var loadUserInfoError: Bool = false

    // 持久化：模型的Model to JsonString
    func savaModel<M: Convertible>(model: M) {
        let jsonString = model.kj.JSONString()
        // 仅得到TypeName，例如“UserModel”
        let modelName = String(describing: type(of: model))
        // 以TypeName作为键，存入StringJson
        UserDefaults.standard.setValue(jsonString, forKey: modelName)
        print(jsonString)
    }

    // 读数据：模型的JsonString to Model
    func loadModel<M: Convertible>(type: Convertible.Type) -> M {
        // 仅得到TypeName，例如“UserModel”
        let modelName = String(describing: type).components(separatedBy: "(").first!
        // 以TypeName作为键，找寻数据
        if let data = UserDefaults.standard.string(forKey: modelName),
           // JsonString to ConvertibleModel
           let model = data.kj.model(type: type)
        {
            return model as! M
        } else {
            return .init()
        }
    }

    /*
     退出登录
     */
    @MainActor
    func logOut() {
        Apphelper.shared.pushAlert(title: "退出登录", message: "确认退出登录？系统会清空当前用户的全部缓存和信息。", actions: [UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            Apphelper.shared.closeSheet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.logOutUser()
            }
        }), .init(title: "取消", style: .default)])
    }

    /*
     删除用户缓存
     */
    @MainActor
    func logOutUser() {
        user = .init()
        tokenInfo = .init()
        isInLogedUserTask = true
        loadUserInfoError = false
        ConfigStore.shared.reset()
        MainViewModel.shared.currentTabbar = .home
        Apphelper.shared.closeKeyBoard()
        // 清空所有UserDefaults.standard储存的值
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
    }

//
//    /*
//     更新用户资料
//     */
//    @MainActor
//    func update_user_info(user: UserAPI.UserUpdate) async -> MoyaResult {
//        let target = UserAPI.update_me(p: user)
//        let result = await Networking.request_async(target)
//        if result.is200Ok {
//            await get_user_info()
//        }
//        return result
//    }
//
    /*
     获取用户资料
     */
    @MainActor
    func get_user_info() async {
        let target = UserAPI.me
        let result = await Networking.request_async(target)
        if result.is200Ok, let userinfo = result.mapObject(XMUserInfo.self) {
            user = userinfo
        } else {
            loadUserInfoError = true
        }
    }

    /*
     注销账户
     */
    @MainActor
    func deleteSelf() {
        Apphelper.shared.pushAlert(title: "注销用户", message: "确认从StrangerBell注销？系统会清除你的全部信息。这可能会消耗一定的时间。", actions: [UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                LocalNotificationManager.shared.did_presentSheet = true
                self.user = .init()
                self.tokenInfo = .init()
                MainViewModel.shared.currentTabbar = .home
            }
        }), .init(title: "取消", style: .default)])
    }
}
