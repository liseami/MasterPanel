//
//  XMModRequestViewModel.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/18.
//

import Foundation

/**
 单一Mod请求协议
 */

class XMModRequestViewModel<ListRowMod: Convertible>: ObservableObject {
    @Published var mod: ListRowMod
    @Published var reqStatus: XMRequestStatus = .isLoading
    var target: XMTargetType

    var pageName: String
    init(autoGetData: Bool = true, pageName: String, target: () -> XMTargetType) {
        self.target = target()
        self.pageName = pageName
        mod = .init()
        guard autoGetData else { return }
        Task { await self.getSingleData() }
    }

    deinit {}
}

extension XMModRequestViewModel {
    /// 获取单一结果
    @MainActor
    func getSingleData() async {
        if self.reqStatus != .isOK {
            self.reqStatus = .isLoading
        }
        let r = await Networking.request_async(self.target)
        if r.is200Ok {
            if let mod = r.mapObject(ListRowMod.self) {
                self.reqStatus = .isOK
                self.mod = mod
            } else {
                self.reqStatus = .isOKButEmpty
            }

        } else {
            self.reqStatus = .isNeedReTry
        }
    }
}
