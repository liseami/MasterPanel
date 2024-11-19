//
//  UserInfoRequestViewModel.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/3/16.
//

import Foundation
class UserInfoRequestViewModel: NSObject, ObservableObject {
    init(showStep: InfoRequestStep = .username) {
        self.showStep = .username
    }

    @Published var showStep: InfoRequestStep = .username
    @Published var userNameInput: String = ""

    enum InfoRequestStep {
        case username
    }
//
//    /*
//     修改用户资料
//     */
//    func updateUserInfo(_ user: UserAPI.UserUpdate) async {
//        let r = await UserManager.shared.update_user_info(user: user)
//        if r.is200Ok, let user = r.mapObject(XMUserInfo.self) {
//            DispatchQueue.main.async {
//                UserManager.shared.user = user
//            }
//        }
//    }
}

extension UserInfoRequestViewModel {
    var usernameInputIsOk: Bool {
        let allowedCharacterSet: CharacterSet = {
            var allowed = CharacterSet.alphanumerics
            allowed.insert(charactersIn: "\u{4E00}" ... "\u{9FFF}") // 添加汉字范围
            return allowed
        }()

        let usernameInputCharacterSet = CharacterSet(charactersIn: self.userNameInput)

        // 检查是否包含不允许的字符
        let isValidUsernameInput = usernameInputCharacterSet.isSubset(of: allowedCharacterSet) && self.userNameInput.count < 12

        return isValidUsernameInput
    }
}
